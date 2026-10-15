from __future__ import annotations

from rom_assets import read_source_text

import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts" / "build"))

from relocate import relocate  # noqa: E402


class RelocateTests(unittest.TestCase):
    def test_every_module_moves_one_byte_further_and_the_tail_stays(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "src"
            (source / "data").mkdir(parents=True)
            (source / "memory.inc").write_text("VALUE = $01\n", encoding="utf-8")
            (source / "first.asm").write_text('.segment "BANK_FF"\n.org $C000\ntbl_first:\n    .byte $00\n',
                                              encoding="utf-8")
            (source / "second.asm").write_text("tbl_second:\n    .byte $01\n", encoding="utf-8")
            (source / "data" / "tail_and_vectors.asm").write_text("unused_tail:\n    .res $FFF8 - *, $FF\n",
                                                                  encoding="utf-8")
            main = source / "main.asm"
            main.write_text('.include "memory.inc"\n.include "first.asm"\n.include "second.asm"\n'
                            '.include "data/tail_and_vectors.asm"\n', encoding="utf-8")
            output = root / "build" / "source" / "main.asm"

            shifts = relocate(main, output)

            self.assertEqual([("src/first.asm", 1), ("src/second.asm", 2)], shifts)
            self.assertIn(".org $C000\n    .byte $EA\n", read_source_text(output.parent / "first.asm"))
            self.assertEqual('.include "memory.inc"\n.include "first.asm"\n    .byte $EA\n'
                             '.include "second.asm"\n.include "data/tail_and_vectors.asm"\n',
                             read_source_text(output))

    def test_a_source_without_the_tail_is_refused(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            main = Path(directory) / "main.asm"
            main.write_text('.include "first.asm"\n.include "second.asm"\n', encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "tail_and_vectors"):
                relocate(main, Path(directory) / "out" / "main.asm")


if __name__ == "__main__":
    unittest.main()
