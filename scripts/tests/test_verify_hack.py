from __future__ import annotations

import unittest

from verify_hack import expected_rom_differences, observed_differences


def ines_rom(prg: bytes, chr_data: bytes = b"\x00" * 8192) -> bytes:
    header = b"NES\x1a" + bytes([1, 1]) + b"\x00" * 10
    return header + prg + chr_data


class VerifyHackTests(unittest.TestCase):
    def test_declared_prg_difference_maps_to_rom_offset(self) -> None:
        original = ines_rom(b"\x10" + b"\x20" * 16383)
        candidate = ines_rom(b"\x11" + b"\x20" * 16383)
        entries = [{"region": "prg", "offset": 0, "original": 16, "variant": 17}]
        self.assertEqual(expected_rom_differences(original, candidate, entries), [(16, 16, 17)])
        self.assertEqual(observed_differences(original, candidate), [(16, 16, 17)])

    def test_undeclared_difference_remains_observable(self) -> None:
        original = ines_rom(b"\x10\x20" + b"\x00" * 16382)
        candidate = ines_rom(b"\x11\x21" + b"\x00" * 16382)
        self.assertEqual(len(observed_differences(original, candidate)), 2)

    def test_manifest_original_value_must_match(self) -> None:
        original = ines_rom(b"\x10" + b"\x00" * 16383)
        candidate = ines_rom(b"\x11" + b"\x00" * 16383)
        entries = [{"region": "prg", "offset": 0, "original": 9, "variant": 17}]
        with self.assertRaisesRegex(ValueError, "manifest original mismatch"):
            expected_rom_differences(original, candidate, entries)


if __name__ == "__main__":
    unittest.main()
