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
        maze_original = b"\x12\x34"
        stage = b"\x56\x78\x9A"
        maze_stage2 = b"\xBC\xDE"
        selector = b"\xEA\x60"
        extra = (
            maze_original + stage + maze_stage2 + selector
            + b"\xFF" * (16_384 - len(maze_original) - len(stage) - len(maze_stage2) - len(selector))
        )
        layout = {
            "extra_bank": {"address": 0x8000, "size": 16_384, "fill": 0xFF},
            "assets": [
                {"name": "maze_original", "address": 0x8000, "size": len(maze_original)},
                {"name": "stage_parameters", "address": 0x8002, "size": len(stage)},
                {"name": "maze_stage2", "address": 0x8005, "size": len(maze_stage2)},
            ],
            "inline_regions": [
                {"name": "maze_selector", "address": 0x8007, "bytes": list(selector)}
            ],
            "fixed_bank_changes": [
                {"address": 0xC000, "original": 0x55, "variant": 0x66}
            ],
        }
        assets = {
            "maze_original": maze_original,
            "stage_parameters": stage,
            "maze_stage2": maze_stage2,
        }
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
        declared_size = sum(len(data) for data in assets.values()) + 2
        changed[16 + declared_size] = 0
        with self.assertRaisesRegex(ValueError, "unexpected data"):
            validate_expanded(original, bytes(changed), assets, layout)

    def test_inline_selector_change_is_rejected(self) -> None:
        original, candidate, assets, layout = self.fixture()
        changed = bytearray(candidate)
        changed[16 + 7] ^= 1
        with self.assertRaisesRegex(ValueError, "region mismatch"):
            validate_expanded(original, bytes(changed), assets, layout)


if __name__ == "__main__":
    unittest.main()
