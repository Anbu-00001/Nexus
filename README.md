# NEXUS · Industrial AI

NEXUS is a state-of-the-art Flutter dashboard designed for industrial manufacturing and processing plants. It leverages artificial intelligence to map plant systems, predict equipment failures, model operational knowledge decay, and enable intuitive cross-persona collaboration from the front-line technician to the plant manager.

---

## 🚀 Key Features

The application is structured around a multi-faceted design that addresses key industrial workflows:

### 1. Ingestion Panel (`Ingest`)
*   **Structured Parsing**: Streamlines uploading complex engineering diagrams (P&IDs), legacy maintenance logs (PDFs), and hand-written inspection sheets (via OCR).
*   **Live Status & Extraction**: Displays real-time progress indicators showing structural mappings, connection resolutions, and entity extraction.

### 2. Knowledge Graph Explorer (`Graph`)
*   **Dynamic Visualizations**: Features a custom-rendered nodes-and-edges canvas displaying relationships between equipment, documents, events, assertions, and tacit knowledge.
*   **Causal Paths Highlighted**: Illuminates multi-step failure pathways (e.g., *V-22 valve partial close → cavitation → vibration spike → P-101 bearing wear → pump failure*) to speed up root-cause investigation.

### 3. Root Cause Query Assistant (`Query`)
*   **Natural Language interface**: Allows engineers to chat directly with plant intelligence to retrieve past failure logs, consult standard operating procedures, and check real-time system predictions.

### 4. P&ID Viewer (`P&ID`)
*   **Interactive Schematics**: View piping and instrumentation diagrams alongside their digital twin configurations to trace physical connections to logical data models.

### 5. Knowledge/SOP Decay Tracker (`Decay`)
*   **Temporal Confidence Modeling**: Calculates and visualizes the confidence of assertions (SOPs, rules-of-thumb) over time. 
*   **Fresh vs. Stale Visuals**: Uses a temporal decay scale to label knowledge as *Fresh* (Green), *Aging* (Amber), or *Stale* (Red) based on months since the last human confirmation.

### 6. Voice Tacit Knowledge Capture (`Capture`)
*   **Mic-Capture Interface**: Empowers field technicians to speak observations directly into the system, which are then parsed and added to the Knowledge Graph as tacit knowledge nodes.

### 7. Manager Dashboard (`Dashboard`)
*   **Key Performance Indicators**: High-level tracking of Unplanned Downtime, MTBF (Mean Time Between Failures), Procedure Compliance, and Open Predictions.
*   **Clustered Failure Communities**: Displays risk matrices grouping related assets by shared causal roots (e.g., *Suction/Cavitation*, *Seal/Lubrication*).
*   **Historical Trends**: A clean, stacked bar chart summarizing downtime by physical component vs. process-induced issues over the trailing 8 weeks.

---

## 👥 Persona-Driven Workflows

NEXUS dynamically morphs the user interface based on the active operational persona:

| Persona | Primary Focus | Default View |
| :--- | :--- | :--- |
| **Technician** | Field checkouts, SOP verification, capturing oral observations | **Decay / SOP Tracker** |
| **Engineer** | Detailed diagnostics, P&ID tracing, causal graph analysis, query assistant | **Query Assistant** |
| **Manager** | Plant health, KPIs, downtime patterns, risk allocation | **KPI Dashboard** |

---

## 🎨 Design & Token System

NEXUS uses a dark-theme visual language engineered for high-visibility industrial settings (based on HSL tailored tokens):

*   **Colors**:
    *   `bgBase` / `bgSunken`: Deep space blues (`#0A0C10` / `#07090B`) reducing glare.
    *   `cyan`: Core intelligence accent (`#2BE8DE`).
    *   `causal`: Purple glow (`#8B6CFF`) used for active failure paths.
    *   `fresh` / `aging` / `stale`: Semantic green, amber, and red indicating state health.
*   **Typography**: Styled with IBM Plex Sans (modern readability) and IBM Plex Mono (highly legible technical data) loaded via Google Fonts.
*   **Responsive Layouts**: 
    *   *Desktop Mode*: Presents a persistent left navigation rail and hosts mobile-exclusive features in an aligned simulated phone preview frame.
    *   *Mobile Mode*: Provides an elegant bottom navigation bar tailored to one-handed use in the field.

---

## 🛠️ Technical Stack & Setup

### Requirements
*   Flutter SDK: `^3.11.3`
*   Dart SDK: matching the Flutter installation

### Project Dependencies
*   `flutter`: Core UI framework.
*   `cupertino_icons`: iOS-style icons.
*   `google_fonts`: Dynamic loading for IBM Plex Sans & IBM Plex Mono fonts.

