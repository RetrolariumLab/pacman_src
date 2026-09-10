#!/usr/bin/env python3
"""Load a bank listing, recursively expanding local ``.include`` files."""

from __future__ import annotations

import re
from pathlib import Path


INCLUDE_RE = re.compile(r'^\s*\.include\s+"([^"]+)"\s*(?:;.*)?$', re.IGNORECASE)


def read_listing_lines(path: Path) -> list[str]:
    """Return a logical listing assembled from *path* and its local includes.

    Includes which do not exist are retained as ordinary source directives.
    This keeps the flattener usable with optional or externally supplied ca65
    include paths.
    """

    root = path.resolve()

    def expand(current: Path, stack: tuple[Path, ...]) -> list[str]:
        resolved = current.resolve()
        if resolved in stack:
            chain = " -> ".join(str(item) for item in (*stack, resolved))
            raise ValueError(f"Listing include cycle: {chain}")

        lines = current.read_text(encoding="utf-8").splitlines()
        output: list[str] = []
        for line in lines:
            match = INCLUDE_RE.match(line)
            if match is None:
                output.append(line)
                continue

            relative = Path(match.group(1))
            candidates = (current.parent / relative, root.parent / relative)
            include_path = next((item for item in candidates if item.is_file()), None)
            if include_path is not None:
                output.extend(expand(include_path, (*stack, resolved)))
            else:
                output.append(line)
        return output

    return expand(root, ())


def read_listing_text(path: Path) -> str:
    lines = read_listing_lines(path)
    return "\n".join(lines) + ("\n" if lines else "")
