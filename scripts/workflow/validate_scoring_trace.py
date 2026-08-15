#!/usr/bin/env python3
"""Validate semantic event sequences in a compact scoring trace."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path


def is_subsequence(expected: list[str], actual: list[str]) -> bool:
    position = 0
    for event in actual:
        if position < len(expected) and event == expected[position]:
            position += 1
    return position == len(expected)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scenarios", required=True, type=Path)
    parser.add_argument("--trace", required=True, type=Path)
    args = parser.parse_args()

    document = json.loads(args.scenarios.read_text(encoding="utf-8"))
    with args.trace.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))

    events = [row["event"] for row in rows]
    failures: list[str] = []
    for scenario in document["scenarios"]:
        expected = scenario["expected_events"]
        if is_subsequence(expected, events):
            print(f"[OK] {scenario['id']}: {' -> '.join(expected)}")
        else:
            failures.append(scenario["id"])
            print(f"[ERROR] {scenario['id']}: missing sequence {' -> '.join(expected)}")

    if failures:
        print(f"[FAIL] {len(failures)} scoring scenario(s) not observed.")
        return 1
    print(f"[OK] All {len(document['scenarios'])} scoring scenarios observed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
