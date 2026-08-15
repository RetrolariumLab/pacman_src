#!/usr/bin/env python3
"""Validate semantic scoring transactions in a compact FCEUX trace."""

from __future__ import annotations

import argparse
import csv
import json
from collections import defaultdict
from pathlib import Path


GHOST_AWARDS = ["000200000000", "000400000000", "000800000000", "000601000000"]
FRUIT_AWARDS = [
    "000100000000",
    "000300000000",
    "000500000000",
    "000700000000",
    "000001000000",
    "000002000000",
    "000003000000",
    "000005000000",
]


def events(rows: list[dict[str, str]]) -> list[str]:
    return [row["event"] for row in rows]


def commit_with(rows: list[dict[str, str]], pending: str) -> bool:
    return any(row["event"] == "score_commit" and row["pending_bcd"] == pending for row in rows)


def validate_normal_pellet(frames: list[list[dict[str, str]]]) -> bool:
    return any(
        "pellet" in events(rows)
        and "power_pellet" not in events(rows)
        and "score_changed" in events(rows)
        and commit_with(rows, "010000000000")
        for rows in frames
    )


def validate_power_pellet(frames: list[list[dict[str, str]]]) -> bool:
    return any(
        events(rows)[:2] == ["power_pellet", "pellet"]
        and "score_changed" in events(rows)
        and commit_with(rows, "050000000000")
        and any(int(row["frightened_mask"], 16) != 0 for row in rows)
        for rows in frames
    )


def validate_ghost_chain(frames: list[list[dict[str, str]]]) -> bool:
    position = 0
    for rows in frames:
        if "power_pellet" in events(rows):
            position = 0
        awards = [row for row in rows if row["event"] == "ghost_award"]
        if not awards:
            continue
        expected_count = f"{position:02X}"
        if awards[0]["kill_count"] == expected_count and commit_with(rows, GHOST_AWARDS[position]):
            position += 1
            if position == 4:
                return True
        else:
            position = 0
    return False


def validate_fruit(frames: list[list[dict[str, str]]]) -> bool:
    for rows in frames:
        if "fruit_award" not in events(rows) or "score_changed" not in events(rows):
            continue
        award = next(row for row in rows if row["event"] == "fruit_award")
        stage = int(award["stage_index"], 16)
        if stage < len(FRUIT_AWARDS) and commit_with(rows, FRUIT_AWARDS[stage]):
            return any(
                row["event"] == "score_changed" and row["fruit_eaten_latch"] == "80"
                for row in rows
            )
    return False


def validate_extra_life(frames: list[list[dict[str, str]]]) -> bool:
    for rows in frames:
        by_event = {row["event"]: row for row in rows}
        required = {"score_commit", "score_changed", "lives_changed", "extra_life_awarded"}
        if not required.issubset(by_event):
            continue
        before = by_event["score_commit"]
        after = by_event["extra_life_awarded"]
        if (
            before["extra_life_latch"] == "00"
            and after["extra_life_latch"] == "01"
            and int(after["lives"], 16) == int(before["lives"], 16) + 1
            and after["score_bcd"][6:8] == "01"
        ):
            return True
    return False


def validate_hiscore(frames: list[list[dict[str, str]]]) -> bool:
    return any(
        "score_commit" in events(rows)
        and any(
            row["event"] == "hiscore_changed" and row["score_bcd"] == row["hiscore_bcd"]
            for row in rows
        )
        for rows in frames
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scenarios", required=True, type=Path)
    parser.add_argument("--trace", required=True, type=Path)
    args = parser.parse_args()

    document = json.loads(args.scenarios.read_text(encoding="utf-8"))
    with args.trace.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))

    required_columns = {
        "frame", "event", "pending_bcd", "score_bcd", "hiscore_bcd", "lives",
        "extra_life_latch", "pellets", "frightened_mask", "kill_count",
        "fruit_eaten_latch", "stage_index",
    }
    if not rows or not required_columns.issubset(rows[0]):
        print("[FAIL] Trace is empty or uses an obsolete CSV schema.")
        return 1

    grouped: dict[int, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[int(row["frame"])].append(row)
    frames = [grouped[frame] for frame in sorted(grouped)]

    checks = {
        "normal-pellet": validate_normal_pellet(frames),
        "power-pellet": validate_power_pellet(frames),
        "four-ghost-chain": validate_ghost_chain(frames),
        "fruit-award": validate_fruit(frames),
        "extra-life-threshold": validate_extra_life(frames),
        "high-score-promotion": validate_hiscore(frames),
    }
    configured = {scenario["id"] for scenario in document["scenarios"]}
    if configured != set(checks):
        print("[FAIL] Scenario IDs and semantic checks are out of sync.")
        return 1

    failures = [scenario_id for scenario_id, passed in checks.items() if not passed]
    for scenario_id, passed in checks.items():
        print(f"[{'OK' if passed else 'ERROR'}] {scenario_id}: semantic invariants")
    if failures:
        print(f"[FAIL] {len(failures)} scoring scenario(s) failed semantic validation.")
        return 1
    print(f"[OK] All {len(checks)} scoring scenarios passed semantic validation.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
