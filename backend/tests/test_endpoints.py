"""HTTP endpoints via in-process TestClient — app/main.py.

The sandbox kills uvicorn, so everything runs through ``TestClient`` (ASGI
in-process). The one route that would hit the LLM (/query) is exercised with
``app.causal.complete`` monkeypatched, so the default run burns zero quota.
"""
import json

from app import causal
from tests.conftest import tiny_png


# ── /health ────────────────────────────────────────────────────────────────
def test_health_shape(client):
    res = client.get("/health")
    assert res.status_code == 200
    body = res.json()
    assert body["status"] == "ok"
    assert isinstance(body["plant"], str) and body["plant"]
    prov = body["providers"]
    assert set(prov) == {"primary", "gemini", "gemini_model", "groq", "groq_model"}


# ── /assertion ─────────────────────────────────────────────────────────────
def test_assertion_valid(client):
    res = client.get("/assertion/SOP-P-101-M")
    assert res.status_code == 200
    body = res.json()
    assert body["id"] == "SOP-P-101-M"
    assert body["confidence"] == 0.41
    assert body["status"] == "stale"
    assert body["stale"] is True
    assert body["months_since_confirmed"] == 14
    assert body["decay_per_month"] == 0.042
    assert "title" in body and "body" in body


def test_assertion_unknown_id_returns_error_but_200(client):
    res = client.get("/assertion/DOES-NOT-EXIST")
    assert res.status_code == 200          # graceful, not a hard 404
    body = res.json()
    assert body["error"] == "unknown assertion"
    assert body["id"] == "DOES-NOT-EXIST"
    assert "confidence" not in body


# ── /graph ─────────────────────────────────────────────────────────────────
def test_graph_values(client):
    res = client.get("/graph")
    assert res.status_code == 200
    body = res.json()
    assert body["recurrences"] == 3
    assert body["confidence"] == 0.81
    assert body["prediction"]["probability"] == 0.74
    assert body["prediction"]["window"] == "next 3–5 weeks"
    assert body["prediction"]["asset"] == "Pump P-101"
    assert "V-22" in body["prediction"]["driver"]
    # events serialised to ISO strings (JSON-safe)
    assert all(isinstance(e["date"], str) for e in body["events"])


# ── /query (mocked LLM — no quota) ────────────────────────────────────────
def test_query_happy_path_mocked(client, monkeypatch):
    async def fake_complete(prompt, system=""):
        return json.dumps({
            "title": "Root cause: valve-induced cavitation",
            "answer": "V-22 starved P-101 suction, inducing cavitation.",
        })

    monkeypatch.setattr(causal, "complete", fake_complete)

    res = client.post("/query", json={"question": "Why did P-101 fail?"})
    assert res.status_code == 200
    body = res.json()
    for k in ("title", "answer", "chain", "prediction", "sources", "confidence"):
        assert k in body
    assert body["prediction"]["probability"] == 0.74
    assert body["confidence"] == 0.81
    assert body["title"] == "Root cause: valve-induced cavitation"
    assert "cavitation" in body["answer"]


def test_query_uses_default_question_when_omitted(client, monkeypatch):
    """QueryIn.question has a default, so an empty body still works."""
    seen = {}

    async def fake_complete(prompt, system=""):
        seen["prompt"] = prompt
        return '{"title":"t","answer":"a"}'

    monkeypatch.setattr(causal, "complete", fake_complete)
    res = client.post("/query", json={})
    assert res.status_code == 200
    # the planted default question made it into the prompt
    assert "P-101" in seen["prompt"]


def test_query_survives_llm_failure_offline_fallback(client, monkeypatch):
    """If complete() blows up, explain() must still return the hardcoded chain."""
    async def boom(prompt, system=""):
        raise RuntimeError("simulated quota exhaustion")

    monkeypatch.setattr(causal, "complete", boom)
    res = client.post("/query", json={"question": "why?"})
    assert res.status_code == 200
    body = res.json()
    # fallback narration tag is appended on failure
    assert "offline narration" in body["answer"]
    assert body["prediction"]["probability"] == 0.74


# ── /query bad input ──────────────────────────────────────────────────────
def test_query_empty_question_mocked(client, monkeypatch):
    async def fake_complete(prompt, system=""):
        return '{"title":"t","answer":"a"}'

    monkeypatch.setattr(causal, "complete", fake_complete)
    res = client.post("/query", json={"question": ""})
    assert res.status_code == 200  # empty string is a valid str


def test_query_long_question_mocked(client, monkeypatch):
    async def fake_complete(prompt, system=""):
        return '{"title":"t","answer":"a"}'

    monkeypatch.setattr(causal, "complete", fake_complete)
    res = client.post("/query", json={"question": "why? " * 5000})
    assert res.status_code == 200


def test_query_wrong_type_question_422(client):
    # question must be a string; pydantic v2 rejects a non-str → 422
    res = client.post("/query", json={"question": 12345})
    assert res.status_code == 422


def test_query_malformed_json_body_422(client):
    res = client.post(
        "/query",
        content="{not valid json",
        headers={"content-type": "application/json"},
    )
    assert res.status_code == 422


# ── /vision/pid ───────────────────────────────────────────────────────────
def test_vision_pid_multipart_ok_keys(client):
    """A valid PNG + question returns 200 with answer+ok keys.

    ``ok`` may be True (live vision worked) or False (no quota / key) — both are
    acceptable; we only assert the contract shape and a non-empty answer.
    """
    png = tiny_png()
    res = client.post(
        "/vision/pid",
        data={"question": "Where is valve V-22?"},
        files={"image": ("pid.png", png, "image/png")},
    )
    assert res.status_code == 200
    body = res.json()
    assert "answer" in body and "ok" in body
    assert isinstance(body["ok"], bool)
    assert isinstance(body["answer"], str) and body["answer"]


def test_vision_pid_missing_image_422(client):
    res = client.post("/vision/pid", data={"question": "where?"})
    assert res.status_code == 422


def test_vision_pid_missing_question_422(client):
    png = tiny_png()
    res = client.post(
        "/vision/pid",
        files={"image": ("pid.png", png, "image/png")},
    )
    assert res.status_code == 422


def test_vision_pid_no_gemini_key_returns_ok_false(client, monkeypatch):
    """With no Gemini key the route degrades gracefully (ok=False, 200)."""
    from app import llm
    monkeypatch.setattr(llm, "GEMINI_KEY", "")
    png = tiny_png()
    res = client.post(
        "/vision/pid",
        data={"question": "where is V-22?"},
        files={"image": ("pid.png", png, "image/png")},
    )
    assert res.status_code == 200
    body = res.json()
    assert body["ok"] is False
    assert "Vision unavailable" in body["answer"]
