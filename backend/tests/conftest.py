"""Shared fixtures / helpers for the NEXUS backend test-suite.

Design notes
------------
* All endpoint tests run **in-process** via ``fastapi.testclient.TestClient``;
  the sandbox kills long-running servers, so we never start uvicorn.
* No ``pytest-asyncio`` is installed, so async coroutines are driven with a tiny
  ``run_async`` helper (``asyncio.run``) instead of a plugin marker.
* Live LLM calls are *opt-in* and capped. A test is "live" only when the
  ``RUN_LIVE`` env var is truthy; otherwise the network layer is monkeypatched.
  This keeps the default ``pytest`` run at **zero** quota burn.
"""
import asyncio
import os
import struct
import zlib

import pytest

from app.main import app


def run_async(coro):
    """Drive a coroutine to completion without a pytest async plugin."""
    return asyncio.run(coro)


# Truthy => the two genuinely-live LLM tests are allowed to hit the network.
LIVE = os.getenv("RUN_LIVE", "").lower() in ("1", "true", "yes", "on")
live_only = pytest.mark.skipif(
    not LIVE,
    reason="live LLM test; set RUN_LIVE=1 to enable (burns free-tier quota)",
)


@pytest.fixture
def client():
    """In-process FastAPI test client (no network server is started)."""
    with __import__("fastapi.testclient", fromlist=["TestClient"]).TestClient(app) as c:
        yield c


def tiny_png() -> bytes:
    """Return the bytes of a valid 1x1 RGB PNG, built inline (no Pillow dep)."""
    sig = b"\x89PNG\r\n\x1a\n"

    def chunk(tag: bytes, body: bytes) -> bytes:
        return (
            struct.pack(">I", len(body))
            + tag
            + body
            + struct.pack(">I", zlib.crc32(tag + body) & 0xFFFFFFFF)
        )

    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0)  # 1x1, 8-bit, RGB
    idat = zlib.compress(b"\x00\xff\x00\x00")            # one red pixel
    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")
