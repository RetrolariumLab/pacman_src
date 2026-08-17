#!/usr/bin/env python3
"""Validate milestone-7 semantic events and controlled-patch boundaries."""

from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path


PATCH_RE = re.compile(r"^([0-9A-F]{4}):[0-9A-F]{2}>[0-9A-F]{2}:[a-z0-9_]+$")
REQUIRED_COLUMNS = {
    "frame", "event", "detail", "script", "player", "lives_p1", "lives_p2",
    "stage", "scene", "substate", "ghost_states", "phase", "pause",
}


def has_ordered_details(rows: list[dict[str, str]], event: str, details: list[str]) -> bool:
    position = 0
    for row in rows:
        if row["event"] == event and row["detail"] == details[position]:
            position += 1
            if position == len(details):
                return True
    return False


def check_death_respawn(rows: list[dict[str, str]]) -> bool:
    return has_ordered_details(rows, "script_changed", ["04>08", "08>00", "00>02"])


def split_ghosts(value: str) -> list[str]:
    return [value[index:index + 2] for index in range(0, 8, 2)]


def check_ghost_releases(rows: list[dict[str, str]]) -> bool:
    transitions: list[tuple[list[str], list[str]]] = []
    for row in rows:
        if row["event"] != "ghost_states_changed" or ">" not in row["detail"]:
            continue
        before, after = row["detail"].split(">", 1)
        transitions.append((split_ghosts(before), split_ghosts(after)))
    for slot in range(1, 4):
        queued = any(before[slot] == "00" and after[slot] == "02" for before, after in transitions)
        active = any(before[slot] == "02" and after[slot] == "04" for before, after in transitions)
        if not queued or not active:
            return False
    return True


def check_mode_boundaries(rows: list[dict[str, str]]) -> bool:
    phases = {row["detail"] for row in rows if row["event"] == "mode_phase_changed"}
    reversals = [row for row in rows if row["event"] == "ghost_reversal"]
    return {"00>01", "01>02", "02>03"} <= phases and len(reversals) >= 2


def check_intermission(rows: list[dict[str, str]], scene: str, substates: set[str]) -> bool:
    observed = {
        row["substate"] for row in rows
        if row["event"] == "intermission_state_changed" and row["scene"] == scene
    }
    entered = any(row["event"] == "script_changed" and row["detail"] == "0E>10" for row in rows)
    exited = any(row["event"] == "script_changed" and row["detail"] == "10>00" for row in rows)
    return entered and exited and substates <= observed


def check_sound_classes(rows: list[dict[str, str]]) -> bool:
    events = {row["event"] for row in rows}
    controls = {row["detail"].split(":")[-1] for row in rows if row["event"] == "sound_control"}
    return {"sound_note", "sound_duration", "sound_control"} <= events and {"F0", "F5"} <= controls


def check_pause_resume(rows: list[dict[str, str]]) -> bool:
    changes = [row["detail"] for row in rows if row["event"] == "pause_changed"]
    return changes == ["00>01", "01>02"]


def check_player_switch(rows: list[dict[str, str]]) -> bool:
    return (
        has_ordered_details(rows, "script_changed", ["06>08", "08>00", "00>02"])
        and any(row["event"] == "player_changed" and row["detail"] == "00>01" for row in rows)
    )


def load_trace(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows or not REQUIRED_COLUMNS.issubset(rows[0]):
        raise ValueError(f"Trace is empty or uses an obsolete schema: {path}")
    if rows[0]["event"] != "trace_start" or rows[-1]["event"] != "trace_end":
        raise ValueError(f"Trace did not complete cleanly: {path}")
    return rows


def validate_patch_scope(scenario: dict[str, object], rows: list[dict[str, str]]) -> None:
    declared = {
        str(patch["address"])[1:].upper()
        for patch in scenario.get("patches", [])  # type: ignore[union-attr]
    }
    observed: set[str] = set()
    for row in rows:
        if row["event"] != "controlled_patch":
            continue
        match = PATCH_RE.fullmatch(row["detail"])
        if not match:
            raise ValueError(f"Malformed controlled patch: {row['detail']}")
        observed.add(match.group(1))
    if observed != declared:
        raise ValueError(
            f"Controlled patch scope differs for {scenario['id']}: "
            f"declared={sorted(declared)}, observed={sorted(observed)}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True, type=Path)
    parser.add_argument("--trace-dir", required=True, type=Path)
    args = parser.parse_args()

    document = json.loads(args.scenarios.read_text(encoding="utf-8"))
    all_checks: dict[str, bool] = {}
    for scenario in document["scenarios"]:
        rows = load_trace(args.trace_dir / f"{scenario['id']}.csv")
        validate_patch_scope(scenario, rows)
        checks = {
            "death-respawn": lambda: check_death_respawn(rows),
            "ghost-releases": lambda: check_ghost_releases(rows),
            "mode-boundaries": lambda: check_mode_boundaries(rows),
            "intermission-scene-0": lambda: check_intermission(rows, "00", {"00", "02", "04", "06"}),
            "intermission-scene-1": lambda: check_intermission(rows, "02", {"00", "02", "04"}),
            "intermission-scene-2": lambda: check_intermission(rows, "04", {"00", "02", "04", "06"}),
            "sound-byte-classes": lambda: check_sound_classes(rows),
            "pause-resume": lambda: check_pause_resume(rows),
            "death-player-switch": lambda: check_player_switch(rows),
        }
        for check_id in scenario["checks"]:
            if check_id not in checks:
                raise ValueError(f"Unknown runtime check: {check_id}")
            passed = checks[check_id]()
            all_checks[check_id] = passed
            print(f"[{'OK' if passed else 'ERROR'}] {check_id}: {scenario['method']}")

    failures = [check_id for check_id, passed in all_checks.items() if not passed]
    if failures:
        print(f"[FAIL] Runtime trace checks failed: {', '.join(failures)}")
        return 1
    print(f"[OK] All {len(all_checks)} focused runtime checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
