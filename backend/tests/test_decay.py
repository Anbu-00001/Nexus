"""Temporal-decay math — app/decay.py.

Covers: all four domains, 0-month identity, far-future clamp (never negative),
unknown-domain default rate, and the fresh/aging/stale status thresholds.
"""
from datetime import date

import pytest

from app.decay import DECAY_PER_MONTH, decayed_confidence, months_between

NOW = date(2026, 6, 26)


# ── months_between ────────────────────────────────────────────────────────
def test_months_between_whole_year():
    assert months_between(date(2025, 6, 26), date(2026, 6, 26)) == pytest.approx(12.0)


def test_months_between_zero():
    assert months_between(NOW, NOW) == 0.0


def test_months_between_partial_days():
    # 15 days ≈ half a month under the /30 convention.
    assert months_between(date(2026, 6, 11), date(2026, 6, 26)) == pytest.approx(0.5)


# ── all four domains carry their declared monthly rate ────────────────────
@pytest.mark.parametrize("domain,rate", list(DECAY_PER_MONTH.items()))
def test_each_domain_uses_its_rate(domain, rate):
    one_month_ago = date(2026, 5, 26)
    d = decayed_confidence(1.0, domain, one_month_ago, NOW)
    assert d["decay_per_month"] == rate
    assert d["confidence"] == pytest.approx(round(1.0 - rate * 1.0, 2))


def test_four_domains_present():
    assert set(DECAY_PER_MONTH) == {"safety", "procedure", "incident", "spec"}


# ── zero months == initial (no erosion yet) ───────────────────────────────
@pytest.mark.parametrize("initial", [0.30, 0.55, 0.80, 1.0])
@pytest.mark.parametrize("domain", list(DECAY_PER_MONTH))
def test_zero_months_returns_initial(initial, domain):
    d = decayed_confidence(initial, domain, NOW, NOW)
    assert d["confidence"] == pytest.approx(round(initial, 2))
    assert d["months_since_confirmed"] == 0


# ── far future clamps to 0.0 and never goes negative ──────────────────────
@pytest.mark.parametrize("domain", list(DECAY_PER_MONTH))
def test_far_future_clamps_to_zero(domain):
    d = decayed_confidence(1.0, domain, date(1990, 1, 1), NOW)
    assert d["confidence"] == 0.0
    assert d["confidence"] >= 0.0
    assert d["status"] == "stale"
    assert d["stale"] is True


def test_confidence_never_exceeds_one():
    # An absurdly high "initial" is still clamped at 1.0.
    d = decayed_confidence(5.0, "spec", NOW, NOW)
    assert d["confidence"] == 1.0


# ── unknown domain falls back to the default 0.04/month ───────────────────
def test_unknown_domain_default_rate():
    d = decayed_confidence(1.0, "totally-made-up", date(2025, 6, 26), NOW)
    assert d["decay_per_month"] == 0.04
    assert d["confidence"] == pytest.approx(round(1.0 - 0.04 * 12, 2))  # 0.52


# ── status thresholds: fresh ≥0.80, aging ≥0.55, stale <0.55 ──────────────
def test_status_fresh_boundary():
    # exactly 0.80 → fresh
    assert decayed_confidence(0.80, "spec", NOW, NOW)["status"] == "fresh"


def test_status_aging_boundary_low():
    # exactly 0.55 → aging (inclusive)
    d = decayed_confidence(0.55, "spec", NOW, NOW)
    assert d["status"] == "aging"
    assert d["stale"] is False


def test_status_stale_boundary():
    # just under 0.55 → stale
    d = decayed_confidence(0.54, "spec", NOW, NOW)
    assert d["status"] == "stale"
    assert d["stale"] is True


def test_status_fresh_just_below_boundary_is_aging():
    assert decayed_confidence(0.79, "spec", NOW, NOW)["status"] == "aging"


# ── the planted demo assertion (must read exactly 0.41 / stale / 14) ──────
def test_planted_sop_assertion_numbers():
    d = decayed_confidence(1.0, "procedure", date(2025, 4, 26), NOW)
    assert d["confidence"] == 0.41
    assert d["status"] == "stale"
    assert d["stale"] is True
    assert d["months_since_confirmed"] == 14


def test_return_dict_shape():
    d = decayed_confidence(1.0, "procedure", date(2025, 4, 26), NOW)
    assert set(d) == {
        "confidence",
        "decay_per_month",
        "months_since_confirmed",
        "status",
        "stale",
    }
