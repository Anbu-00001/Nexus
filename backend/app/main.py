"""NEXUS API — Causal-Temporal industrial knowledge engine."""
from fastapi import FastAPI, File, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from . import causal, data
from .decay import decayed_confidence
from .llm import providers_status, vision

app = FastAPI(title="NEXUS API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class QueryIn(BaseModel):
    question: str = "Why did Pump P-101 fail in August 2023?"


@app.get("/health")
async def health():
    return {"status": "ok", "plant": data.PLANT, "providers": providers_status()}


@app.post("/query")
async def query(q: QueryIn):
    """Causal chain + failure prediction, narrated by the LLM."""
    return await causal.explain(q.question)


@app.get("/assertion/{assertion_id}")
async def assertion(assertion_id: str):
    """Temporal-decay confidence for a knowledge assertion."""
    a = data.ASSERTIONS.get(assertion_id)
    if not a:
        return {"error": "unknown assertion", "id": assertion_id}
    d = decayed_confidence(a["initial_confidence"], a["domain"],
                           a["last_confirmed"], data.DEMO_NOW)
    return {"id": assertion_id, "title": a["title"], "body": a["body"], **d}


@app.post("/vision/pid")
async def pid_vision(question: str = Form(...), image: UploadFile = File(...)):
    """Vision-native P&ID Q&A — locate a component on an engineering drawing."""
    img = await image.read()
    # Coerce to a real image mime; some clients upload as octet-stream.
    ctype = image.content_type or ""
    mime = ctype if ctype.startswith("image/") else "image/png"
    prompt = (
        "You are reading a P&ID engineering drawing. Answer the question by "
        "naming the relevant tag/component and where it sits relative to other "
        f"components. Be concise.\n\nQuestion: {question}"
    )
    try:
        answer = await vision(prompt, img, mime)
        return {"answer": answer, "ok": True}
    except Exception as e:
        return {"answer": f"Vision unavailable ({type(e).__name__}).", "ok": False}


@app.get("/graph")
async def graph():
    """Reconstructed causal-chain summary for the graph view."""
    return causal.reconstruct()
