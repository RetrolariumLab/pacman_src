#!/usr/bin/env python3
"""Materialize the canonical CRLF representation of an FM2 movie."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import tempfile
from pathlib import Path


def canonical_movie_bytes(data: bytes) -> bytes:
    """Return FM2 text with every line terminated consistently by CRLF."""
    normalized = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return normalized.replace(b"\n", b"\r\n")


def canonical_movie_sha1(data: bytes) -> str:
    """Hash the canonical FM2 serialization, independent of checkout EOLs."""
    return hashlib.sha1(canonical_movie_bytes(data)).hexdigest()


def materialize_canonical_movie(
    source: Path, output: Path, expected_sha1: str | None = None,
) -> Path:
    """Validate and atomically write a canonical FM2 copy."""
    data = canonical_movie_bytes(source.read_bytes())
    actual = hashlib.sha1(data).hexdigest()
    if expected_sha1 is not None and actual != expected_sha1:
        raise ValueError(
            f"canonical movie SHA-1 mismatch for {source}: "
            f"expected={expected_sha1}, actual={actual}"
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=output.parent, delete=False) as stream:
        temporary = Path(stream.name)
        stream.write(data)
    try:
        os.replace(temporary, output)
    finally:
        temporary.unlink(missing_ok=True)
    return output


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--movie", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args(argv)
    try:
        document = json.loads(args.manifest.read_text(encoding="utf-8"))
        expected = document["movie_sha1"]
        if not isinstance(expected, str) or len(expected) != 40:
            raise ValueError("scenario manifest movie_sha1 must be a SHA-1 string")
        output = materialize_canonical_movie(args.movie, args.output, expected)
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f"[FAIL] {error}")
        return 1
    print(f"[OK] Canonical FM2 movie: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
