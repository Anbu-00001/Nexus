"""Causal-temporal reconstruction — app/causal.py (the sync reconstruct()).

These assert the planted demo numbers (recurrences 3, prob 0.74, conf 0.81)
plus the pairing logic and prediction-field shapes. No LLM is touched here.
"""
from datetime import date

import pytest

from app import causal, data


@pytest.fixture(scope="module")
def r():
    return causal.reconstruct()


# ── pairing correctness ───────────────────────────────────────────────────
def test_pairs_each_anomaly_with_next_failure():
    """3 of the 4 anomalies have a later failure; the 2026 one does not."""
    anomalies = [e for e in data.EVENTS if e["kind"] == "anomaly"]
    failures = [e for e in data.EVENTS if e["kind"] == "failure"]
    assert len(anomalies) == 4
    assert len(failures) == 3

    paired = [
        a for a in anomalies
        if any(f["date"] > a["date"] for f in failures)
    ]
    assert len(paired) == 3
    # The live/open anomaly is the most recent one (2026-06-02), unpaired.
    open_anomaly = max(
        (a for a in anomalies if not any(f["date"] > a["date"] for f in failures)),
        key=lambda a: a["date"],
    )
    assert open_anomaly["date"] == date(2026, 6, 2)


# ── headline planted numbers ──────────────────────────────────────────────
def test_recurrences_is_three(r):
    assert r["recurrences"] == 3


def test_probability_is_074(r):
    assert r["prediction"]["probability"] == 0.74


def test_confidence_is_081(r):
    assert r["confidence"] == 0.81


def test_mean_lag_positive(r):
    assert r["mean_lag_days"] > 0


def test_window_string_shape(r):
    w = r["prediction"]["window"]
    assert isinstance(w, str)
    assert w.startswith("next ")
    assert "weeks" in w
    # demo's exact planted window (uses an en-dash separator)
    assert w == "next 3–5 weeks"


def test_prediction_driver_mentions_v22(r):
    assert "V-22" in r["prediction"]["driver"]


def test_prediction_asset(r):
    assert r["prediction"]["asset"] == "Pump P-101"


def test_eta_is_iso_date(r):
    eta = r["prediction"]["eta"]
    # round-trips through date.fromisoformat → it's a valid ISO date string
    parsed = date.fromisoformat(eta)
    assert parsed.isoformat() == eta
    # ETA must be after the open anomaly (a forward projection)
    assert parsed > date(2026, 6, 2)


# ── structural integrity ──────────────────────────────────────────────────
def test_top_level_keys(r):
    for k in ("chain", "recurrences", "mean_lag_days", "confidence",
              "prediction", "sources", "events"):
        assert k in r


def test_chain_passthrough(r):
    assert r["chain"] is data.CAUSAL_CHAIN
    assert len(r["chain"]["steps"]) == 5


def test_sources_passthrough(r):
    assert r["sources"] == data.SOURCES
    assert len(r["sources"]) == 3


def test_events_serialised_as_iso_strings(r):
    assert len(r["events"]) == len(data.EVENTS)
    for e in r["events"]:
        assert isinstance(e["date"], str)
        date.fromisoformat(e["date"])  # raises if not ISO


def test_probability_capped_at_095(r):
    assert r["prediction"]["probability"] <= 0.95


def test_confidence_capped_at_095(r):
    assert r["confidence"] <= 0.95


# ── prediction sub-dict shape ─────────────────────────────────────────────
def test_prediction_keys(r):
    assert set(r["prediction"]) == {
        "asset", "probability", "window", "eta", "driver"
    }
