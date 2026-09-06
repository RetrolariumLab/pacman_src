from __future__ import annotations

import csv
import json
import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts" / "workflow"))

from relocation_test import (  # noqa: E402
    prepare_scenario,
    prepare_source,
    validate_runtime,
)


TRACE_FIELDS = [
    "frame", "event", "detail", "script", "player", "lives_p1",
    "lives_p2", "stage", "scene", "substate", "ghost_states", "phase",
    "pause",
]


class RelocationTests(unittest.TestCase):
    def test_prepare_source_inserts_progressive_nonexecuted_ea_anchors(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "src"
            (source / "data").mkdir(parents=True)
            (source / "memory.inc").write_text("VALUE = $01\n", encoding="utf-8")
            (source / "first.asm").write_text(
                '.segment "BANK_FF"\n.org $C000\ntbl_first:\n    .byte $00\n',
                encoding="utf-8",
            )
            (source / "second.asm").write_text(
                "tbl_second:\n    .byte $01\n",
                encoding="utf-8",
            )
            (source / "data" / "tail_and_vectors.asm").write_text(
                "unused_tail:\n    .res $FFF8 - *, $FF\n",
                encoding="utf-8",
            )
            main = source / "main.asm"
            main.write_text(
                '.include "memory.inc"\n'
                '.include "first.asm"\n'
                '.include "second.asm"\n'
                '.include "data/tail_and_vectors.asm"\n',
                encoding="utf-8",
            )
            output = root / "build" / "generated" / "main.asm"
            manifest_path = root / "build" / "layout.json"

            manifest = prepare_source(main, output, manifest_path)

            self.assertEqual(manifest["anchor_count"], 2)
            self.assertEqual(
                [item["expected_shift"] for item in manifest["modules"]],
                [1, 2],
            )
            generated_boot = output.parent / "boot_and_frame.asm"
            self.assertIn(".org $C000\n    .byte $EA\n", generated_boot.read_text())
            self.assertEqual(output.read_text().count("    .byte $EA\n"), 1)

    def test_prepare_scenario_keeps_controlled_checks(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            base = root / "base.json"
            rom = root / "candidate.nes"
            output = root / "candidate.json"
            rom.write_bytes(b"candidate")
            base.write_text(
                json.dumps(
                    {
                        "format": 1,
                        "rom_sha1": "old",
                        "movie": "movie.fm2",
                        "movie_sha1": "movie",
                        "scenarios": [
                            {"id": "natural-longplay", "max_frames": 10},
                            {"id": "pause-resume", "max_frames": 20},
                        ],
                    }
                ),
                encoding="utf-8",
            )

            prepare_scenario(base, rom, output, 120_000, 5_000)
            document = json.loads(output.read_text(encoding="utf-8"))

            self.assertEqual(len(document["scenarios"]), 2)
            self.assertEqual(document["scenarios"][0]["max_frames"], 120_000)
            self.assertEqual(document["scenarios"][0]["heartbeat_interval"], 5_000)
            self.assertEqual(document["scenarios"][1]["max_frames"], 20)

    def test_runtime_requires_round_progress_and_live_heartbeats(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            trace = Path(directory) / "trace.csv"
            rows = [
                self.row(0, "trace_start"),
                self.row(0, "heartbeat", "frame_counter=00"),
                self.row(1, "stage_changed", "00>01"),
                self.row(2, "stage_changed", "01>02"),
                self.row(3, "stage_changed", "02>03"),
                self.row(5, "heartbeat", "frame_counter=01"),
                self.row(10, "heartbeat", "frame_counter=02"),
                self.row(15, "heartbeat", "frame_counter=03"),
                self.row(19, "ghost_reversal"),
                self.row(20, "heartbeat", "frame_counter=04"),
                self.row(20, "trace_end"),
            ]
            with trace.open("w", encoding="utf-8", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=TRACE_FIELDS)
                writer.writeheader()
                writer.writerows(rows)

            validate_runtime(trace, 20, 5)

    def test_runtime_rejects_an_executed_probe_in_any_scenario(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            trace = root / "natural-longplay.csv"
            other = root / "pause-resume.csv"
            rows = [
                self.row(0, "trace_start"),
                self.row(0, "heartbeat", "frame_counter=00"),
                self.row(1, "stage_changed", "00>01"),
                self.row(2, "stage_changed", "01>02"),
                self.row(3, "stage_changed", "02>03"),
                self.row(5, "heartbeat", "frame_counter=01"),
                self.row(10, "heartbeat", "frame_counter=02"),
                self.row(15, "heartbeat", "frame_counter=03"),
                self.row(19, "ghost_reversal"),
                self.row(20, "heartbeat", "frame_counter=04"),
                self.row(20, "trace_end"),
            ]
            self.write_trace(trace, rows)
            self.write_trace(
                other,
                [
                    self.row(0, "trace_start"),
                    self.row(7, "relocation_probe_executed", "C123"),
                    self.row(10, "trace_end"),
                ],
            )

            with self.assertRaisesRegex(ValueError, "probe executed.*pause-resume"):
                validate_runtime(trace, 20, 5, root)

    @staticmethod
    def write_trace(path: Path, rows: list[dict[str, str]]) -> None:
        with path.open("w", encoding="utf-8", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=TRACE_FIELDS)
            writer.writeheader()
            writer.writerows(rows)

    @staticmethod
    def row(frame: int, event: str, detail: str = "") -> dict[str, str]:
        return {
            "frame": str(frame), "event": event, "detail": detail,
            "script": "04", "player": "00", "lives_p1": "03",
            "lives_p2": "00", "stage": "03", "scene": "00",
            "substate": "00", "ghost_states": "04040404",
            "phase": "01", "pause": "00",
        }


if __name__ == "__main__":
    unittest.main()
