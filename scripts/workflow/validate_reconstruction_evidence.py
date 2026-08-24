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


def load_trace(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows or not REQUIRED_COLUMNS.issubset(rows[0]):
        raise ValueError(f"Trace is empty or uses an obsolete schema: {path}")
    if rows[0]["event"] != "trace_start" or rows[-1]["event"] != "trace_end":
        raise ValueError(f"Trace did not complete cleanly: {path}")
    return rows


def matching(rows: list[dict[str, str]], **values: str) -> list[dict[str, str]]:
    return [row for row in rows if all(row[key] == value for key, value in values.items())]


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
    rows: list[dict[str, str]] = []
    for scenario in document["scenarios"]:
        rows.extend(load_trace(args.trace_dir / f"{scenario['id']}.csv"))

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
