from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from verify_expanded import validate_expanded  # noqa: E402


def rom(prg: bytes, banks: int) -> bytes:
    header = b"NES\x1a" + bytes([banks, 1]) + b"\x00" * 10
    return header + prg + b"\x22" * 8192


class VerifyExpandedTests(unittest.TestCase):
    def fixture(self) -> tuple[bytes, bytes, dict[str, bytes], dict[str, object]]:
        original_prg = bytearray(b"\x55" * 16_384)
        fixed = bytearray(original_prg)
        fixed[0] = 0x66
        maze = b"\x12\x34"
        stage = b"\x56\x78\x9A"
        extra = maze + stage + b"\xFF" * (16_384 - len(maze) - len(stage))
        layout = {
            "extra_bank": {"address": 0x8000, "size": 16_384, "fill": 0xFF},
            "assets": [
                {"name": "maze", "address": 0x8000, "size": len(maze)},
                {"name": "stage_parameters", "address": 0x8002, "size": len(stage)},
            ],
            "fixed_bank_changes": [
                {"address": 0xC000, "original": 0x55, "variant": 0x66}
            ],
        }
        assets = {"maze": maze, "stage_parameters": stage}
        return rom(bytes(original_prg), 1), rom(extra + bytes(fixed), 2), assets, layout

    def test_valid_layout_accepts_declared_assets_and_fixed_change(self) -> None:
        validate_expanded(*self.fixture())

    def test_other_fixed_bank_change_is_rejected(self) -> None:
        original, candidate, assets, layout = self.fixture()
        changed = bytearray(candidate)
        changed[16 + 16_384 + 1] ^= 1
        with self.assertRaisesRegex(ValueError, "fixed-bank change manifest mismatch"):
            validate_expanded(original, bytes(changed), assets, layout)

    def test_asset_gap_is_rejected(self) -> None:
        original, candidate, assets, layout = self.fixture()
        layout["assets"][1]["address"] += 1
        with self.assertRaisesRegex(ValueError, "not contiguous"):
            validate_expanded(original, candidate, assets, layout)

    def test_unexpected_extra_bank_data_is_rejected(self) -> None:
        original, candidate, assets, layout = self.fixture()
        changed = bytearray(candidate)
        changed[16 + len(assets["maze"]) + len(assets["stage_parameters"])] = 0
        with self.assertRaisesRegex(ValueError, "unexpected data"):
            validate_expanded(original, bytes(changed), assets, layout)


if __name__ == "__main__":
    unittest.main()
