"""Greeting helpers for the Octopus Day 2 package."""

from __future__ import annotations

from typing import Final

DEFAULT_GREETING: Final[str] = "Hello from Octopus Day 2"


def welcome(name: str | None = None) -> str:
    """Return a friendly greeting for the supplied name.

    Args:
        name: Optional recipient name. A blank or missing value resolves to
            "World".

    Returns:
        A greeting string.
    """
    target = (name or "World").strip() or "World"
    return f"{DEFAULT_GREETING}, {target}!"
