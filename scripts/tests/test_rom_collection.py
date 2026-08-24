from __future__ import annotations

import sys
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from analyze_rom_collection import changed_ranges, difference_runs, normalize_prg  # noqa: E402


class RomCollectionTests(unittest.TestCase):
    def test_mirrored_prg_is_collapsed(self) -> None:
        bank = bytes(range(256)) * 64
        normalized, note = normalize_prg(bank + bank)
        self.assertEqual(normalized, bank)
        self.assertIn("mirrored", note)

    def test_nonmirrored_32k_prg_compares_vector_bearing_high_bank(self) -> None:
        low = b"a" * 16384
        high = b"b" * 16384
        normalized, note = normalize_prg(low + high)
        self.assertEqual(normalized, high)
        self.assertIn("high bank", note)

    def test_difference_runs_count_regions(self) -> None:
        self.assertEqual(difference_runs(b"abcdef", b"abXXeY"), (3, 2))
        self.assertEqual(changed_ranges(b"abcdef", b"abXXeY"), [(2, 4), (5, 6)])
        self.assertEqual(difference_runs(b"same", b"same"), (0, 0))


if __name__ == "__main__":
    unittest.main()
