from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from validate_reconstruction_evidence import validate_runtime  # noqa: E402


def row(event: str, address: str = "0000", **values: str) -> dict[str, str]:
    result = {
        "event": event, "address": address, "pc": "0000", "script": "00",
        "value": "00", "a": "00", "x": "00", "y": "00", "detail": "",
    }
    result.update(values)
    return result


def complete_rows() -> list[dict[str, str]]:
    rows = [
        row("read", "00C0", pc="D224"),
        row("write", "00C0", pc="CFEC", y="04"),
        row("write", "00D2", pc="D1C4", a="01"),
        row("read", "00D2", pc="D16C", value="00"),
        row("read", "00D2", pc="D16C", value="01"),
        row("reversal_entry", "00D2", value="00"),
        row("reversal_entry", "00D2", value="01"),
    ]
    rows.extend(
        row("read", "0087", script=script, detail="RAM-002")
        for script in ("00", "02", "04", "06", "08", "0A", "0C", "0E", "10")
    )
    rows.extend(
        row("sound_slot_active", f"{0x0600 + slot:04X}") for slot in range(16)
    )
    rows.extend(
        row("attract_strip", "C688", value=value)
        for value in ("02", "06", "0A", "0E")
    )
    return rows


class ReconstructionEvidenceTests(unittest.TestCase):
    def test_complete_evidence_passes_every_runtime_check(self) -> None:
        self.assertTrue(all(validate_runtime(complete_rows()).values()))

    def test_missing_sound_slot_is_rejected(self) -> None:
        rows = [
            item for item in complete_rows()
            if not (item["event"] == "sound_slot_active" and item["address"] == "060F")
        ]
        self.assertFalse(validate_runtime(rows)["SND-001 all request slots active"])

    def test_release_latch_requires_both_consumer_states(self) -> None:
        rows = [
            item for item in complete_rows()
            if not (item["event"] == "reversal_entry" and item["value"] == "01")
        ]
        self.assertFalse(validate_runtime(rows)["RAM-003 persistent latch and consumers"])


if __name__ == "__main__":
    unittest.main()
