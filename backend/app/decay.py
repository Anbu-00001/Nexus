"""Temporal Knowledge Decay.

Confidence in an assertion erodes over time unless re-confirmed. Rates are
domain-specific (safety-critical knowledge decays fast; equipment specs slowly).
We use a linear monthly decay so the surfaced numbers are explainable to a plant
engineer — e.g. a procedure last confirmed 14 months ago at 4.2%/month reads as
1.0 − 0.042·14 ≈ 0.41 (41%), exactly the figure the UI shows.
"""
from datetime import date

# Monthly decay rate per knowledge domain.
DECAY_PER_MONTH = {
    "safety": 0.090,     # re-confirm ~every 6 months
    "procedure": 0.042,  # medium
    "incident": 0.030,
    "spec": 0.011,       # equipment specs age slowly (~5y)
}


def months_between(a: date, b: date) -> float:
    return (b.year - a.year) * 12 + (b.month - a.month) + (b.day - a.day) / 30.0


def decayed_confidence(initial: float, domain: str, last_confirmed: date,
                       now: date) -> dict:
    rate = DECAY_PER_MONTH.get(domain, 0.04)
    months = months_between(last_confirmed, now)
    conf = max(0.0, min(1.0, initial - rate * months))
    if conf >= 0.80:
        status = "fresh"
    elif conf >= 0.55:
        status = "aging"
    else:
        status = "stale"
    return {
        "confidence": round(conf, 2),
        "decay_per_month": rate,
        "months_since_confirmed": round(months),
        "status": status,
        "stale": conf < 0.55,
    }
