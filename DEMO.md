# NEXUS — Demo Guide

**Causal-Temporal knowledge platform for industrial plants.** It turns P&IDs, maintenance
logs, SOPs and SME interviews into a knowledge graph that answers *root-cause* questions,
*predicts* recurring failures, flags *stale* knowledge, and *captures* tacit expertise by voice.

Demo plant: **Rashtriya Petrochemicals · Vadodara · Unit 3**. Hero story: Pump **P-101**'s
August-2023 bearing failure traced back to valve **V-22**.

---

## 📱 Install (teammate)

1. Copy **`nexus-demo.apk`** (~170 MB) to the phone.
2. Tap it → if prompted, allow **"Install unknown apps"** for your file manager → **Install**.
3. Open **NEXUS**. When you first tap the mic on **Capture**, tap **Allow** for the microphone.

**Works fully offline / on any phone** — every screen renders, on-device voice transcribes
locally, and the causal/P&ID answers show the curated demo content. No server or setup needed.

> **Optional — live AI answers:** the *Query* and *P&ID* "Ask" buttons go live against the
> Gemini-backed backend **only if it's reachable**. Without it they fall back to the polished
> built-in answers (no errors, no waiting). To run live, see *Live mode* at the bottom.

---

## 🎬 Demo script (~4–5 min)

It opens on **Query** — the hero screen. Move left→right along the bottom tabs.

### 1. Query — "It answers *why*, not just *what*"  ⭐ the money shot
- Question is pre-filled: *"Why did Pump P-101 fail in August 2023?"* → tap **Ask**.
- Read the answer: **V-22 held partially closed → starved suction → cavitation → vibration →
  P-101 bearing failure (14 Aug 2023)**.
- Point at the **causal chain** strip (V-22 → cavit. → vibr. → P-101 → FAIL) and the
  **3 cited sources** (P&ID + maintenance log + SME interview).
- Line: *"This isn't search — it's a reconstructed cause-and-effect chain, with its sources."*

### 2. P&ID — "It reads the engineering drawing"
- Tap the **P&ID** tab. Question pre-filled: *"Where is the pressure relief…?"* → tap **Ask**.
- It highlights **RV-103** on the schematic and explains its location *between T-04 and V-22,
  upstream of P-101*.
- Line: *"It's vision-native — it reads the actual P&ID, not a text dump of it."*

### 3. Decay — "It knows when knowledge goes stale"  ⭐ the differentiator
- Tap **Decay**. Show SOP **SOP-P-101-M**: **41% confidence**, **"STALE — verify before use"**,
  *decays ~4.2%/month, last confirmed 14 months ago*.
- Line: *"Every fact has a freshness half-life. NEXUS flags knowledge that's aged out before
  someone acts on it."*

### 4. Capture — "It captures the expert before they retire"  ⭐ on-device voice
- Tap **Capture**. NEXUS asks the SME a question. Tap the **mic** and **say a sentence**
  (e.g. *"You hear a gravelly rumble at the casing about ten seconds before the gauge moves."*).
- Watch the **live transcript** appear and a new **TacitKnowledge node** form, linked to P-101.
- Line: *"Speech-to-text runs **on-device** — works offline, on the plant floor, privately."*

### 5. Graph — "Everything is connected"
- Tap **Graph**. Show the knowledge graph, the lit **causal path**, and the **P-101** inspector
  (incoming vibration spike, outgoing bearing failure).

### 6. Stats — "The plant-manager view"
- Tap **Stats**. KPIs (downtime ↓22%, MTBF 412 d, compliance 81%, **3 open predictions**),
  the downtime-by-cause chart, and failure communities.
- Optional: tap **T · E · M** (top-right) to switch persona (Technician / Engineer / Manager).

### 7. Ingest — (optional opener) "How the brain is built"
- Tap **Ingest**. P&IDs, logs, SOPs and scanned forms stream in and grow the graph live.

**Closing line:** *"Causal + temporal + multimodal + on-device voice — the tribal knowledge of
a plant, captured, queryable, and honest about how fresh it is."*

---

## 🔌 Live mode (optional, for live Gemini answers)

The app defaults to `NEXUS_API=http://127.0.0.1:8077`. Two ways to make *Ask* go live:

- **USB (dev):** plug the phone in →
  `adb reverse tcp:8077 tcp:8077` → run the backend on the laptop:
  `cd backend && .venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8077`.
- **Same Wi-Fi:** rebuild with `--dart-define=NEXUS_API=http://<laptop-LAN-IP>:8077` and run
  the backend with `--host 0.0.0.0`.

The backend needs `GEMINI_API_KEY` (and optional `GROQ_API_KEY`) in the repo-root `.env`.
If the backend is down, every screen still works on the bundled demo data.

---

## ✅ Verified end-to-end (release APK, on device)
- All 7 screens render clean & navigable at phone width; 35 widget tests + analyzer pass.
- **Offline:** Ask falls back gracefully (no crash/hang); on-device voice records & transcribes.
- **Live:** Query → live Gemini causal answer; P&ID → live Gemini vision on the drawing.
