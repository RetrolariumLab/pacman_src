from __future__ import annotations

import copy
import json
import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "scripts" / "validation"))

from make_help import load_help, render_help, validate_help  # noqa: E402


MANIFEST = PROJECT_ROOT / "config/make_help.json"


class MakeHelpTests(unittest.TestCase):
    def test_project_help_exactly_covers_phony_interface(self) -> None:
        self.assertEqual(validate_help(PROJECT_ROOT, load_help(MANIFEST)), [])

    def test_rendered_help_contains_every_public_target(self) -> None:
        document = load_help(MANIFEST)
        rendered = render_help(document)
        for category in document["categories"]:
            for command in category["commands"]:
                self.assertIn(f"make {command['usage']}", rendered)

    def test_missing_public_target_is_rejected(self) -> None:
        document = copy.deepcopy(load_help(MANIFEST))
        document["categories"][0]["commands"].pop(0)
        errors = validate_help(PROJECT_ROOT, document)
        self.assertTrue(any("undocumented public Make targets" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
