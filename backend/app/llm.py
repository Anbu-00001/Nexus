"""Provider-agnostic LLM + vision access.

Reads keys from the repo-root .env. Primary provider is configurable; on a
Gemini failure (e.g. free-tier quota) it transparently falls back to Groq for
text so the demo never hard-stops.
"""
import base64
import os

import httpx
from dotenv import load_dotenv

# .env lives at the repo root (one level above backend/).
load_dotenv(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

PROVIDER = os.getenv("LLM_PROVIDER", "gemini").lower()
GEMINI_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
GROQ_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")

_GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
_GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"


def providers_status() -> dict:
    return {
        "primary": PROVIDER,
        "gemini": bool(GEMINI_KEY),
        "gemini_model": GEMINI_MODEL,
        "groq": bool(GROQ_KEY),
        "groq_model": GROQ_MODEL,
    }


async def complete(prompt: str, system: str = "") -> str:
    order = [PROVIDER] + [p for p in ("gemini", "groq") if p != PROVIDER]
    last_err: Exception | None = None
    for prov in order:
        try:
            if prov == "gemini" and GEMINI_KEY:
                return await _gemini_text(prompt, system)
            if prov == "groq" and GROQ_KEY:
                return await _groq_text(prompt, system)
        except Exception as e:  # try the next provider
            last_err = e
    raise RuntimeError(f"No LLM provider succeeded: {last_err}")


async def vision(prompt: str, image_bytes: bytes, mime: str = "image/png") -> str:
    """Multimodal P&ID Q&A — Gemini only (Groq has no vision)."""
    if not GEMINI_KEY:
        raise RuntimeError("Vision requires a Gemini key")
    b64 = base64.b64encode(image_bytes).decode()
    body = {"contents": [{"parts": [
        {"text": prompt},
        {"inline_data": {"mime_type": mime, "data": b64}},
    ]}]}
    return await _gemini_call(body)


# ── provider implementations ─────────────────────────────────────────────
async def _gemini_text(prompt: str, system: str) -> str:
    text = f"{system}\n\n{prompt}" if system else prompt
    return await _gemini_call({"contents": [{"parts": [{"text": text}]}]})


async def _gemini_call(body: dict) -> str:
    url = _GEMINI_URL.format(model=GEMINI_MODEL, key=GEMINI_KEY)
    async with httpx.AsyncClient(timeout=60) as c:
        r = await c.post(url, json=body)
        r.raise_for_status()
        data = r.json()
        return data["candidates"][0]["content"]["parts"][0]["text"]


async def _groq_text(prompt: str, system: str) -> str:
    msgs = ([{"role": "system", "content": system}] if system else []) + \
        [{"role": "user", "content": prompt}]
    async with httpx.AsyncClient(timeout=60) as c:
        r = await c.post(_GROQ_URL,
                         headers={"Authorization": f"Bearer {GROQ_KEY}"},
                         json={"model": GROQ_MODEL, "messages": msgs,
                               "temperature": 0.3})
        r.raise_for_status()
        return r.json()["choices"][0]["message"]["content"]
