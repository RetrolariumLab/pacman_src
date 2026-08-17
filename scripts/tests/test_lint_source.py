from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from lint_source import (  # noqa: E402
    LintResult,
    check_asm_file,
    check_documentation_references,
    check_python_syntax,
    check_text_format,
)


class LintSourceTests(unittest.TestCase):
    def test_rejects_legacy_and_unsupported_symbol_prefixes(self) -> None:
        result = LintResult()
        check_asm_file(
            Path("src/test.asm"),
            "ofs_003_old:\nthing_without_role:\n",
            result,
            {},
            {},
        )
        messages = "\n".join(result.errors)
        self.assertIn("legacy ofs_ definition", messages)
        self.assertIn("unsupported prefix", messages)

    def test_rejects_repeated_assembly_blank_lines(self) -> None:
        result = LintResult()
        check_text_format(Path("src/test.asm"), "sub_test:\n\n\n    RTS\n", result)
        self.assertTrue(any("repeated blank line" in error for error in result.errors))

    def test_documentation_symbols_and_local_links_must_resolve(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs").mkdir()
            (root / "docs" / "present.md").write_text("ok\n", encoding="utf-8")
            text = {
                Path("README.md"): (
                    "`sub_known` `ram_missing` `sub_EE5C` "
                    "[present](docs/present.md) [missing](docs/missing.md)\n"
                )
            }
            result = LintResult()
            check_documentation_references(root, text, {"sub_known"}, result)
            messages = "\n".join(result.errors)
            self.assertIn("undefined symbol: ram_missing", messages)
            self.assertIn("broken local documentation link", messages)
            self.assertNotIn("sub_EE5C", messages)

    def test_imported_nesdev_reference_is_outside_project_doc_checks(self) -> None:
        result = LintResult()
        check_documentation_references(
            Path.cwd(),
            {Path("docs/nesdev/import.md"): "`ram_missing` [wiki syntax](not-a-file)\n"},
            set(),
            result,
        )
        self.assertEqual(result.errors, [])

    def test_python_syntax_errors_are_reported_without_execution(self) -> None:
        result = LintResult()
        check_python_syntax(Path("scripts/broken.py"), "def broken(:\n", result)
        self.assertTrue(any("Python syntax error" in error for error in result.errors))


if __name__ == "__main__":
    unittest.main()
