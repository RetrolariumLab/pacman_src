from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from run_revision_smokes import parse_result  # noqa: E402


class RevisionSmokeTests(unittest.TestCase):
    def test_result_parser_reads_key_value_report(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.txt"
            path.write_text("menu_hit=true\noam_mismatches=0\nstatus=PASS\n", encoding="utf-8")
            self.assertEqual(parse_result(path)["status"], "PASS")

    def test_result_parser_rejects_malformed_line(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.txt"
            path.write_text("not a result\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "invalid"):
                parse_result(path)


if __name__ == "__main__":
    unittest.main()
