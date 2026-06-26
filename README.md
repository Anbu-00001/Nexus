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
    *Note: Supports Flutter Web, Android, iOS, and Desktop platforms.*
