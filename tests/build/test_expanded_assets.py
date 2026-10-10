from __future__ import annotations

import copy
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "build"))

from build_expanded import validate_chr_input  # noqa: E402
from expanded_assets import encode_sound_collection, write_assets  # noqa: E402
from palette_assets import ENCODED_SIZE, decode_palette_collection, encode_palette_collection  # noqa: E402
from screen_assets import (  # noqa: E402
    BUNDLE_SIZE, EXPANDED_BASE, OFFSETS, decode_screen_collection, encode_screen_collection,
    validate_screen_collection,
)


ROM = ROOT / "Pac-Man (J) (V1.0) [!].nes"
ASSETS = ROOT / "assets/generated"
CHR = ASSETS / "chr/pacman.chr"


def streams(extra_notes: int = 0) -> list[dict[str, object]]:
    result = []
    for slot in range(16):
        commands = [{"kind": "note", "value": 0x01, "duration": 1}] * (extra_notes if slot == 0 else 0)
        commands.append({"kind": "control", "opcode": 0xF0})
        result.append({"format": "sound_stream", "prologue": [1, 2, 3, 4], "commands": commands,
                       "trailing_bytes": []})
    return result


class SoundCollectionTests(unittest.TestCase):
    def test_variable_length_streams_recalculate_following_pointers(self) -> None:
        pointers, bundle, used = encode_sound_collection(streams(extra_notes=3), 0x9000, 256)
        self.assertEqual(pointers[0] | pointers[1] << 8, 0x9000)
        self.assertEqual(pointers[2] | pointers[3] << 8, 0x9000 + 4 + 3 * 2 + 1)
        self.assertEqual(len(bundle), 256)
        self.assertEqual(bundle[used:], b"\xFF" * (256 - used))

    def test_sound_budget_overflow_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "exceed 80-byte budget"):
            encode_sound_collection(streams(extra_notes=20), 0x9000, 80)


@unittest.skipUnless(ROM.is_file() and CHR.is_file(), "the Pac-Man v1.0 ROM and its split assets are needed")
class ExpandedAssetTests(unittest.TestCase):
    def test_palette_collection_holds_every_runtime_section(self) -> None:
        document = decode_palette_collection(ROM.read_bytes())
        payload = encode_palette_collection(document)
        self.assertEqual(len(payload), ENCODED_SIZE)
        self.assertEqual(payload[:16], bytes(document["title_background"]))
        self.assertEqual(payload[16:48], bytes(document["attract_bg_spr"]))
        self.assertEqual(payload[48:80], bytes(document["round_gameplay"]))

    def test_screens_encode_into_the_fixed_bundle(self) -> None:
        document = decode_screen_collection(ROM.read_bytes())
        encoded = encode_screen_collection(document)
        self.assertEqual(len(encoded), BUNDLE_SIZE)
        self.assertEqual(encoded[:138], bytes(document["title_logo"]["tiles"]))
        pointer = encoded[OFFSETS["attract_pointers"]] | encoded[OFFSETS["attract_pointers"] + 1] << 8
        self.assertEqual(pointer, EXPANDED_BASE + OFFSETS["attract_packets"])
        broken = copy.deepcopy(document)
        broken["title_logo"]["width"] = 24
        with self.assertRaisesRegex(ValueError, "23x6"):
            validate_screen_collection(broken)

    def test_assets_come_from_the_rom_and_probes_mark_two_values(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            plain, probed = Path(directory, "plain"), Path(directory, "probe")
            arguments = (ROM, ASSETS / "maze/maze.rle", ROOT / "assets/manifest.json", ASSETS)
            write_assets(*arguments, plain)
            write_assets(*arguments, probed, probe=True)
            rom = ROM.read_bytes()
            stage = (plain / "stage_parameters.bin").read_bytes()
            self.assertEqual(stage, rom[16 + 0xEB42 - 0xC000:][:310])
            self.assertEqual((plain / "maze.rle").read_bytes(), (ASSETS / "maze/maze.rle").read_bytes())
            self.assertEqual((probed / "stage_parameters.bin").read_bytes()[7], 14)
            differing = [name.name for name in plain.iterdir()
                         if name.read_bytes() != (probed / name.name).read_bytes()]
            self.assertEqual(sorted(differing), ["sound_streams.bin", "stage_parameters.bin"])

    def test_expanded_build_accepts_a_fixed_size_chr(self) -> None:
        validate_chr_input(b"\x33" * 8192, CHR.read_bytes())
        with self.assertRaises(SystemExit):
            validate_chr_input(b"\x33" * 8191, CHR.read_bytes())


if __name__ == "__main__":
    unittest.main()
