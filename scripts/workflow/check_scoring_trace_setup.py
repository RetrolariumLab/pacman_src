#!/usr/bin/env python3
"""Check FCEUX Lua runtime and scoring hook addresses before capture."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


EXPECTED_HOOKS = {
    "power_pellet": "bra_handle_power_pellet_eaten",
    "pellet": "bra_handle_any_pellet_eaten",
    "actor_collision": "bra_dispatch_collision_type",
    "ghost_award": "bra_award_frightened_ghost",
    "fruit_award": "bra_spawn_fruit_and_score",
    "score_commit": "loc_add_points_and_update_score_buffers",
}
LABEL_RE = re.compile(r"^al [0-9A-Fa-f]{2}([0-9A-Fa-f]{4}) \.([A-Za-z0-9_]+)$")
HOOK_RE = re.compile(
    r'memory\.registerexecute\(0x([0-9A-Fa-f]{4}), function\(\) emit\("([a-z_]+)"\) end\)'
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fceux", required=True, type=Path)
    parser.add_argument("--labels", required=True, type=Path)
    parser.add_argument("--lua", required=True, type=Path)
    parser.add_argument("--trace", type=Path)
    args = parser.parse_args()

    failures: list[str] = []
    for path in (args.fceux, args.labels, args.lua):
        if not path.is_file():
            failures.append(f"missing required file: {path}")
    for dll in ("lua51.dll", "lua5.1.dll"):
        path = args.fceux.parent / dll
        if not path.is_file():
            failures.append(f"missing Lua runtime beside FCEUX: {path}")

    if not failures:
        labels: dict[str, int] = {}
        for line in args.labels.read_text(encoding="utf-8").splitlines():
            match = LABEL_RE.match(line)
            if match:
                labels[match.group(2)] = int(match.group(1), 16)
        hooks = {
            event: int(address, 16)
            for address, event in HOOK_RE.findall(args.lua.read_text(encoding="utf-8"))
        }
        for event, symbol in EXPECTED_HOOKS.items():
            if event not in hooks:
                failures.append(f"Lua hook is missing: {event}")
            elif symbol not in labels:
                failures.append(f"linker label is missing: {symbol}")
            elif hooks[event] != labels[symbol]:
                failures.append(
                    f"stale {event} hook: Lua=${hooks[event]:04X}, {symbol}=${labels[symbol]:04X}"
                )

    if args.trace is not None and (not args.trace.is_file() or args.trace.stat().st_size == 0):
        failures.append(f"trace was not created or is empty: {args.trace}")

    if failures:
        for failure in failures:
            print(f"[ERROR] {failure}")
        return 1
    print("[OK] Scoring trace setup and hook addresses are valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
