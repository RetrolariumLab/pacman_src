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
    def candidate(self) -> tuple[bytes, bytes, bytes]:
        original_prg = bytearray(b"\x55" * 16_384)
        original_prg[0x3FF8:0x3FFA] = b"\x78\xEC"
        maze = b"\x12\x34"
        extra = maze + b"\xFF" * (16_384 - len(maze))
        fixed = bytearray(original_prg)
        fixed[0x3FF8:0x3FFA] = b"\x00\x80"
        return rom(bytes(original_prg), 1), rom(extra + bytes(fixed), 2), maze

    def test_valid_layout_accepts_only_pointer_change(self) -> None:
        validate_expanded(*self.candidate())

    def test_other_fixed_bank_change_is_rejected(self) -> None:
        original, candidate, maze = self.candidate()
        changed = bytearray(candidate)
        changed[16 + 16_384] ^= 1
        with self.assertRaisesRegex(ValueError, "beyond the maze pointer"):
            validate_expanded(original, bytes(changed), maze)

    def test_unexpected_extra_bank_data_is_rejected(self) -> None:
        original, candidate, maze = self.candidate()
        changed = bytearray(candidate)
        changed[16 + len(maze)] = 0
        with self.assertRaisesRegex(ValueError, "unexpected data"):
            validate_expanded(original, bytes(changed), maze)


if __name__ == "__main__":
    unittest.main()
