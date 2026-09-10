from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import sys


sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts" / "validation"))

from asm_style import format_file, lint_file, split_comment  # noqa: E402


class AssemblyStyleTests(unittest.TestCase):
    def test_comment_split_ignores_semicolons_in_strings(self) -> None:
        before, comment = split_comment('    .byte "A;B"  ; text')
        self.assertEqual(before, '    .byte "A;B"  ')
        self.assertEqual(comment, " text")

    def test_formatter_normalizes_code_without_changing_operands(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.asm"
            path.write_text(
                '.macro Example\nlabel:\tlda #$01 ; Comment.\n  .byte "A;B"\n.endmacro\n\n',
                encoding="utf-8",
            )

            self.assertTrue(format_file(path))
            self.assertEqual(
                path.read_text(encoding="utf-8"),
                '.macro Example\nlabel:\n    LDA #$01  ; Comment\n    .byte "A;B"\n.endmacro\n',
            )
            self.assertEqual(lint_file(path), [])

    def test_linter_reports_style_violations_without_rewriting(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.inc"
            original = "label:\tlda #$01 ; comment.\n"
            path.write_text(original, encoding="utf-8")

            codes = {issue.code for issue in lint_file(path)}

            self.assertTrue({"tab", "label-line", "inline-comment-gap", "comment-period"} <= codes)
            self.assertEqual(path.read_text(encoding="utf-8"), original)

    def test_label_comment_moves_to_preceding_line(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.asm"
            path.write_text(
                "sub_example:  ; Explain the entry\n    RTS\n",
                encoding="utf-8",
            )

            self.assertIn("label-line", {issue.code for issue in lint_file(path)})
            self.assertTrue(format_file(path))
            self.assertEqual(
                path.read_text(encoding="utf-8"),
                "; Explain the entry\nsub_example:\n    RTS\n",
            )
            self.assertEqual(lint_file(path), [])


if __name__ == "__main__":
    unittest.main()
