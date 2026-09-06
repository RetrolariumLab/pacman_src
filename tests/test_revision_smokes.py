from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
sys.path.insert(0, str(SCRIPTS / "workflow"))

from revision_profiles import Revision  # noqa: E402
from run_revision_smokes import (  # noqa: E402
    parse_result,
    validate_result,
    validate_scenarios,
)


class RevisionSmokeTests(unittest.TestCase):
    def test_result_parser_reads_key_value_report(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.txt"
            path.write_text("menu_hit=true\noam_uniform=true\n", encoding="utf-8")
            self.assertEqual(parse_result(path)["oam_uniform"], "true")

    def test_result_parser_rejects_malformed_line(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.txt"
            path.write_text("not a result\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "invalid"):
                parse_result(path)

    def test_release_matrix_requires_direct_coverage_for_every_profile(self) -> None:
        revisions = {
            "a": Revision("a", "a.nes", "0" * 40, "0" * 64, 0, "generated", "boot"),
            "b": Revision("b", "b.nes", "1" * 40, "1" * 64, 1, "generated", "boot"),
        }
        rows = [{"id": "a", "scenario": "boot", "max_frames": 10, "title_oam_fill": 0}]
        with self.assertRaisesRegex(ValueError, "lack direct runtime smoke"):
            validate_scenarios(rows, revisions, True)

    def test_runtime_smoke_must_match_revision_contract(self) -> None:
        revisions = {
            "a": Revision("a", "a.nes", "0" * 40, "0" * 64, 0, "generated", "boot"),
        }
        rows = [{"id": "a", "scenario": "other", "max_frames": 10, "title_oam_fill": 0}]
        with self.assertRaisesRegex(ValueError, "runtime smoke mismatch"):
            validate_scenarios(rows, revisions, True)

    def test_validator_accepts_complete_capture(self) -> None:
        result = {
            "frames": "246",
            "nmi_hits": "242",
            "menu_hit": "true",
            "oam_value": "0",
            "oam_uniform": "true",
            "oam_first_difference": "-1",
        }
        scenario = {"max_frames": 900, "title_oam_fill": 0}
        self.assertEqual(validate_result(result, scenario), (246, 242))

    def test_validator_rejects_wrong_oam_value(self) -> None:
        result = {
            "frames": "246",
            "nmi_hits": "242",
            "menu_hit": "true",
            "oam_value": "239",
            "oam_uniform": "true",
            "oam_first_difference": "-1",
        }
        scenario = {"max_frames": 900, "title_oam_fill": 0}
        with self.assertRaisesRegex(ValueError, "expected 0"):
            validate_result(result, scenario)


if __name__ == "__main__":
    unittest.main()
