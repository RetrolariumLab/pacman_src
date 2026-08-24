#!/usr/bin/env python3
"""Validate runtime and static evidence for resolved reconstruction findings."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path


REQUIRED_COLUMNS = {
    "frame", "event", "address", "pc", "script", "value", "a", "x", "y", "detail",
}


def load_trace(
    path: Path, expected_scenario: str, expected_end_frame: int,
) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows or not REQUIRED_COLUMNS.issubset(rows[0]):
        raise ValueError(f"Trace is empty or uses an obsolete schema: {path}")
    if rows[0]["event"] != "trace_start" or rows[-1]["event"] != "trace_end":
        raise ValueError(f"Trace did not complete cleanly: {path}")
    if rows[0]["detail"] != expected_scenario or rows[-1]["detail"] != expected_scenario:
        raise ValueError(
            f"Trace scenario mismatch for {path}: expected {expected_scenario!r}"
        )
    try:
        start_frame = int(rows[0]["frame"])
        end_frame = int(rows[-1]["frame"])
    except ValueError as error:
        raise ValueError(f"Trace uses a nonnumeric frame boundary: {path}") from error
    if start_frame != 0 or end_frame != expected_end_frame:
        raise ValueError(
            f"Trace frame range mismatch for {path}: expected 0..{expected_end_frame}, "
            f"got {start_frame}..{end_frame}"
        )
    return rows


def matching(rows: list[dict[str, str]], **values: str) -> list[dict[str, str]]:
    return [row for row in rows if all(row[key] == value for key, value in values.items())]


def normalize_patch_address(value: str) -> str:
    return value.removeprefix("$").upper().zfill(4)


def validate_trace_provenance(
    scenarios: list[dict[str, object]], traces: dict[str, list[dict[str, str]]],
) -> None:
    scenario_ids = [str(scenario["id"]) for scenario in scenarios]
    if len(scenario_ids) != len(set(scenario_ids)):
        raise ValueError("Reconstruction evidence contains duplicate scenario IDs")
    if set(traces) != set(scenario_ids):
        raise ValueError("Loaded traces do not match the configured scenario set")

    for scenario in scenarios:
        scenario_id = str(scenario["id"])
        expected_addresses = {
            normalize_patch_address(str(address))
            for address in scenario.get("patches", [])
        }
        actual_addresses = {
            row["address"] for row in traces[scenario_id]
            if row["event"] == "controlled_patch"
        }
        if actual_addresses != expected_addresses:
            raise ValueError(
                f"Controlled patches for {scenario_id!r} do not match its manifest: "
                f"expected={sorted(expected_addresses)}, actual={sorted(actual_addresses)}"
            )

    pause_rows = traces.get("pause-probe")
    if pause_rows is None:
        raise ValueError("Required pause-probe reconstruction scenario is missing")
    patches = [row for row in pause_rows if row["event"] == "controlled_patch"]
    observed_controls = [
        (row["detail"], row["address"], row["script"]) for row in patches
    ]
    expected_controls = [
        ("pause_press", "004D", "04"),
        ("resume_press", "004D", "04"),
    ]
    if observed_controls != expected_controls:
        raise ValueError(
            "Pause probe must contain exactly one script-04 pause press and resume press"
        )
    press_frame, resume_frame = (int(row["frame"]) for row in patches)
    slot_0f_frames = [
        int(row["frame"]) for row in pause_rows
        if row["event"] == "sound_slot_active" and row["address"] == "060F"
    ]
    if not press_frame < resume_frame or not any(
        press_frame < frame < resume_frame for frame in slot_0f_frames
    ):
        raise ValueError(
            "Pause probe did not activate sound slot 0F between pause and resume"
        )


def sha1(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_static(rom: Path) -> dict[str, bool]:
    payload = rom.read_bytes()
    if len(payload) != 16 + 0x4000 + 0x2000:
        raise ValueError(f"Expected NROM-128 image, got {len(payload)} bytes")
    prg = payload[16:16 + 0x4000]
    notice = b"COPY RIGHT 1984 1980 NAMCO LTD. ALL RIGHTS RESERVED"
    return {
        "DATA-003 file-offset mapping": prg[0x05D3:0x05D5] == b"\xE7\xC5",
        "DATA-004 copyright payload": prg[:0x33] == notice,
        "DATA-004 reset vector bypasses notice": prg[-4:-2] == b"\x33\xC0",
    }


def validate_runtime(rows: list[dict[str, str]]) -> dict[str, bool]:
    scripts = {
        row["script"] for row in rows
        if row["detail"] == "RAM-002" and row["event"] in {"read", "write"}
    }
    active_slots = {
        int(row["address"], 16) - 0x0600
        for row in rows if row["event"] == "sound_slot_active"
    }
    gate_reads = matching(rows, event="read", address="00D2", pc="D16C")
    reversals = matching(rows, event="reversal_entry", address="00D2")
    return {
        "RAM-001 fruit collision array member": bool(
            matching(rows, event="read", address="00C0", pc="D224")
            and matching(rows, event="write", address="00C0", pc="CFEC", y="04")
        ),
        "RAM-002 script ownership coverage": {
            "00", "02", "04", "06", "08", "0A", "0C", "0E", "10"
        } <= scripts,
        "RAM-003 persistent latch and consumers": bool(
            matching(rows, event="write", address="00D2", pc="D1C4", a="01")
            and {row["value"] for row in gate_reads} >= {"00", "01"}
            and {row["value"] for row in reversals} >= {"00", "01"}
        ),
        "SND-001 all request slots active": active_slots == set(range(16)),
        "DATA-003 four sprite-strip selections": {
            row["value"] for row in rows if row["event"] == "attract_strip"
        } >= {"02", "06", "0A", "0E"},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True, type=Path)
    parser.add_argument("--trace-dir", required=True, type=Path)
    parser.add_argument("--rom", required=True, type=Path)
    args = parser.parse_args()

    document = json.loads(args.scenarios.read_text(encoding="utf-8"))
    actual_rom_sha1 = sha1(args.rom)
    if actual_rom_sha1 != document["rom_sha1"]:
        raise SystemExit(
            f"[FAIL] ROM SHA-1 mismatch: expected={document['rom_sha1']}, "
            f"actual={actual_rom_sha1}"
        )
    scenarios = document["scenarios"]
    traces: dict[str, list[dict[str, str]]] = {}
    try:
        for scenario in scenarios:
            scenario_id = scenario["id"]
            traces[scenario_id] = load_trace(
                args.trace_dir / f"{scenario_id}.csv",
                scenario_id,
                scenario["max_frames"],
            )
        validate_trace_provenance(scenarios, traces)
    except (OSError, TypeError, ValueError) as error:
        print(f"[FAIL] Invalid reconstruction evidence: {error}")
        return 1
    print(f"[OK] Trace provenance: {len(traces)} scenarios with declared controls.")
    rows = [row for scenario_rows in traces.values() for row in scenario_rows]

    checks = validate_static(args.rom) | validate_runtime(rows)
    for name, passed in checks.items():
        print(f"[{'OK' if passed else 'ERROR'}] {name}")
    failures = [name for name, passed in checks.items() if not passed]
    if failures:
        print(f"[FAIL] Reconstruction evidence checks failed: {', '.join(failures)}")
        return 1
    print(f"[OK] All {len(checks)} reconstruction evidence checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
