from __future__ import annotations

import csv
import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from validate_reconstruction_evidence import (  # noqa: E402
    load_trace,
    validate_runtime,
    validate_trace_provenance,
)


ORIGINAL_LABELS = {
    "sub_check_actor_collisions": 0xD20F,
    "bra_normalize_power_pellet_tiles": 0xCFD9,
    "bra_use_personal_release_latch": 0xD16A,
    "bra_check_personal_release_targets": 0xD1B2,
}


def row(event: str, address: str = "0000", **values: str) -> dict[str, str]:
    result = {
        "frame": "0", "event": event, "address": address, "pc": "0000", "script": "00",
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


def complete_traces() -> tuple[list[dict[str, object]], dict[str, list[dict[str, str]]]]:
    scenarios: list[dict[str, object]] = [
        {"id": "natural-longplay", "max_frames": 120000},
        {"id": "pause-probe", "max_frames": 23000, "patches": ["$004D"]},
    ]
    natural = [
        row("trace_start", detail="natural-longplay"),
        row("trace_end", detail="natural-longplay", frame="120000"),
    ]
    pause = [
        row("trace_start", detail="pause-probe"),
        row("controlled_patch", "004D", frame="22000", script="04", detail="pause_press"),
        row("sound_slot_active", "060F", frame="22001", script="04", detail="slot_0F"),
        row("controlled_patch", "004D", frame="22036", script="04", detail="resume_press"),
        row("trace_end", detail="pause-probe", frame="23000"),
    ]
    return scenarios, {"natural-longplay": natural, "pause-probe": pause}


class ReconstructionEvidenceTests(unittest.TestCase):
    def test_complete_trace_provenance_is_accepted(self) -> None:
        scenarios, traces = complete_traces()
        validate_trace_provenance(scenarios, traces)

    def test_trace_file_must_identify_its_scenario(self) -> None:
        fields = ["frame", "event", "address", "pc", "script", "value", "a", "x", "y", "detail"]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "pause-probe.csv"
            with path.open("w", encoding="utf-8", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=fields)
                writer.writeheader()
                writer.writerows([
                    row("trace_start", detail="natural-longplay"),
                    row("trace_end", detail="natural-longplay", frame="23000"),
                ])
            with self.assertRaisesRegex(ValueError, "scenario mismatch"):
                load_trace(path, "pause-probe", 23000)

    def test_pause_probe_requires_complete_control_sequence(self) -> None:
        scenarios, traces = complete_traces()
        traces["pause-probe"] = [
            item for item in traces["pause-probe"] if item["detail"] != "resume_press"
        ]
        with self.assertRaisesRegex(ValueError, "pause press and resume press"):
            validate_trace_provenance(scenarios, traces)

    def test_undeclared_control_patch_is_rejected(self) -> None:
        scenarios, traces = complete_traces()
        traces["natural-longplay"].insert(
            1, row("controlled_patch", "004D", frame="100", detail="unexpected")
        )
        with self.assertRaisesRegex(ValueError, "do not match its manifest"):
            validate_trace_provenance(scenarios, traces)

    def test_complete_evidence_passes_every_runtime_check(self) -> None:
        self.assertTrue(all(validate_runtime(complete_rows(), ORIGINAL_LABELS).values()))

    def test_missing_sound_slot_is_rejected(self) -> None:
        rows = [
            item for item in complete_rows()
            if not (item["event"] == "sound_slot_active" and item["address"] == "060F")
        ]
        self.assertFalse(
            validate_runtime(rows, ORIGINAL_LABELS)["SND-001 all request slots active"]
        )

    def test_release_latch_requires_both_consumer_states(self) -> None:
        rows = [
            item for item in complete_rows()
            if not (item["event"] == "reversal_entry" and item["value"] == "01")
        ]
        self.assertFalse(
            validate_runtime(rows, ORIGINAL_LABELS)[
                "RAM-003 persistent latch and consumers"
            ]
        )

    def test_runtime_checks_follow_relocated_label_anchors(self) -> None:
        relocated = {name: address + 9 for name, address in ORIGINAL_LABELS.items()}
        shifted_rows = [dict(item) for item in complete_rows()]
        for item in shifted_rows:
            if item["pc"] in {"D224", "CFEC", "D16C", "D1C4"}:
                item["pc"] = f"{int(item['pc'], 16) + 9:04X}"
        self.assertTrue(all(validate_runtime(shifted_rows, relocated).values()))


if __name__ == "__main__":
    unittest.main()