### Setup Instructions
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Anbu-00001/Nexus.git
    cd Nexus
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the Application**:
    ```bash
    flutter run
    ```
    *Note: Supports Flutter Web, Android, iOS, and Desktop platforms. The app
    renders fully on a built-in demo dataset, so it runs with or without the
    backend below.*

---

## 🧠 AI Engine (FastAPI backend)

The intelligence behind NEXUS lives in a small, provider-agnostic FastAPI
service under [`backend/`](backend/). The Flutter app ships with a matching
demo dataset and can call this service for live answers; if the service is
offline it transparently falls back to the bundled data, so a demo never breaks.

### What it does
*   **Causal–temporal reasoning** (`app/causal.py`): reconstructs the recurring
    pattern in the maintenance log — an upstream **V-22** anomaly that reliably
    precedes a downstream **P-101** failure at a consistent lag — counts its
    recurrences, and projects the next occurrence (probability + time window).
    A large language model then narrates the chain in plain engineering
    language with source citations.
*   **Temporal knowledge decay** (`app/decay.py`): confidence in an assertion
    erodes linearly per month at a domain-specific rate (safety-critical decays
    fast, equipment specs slowly). A procedure last confirmed 14 months ago at
    4.2 %/month surfaces as **41 % — STALE**, exactly as the UI shows.
*   **Vision-native P&ID Q&A** (`app/main.py` → `/vision/pid`): sends the
    drawing image + question to a multimodal model to locate a component.
*   **Provider abstraction** (`app/llm.py`): Google **Gemini** (`gemini-2.5-flash`,
    multimodal) as primary, **Groq** (Llama 3.3 70B) as a fast text fallback —
    a Gemini failure (e.g. free-tier quota) auto-falls-back to Groq so text
    answers keep flowing.

> **Honest framing (and a deliberate design choice):** with only a handful of
> failure events there is no statistically valid *causal discovery* to perform.
> NEXUS instead does **temporal pattern reconstruction + LLM narration** — which
> is robust on sparse industrial data and exactly what a reliability engineer
> reasons through. We do not overclaim a DoWhy/PC statistical-discovery result.

### Endpoints
| Method | Path | Purpose |
| :-- | :-- | :-- |
| `GET`  | `/health` | service + provider status |
| `POST` | `/query` | causal chain + failure prediction, LLM-narrated |
| `GET`  | `/assertion/{id}` | temporal-decay confidence for an assertion |
| `GET`  | `/graph` | reconstructed causal-chain summary |
| `POST` | `/vision/pid` | locate a component on a P&ID image (multipart) |

### Setup & run
```bash
cd backend
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8077      # http://127.0.0.1:8077/docs
```

### API keys (`.env` at the repo root — git-ignored)
Copy `.env.example` to `.env` and fill in:
```
LLM_PROVIDER=gemini
GEMINI_API_KEY=AIza...      # https://aistudio.google.com/apikey (durable AIza key)
GEMINI_MODEL=gemini-2.5-flash
GROQ_API_KEY=gsk_...        # https://console.groq.com  (fallback)
```

### Tests
```bash
cd backend && PYTHONPATH=$PWD .venv/bin/python -m pytest -q
```
Endpoints are tested in-process with FastAPI's `TestClient` (no running server
needed).

---

## 🎬 3-Minute Demo Script
1. **Ingest** — drop a P&ID, a maintenance PDF, and a scanned form; the
   knowledge graph builds live and a causal chain begins forming.
2. **Query** — ask *"Why did Pump P-101 fail in August 2023?"* NEXUS traces
   **V-22 → cavitation → vibration → P-101 bearing → failure** across three
   documents, then predicts: *"P-101 failure probability in the next 3–5 weeks:
   **74 %**"* — from a recurring historical pattern.
3. **Decay & Capture** — a field tech opens restart procedure **SOP-P-101-M**:
   *"Confidence 41 % — last confirmed 14 months ago. STALE."* Then a retiring
   engineer's spoken insight becomes a permanent **TacitKnowledge** graph node.

---

## 🗂️ Repository Layout
```
lib/                 Flutter app
  theme/             design tokens + theme (1:1 with the design system)
  widgets/           reusable components (badges, prediction alert, waveform…)
  graph/             custom-painted knowledge graph + glowing causal path
  screens/           the 7 screens
  app/               shell, navigation, persona scope
  data/              demo dataset (mirrors the backend)
backend/             FastAPI AI engine (causal, decay, vision, LLM providers)
```
