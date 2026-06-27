"""LLM provider routing & fallback — app/llm.py.

ALL tests here are MOCKED: the actual network functions (_gemini_text /
_groq_text / _gemini_call) are monkeypatched, and the module-level key/provider
globals are overridden. Zero quota is burned. Live calls live in test_live.py.
"""
import pytest

from app import llm
from tests.conftest import run_async


# ── complete(): primary=gemini, gemini works ──────────────────────────────
def test_complete_gemini_primary_success(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "gemini")
    monkeypatch.setattr(llm, "GEMINI_KEY", "fake-g")
    monkeypatch.setattr(llm, "GROQ_KEY", "fake-q")

    async def fake_gemini(prompt, system):
        return "GEMINI_ANSWER"

    async def fake_groq(prompt, system):  # should NOT be reached
        raise AssertionError("groq must not be called when gemini succeeds")

    monkeypatch.setattr(llm, "_gemini_text", fake_gemini)
    monkeypatch.setattr(llm, "_groq_text", fake_groq)

    assert run_async(llm.complete("hi", "sys")) == "GEMINI_ANSWER"


# ── complete(): gemini raises → falls back to groq ────────────────────────
def test_complete_falls_back_to_groq_on_gemini_error(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "gemini")
    monkeypatch.setattr(llm, "GEMINI_KEY", "fake-g")
    monkeypatch.setattr(llm, "GROQ_KEY", "fake-q")

    async def boom(prompt, system):
        raise RuntimeError("gemini 429 quota")

    async def fake_groq(prompt, system):
        return "GROQ_FALLBACK"

    monkeypatch.setattr(llm, "_gemini_text", boom)
    monkeypatch.setattr(llm, "_groq_text", fake_groq)

    assert run_async(llm.complete("hi", "sys")) == "GROQ_FALLBACK"


# ── complete(): primary=groq uses groq first ──────────────────────────────
def test_complete_groq_primary(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "groq")
    monkeypatch.setattr(llm, "GEMINI_KEY", "fake-g")
    monkeypatch.setattr(llm, "GROQ_KEY", "fake-q")

    async def fake_gemini(prompt, system):
        raise AssertionError("gemini must not be primary here")

    async def fake_groq(prompt, system):
        return "GROQ_PRIMARY"

    monkeypatch.setattr(llm, "_gemini_text", fake_gemini)
    monkeypatch.setattr(llm, "_groq_text", fake_groq)

    assert run_async(llm.complete("hi")) == "GROQ_PRIMARY"


# ── complete(): groq primary fails → falls back to gemini ─────────────────
def test_complete_groq_primary_falls_back_to_gemini(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "groq")
    monkeypatch.setattr(llm, "GEMINI_KEY", "fake-g")
    monkeypatch.setattr(llm, "GROQ_KEY", "fake-q")

    async def fake_gemini(prompt, system):
        return "GEMINI_RESCUE"

    async def boom(prompt, system):
        raise RuntimeError("groq down")

    monkeypatch.setattr(llm, "_gemini_text", fake_gemini)
    monkeypatch.setattr(llm, "_groq_text", boom)

    assert run_async(llm.complete("hi")) == "GEMINI_RESCUE"


# ── complete(): both providers fail → RuntimeError surfaced ───────────────
def test_complete_all_providers_fail(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "gemini")
    monkeypatch.setattr(llm, "GEMINI_KEY", "fake-g")
    monkeypatch.setattr(llm, "GROQ_KEY", "fake-q")

    async def boom(prompt, system):
        raise RuntimeError("nope")

    monkeypatch.setattr(llm, "_gemini_text", boom)
    monkeypatch.setattr(llm, "_groq_text", boom)

    with pytest.raises(RuntimeError, match="No LLM provider succeeded"):
        run_async(llm.complete("hi"))


# ── complete(): no keys at all → RuntimeError (nothing eligible) ──────────
def test_complete_no_keys_raises(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "gemini")
    monkeypatch.setattr(llm, "GEMINI_KEY", "")
    monkeypatch.setattr(llm, "GROQ_KEY", "")
    with pytest.raises(RuntimeError, match="No LLM provider succeeded"):
        run_async(llm.complete("hi"))


# ── complete(): only groq key present, gemini primary → still groq ────────
def test_complete_only_groq_key(monkeypatch):
    monkeypatch.setattr(llm, "PROVIDER", "gemini")
    monkeypatch.setattr(llm, "GEMINI_KEY", "")
    monkeypatch.setattr(llm, "GROQ_KEY", "fake-q")

    async def fake_groq(prompt, system):
        return "ONLY_GROQ"

    monkeypatch.setattr(llm, "_groq_text", fake_groq)
    assert run_async(llm.complete("hi")) == "ONLY_GROQ"


# ── vision(): no gemini key → raises cleanly ──────────────────────────────
def test_vision_requires_gemini_key(monkeypatch):
    monkeypatch.setattr(llm, "GEMINI_KEY", "")
    with pytest.raises(RuntimeError, match="Vision requires a Gemini key"):
        run_async(llm.vision("what is this", b"\x89PNG", "image/png"))


# ── vision(): with key, delegates to _gemini_call ─────────────────────────
def test_vision_calls_gemini(monkeypatch):
    monkeypatch.setattr(llm, "GEMINI_KEY", "fake-g")
    captured = {}

    async def fake_call(body):
        captured["body"] = body
        return "VISION_OK"

    monkeypatch.setattr(llm, "_gemini_call", fake_call)
    out = run_async(llm.vision("locate V-22", b"\x89PNGdata", "image/png"))
    assert out == "VISION_OK"
    # the image was base64-encoded into an inline_data part
    parts = captured["body"]["contents"][0]["parts"]
    assert any("inline_data" in p for p in parts)
    assert any(p.get("text") == "locate V-22" for p in parts)


# ── providers_status(): shape ─────────────────────────────────────────────
def test_providers_status_shape():
    s = llm.providers_status()
    assert set(s) == {"primary", "gemini", "gemini_model", "groq", "groq_model"}
    assert isinstance(s["gemini"], bool)
    assert isinstance(s["groq"], bool)
    assert isinstance(s["primary"], str)
    assert isinstance(s["gemini_model"], str)
    assert isinstance(s["groq_model"], str)


def test_providers_status_reflects_keys(monkeypatch):
    monkeypatch.setattr(llm, "GEMINI_KEY", "x")
    monkeypatch.setattr(llm, "GROQ_KEY", "")
    s = llm.providers_status()
    assert s["gemini"] is True
    assert s["groq"] is False
