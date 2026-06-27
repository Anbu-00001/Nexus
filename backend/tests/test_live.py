"""GENUINELY LIVE LLM tests — hit the real provider through the real keys.

These are the ONLY tests that consume free-tier quota. There are exactly TWO
of them, and both are skipped unless ``RUN_LIVE=1`` is set in the environment,
so the ordinary ``pytest`` run stays at zero quota.

Each makes at most ONE real call → 2 live calls total when enabled.
"""
from app import causal, llm
from tests.conftest import live_only, run_async


@live_only
def test_live_complete_returns_nonempty_string():
    """LIVE: app.llm.complete() against the real gemini→groq stack."""
    out = run_async(llm.complete(
        "Reply with a single short sentence about pump cavitation.",
        system="You are a terse reliability engineer.",
    ))
    assert isinstance(out, str)
    assert out.strip() != ""


@live_only
def test_live_explain_narrates_chain():
    """LIVE: app.causal.explain() — full reconstruct + real LLM narration."""
    result = run_async(causal.explain("Why did Pump P-101 fail in August 2023?"))
    assert isinstance(result["answer"], str)
    assert result["answer"].strip() != ""
    assert isinstance(result["title"], str) and result["title"].strip() != ""
    # numbers must remain the planted demo values even with a live narration
    assert result["prediction"]["probability"] == 0.74
    assert result["confidence"] == 0.81
