"""The planted synthetic plant dataset.

This mirrors the narrative the Flutter app shows on mock data, but here the
maintenance events are *real rows* the causal engine reasons over — so the
demo's headline (V-22 → P-101, with a recurring pattern → prediction) is
reconstructed from data, not hard-coded prose.
"""
from datetime import date

PLANT = "Rashtriya Petrochemicals · Vadodara · Unit 3"

# Maintenance / event log. `kind` is one of: anomaly (a precursor signal on an
# upstream asset) or failure (the downstream outcome on the pump).
EVENTS = [
    {"date": date(2019, 6, 12), "asset": "V-22",  "kind": "anomaly", "text": "Valve V-22 partial-close complaint logged"},
    {"date": date(2019, 8, 7),  "asset": "P-101", "kind": "failure",  "text": "P-101 bearing failure — cavitation damage"},
    {"date": date(2021, 6, 9),  "asset": "V-22",  "kind": "anomaly", "text": "V-22 thermal expansion / partial restriction noted"},
    {"date": date(2021, 9, 3),  "asset": "P-101", "kind": "failure",  "text": "P-101 bearing failure — repeat cavitation"},
    {"date": date(2023, 8, 3),  "asset": "V-22",  "kind": "anomaly", "text": "V-22 held partial-closed ~11 days, suction starved"},
    {"date": date(2023, 8, 14), "asset": "P-101", "kind": "failure",  "text": "P-101 catastrophic bearing failure"},
    # Recent re-emergence — the live trigger for the prediction.
    {"date": date(2026, 6, 2),  "asset": "V-22",  "kind": "anomaly", "text": "V-22 slight restriction; cavitation signature re-emerging"},
]

# The reconstructed cause→effect chain (nodes the LLM narrates over).
CAUSAL_CHAIN = {
    "id": "CC-07",
    "steps": [
        {"label": "V-22", "role": "valve", "type": "equipment"},
        {"label": "cavitation", "role": "process", "type": "event"},
        {"label": "vibration spike", "role": "signal", "type": "event"},
        {"label": "P-101 bearing wear", "role": "bearing", "type": "equipment"},
        {"label": "pump failure", "role": "outcome", "type": "causalChain"},
    ],
}

SOURCES = [
    {"kind": "PID", "label": "P&ID-204.pdf · sheet 3"},
    {"kind": "LOG", "label": "maintenance-log-2023.pdf · row 142"},
    {"kind": "SME", "label": "R. Okafor · voice interview"},
]

# Knowledge assertions carrying temporal-decay metadata.
ASSERTIONS = {
    "SOP-P-101-M": {
        "title": "Controlled restart sequence",
        "body": "Confirm suction valve V-22 fully open, prime casing, then "
                "energize at reduced speed…",
        "domain": "procedure",          # decay class
        "initial_confidence": 1.0,
        "last_confirmed": date(2025, 4, 26),  # ~14 months before the demo's "now"
    },
}

# "Now" for the demo, so decay numbers are deterministic.
DEMO_NOW = date(2026, 6, 26)
