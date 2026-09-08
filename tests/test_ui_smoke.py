from __future__ import annotations

import copy
import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from ui_smoke import load_manifest, prepare_output, validate_manifest  # noqa: E402


MANIFEST = PROJECT_ROOT / "config/authoring/ui_smokes.json"


class UiSmokeTests(unittest.TestCase):
    def test_project_contract_covers_all_studios_and_actions(self) -> None:
        self.assertEqual(
            validate_manifest(PROJECT_ROOT, load_manifest(MANIFEST), require_inputs=False),
            [],
        )

    def test_missing_dirty_close_action_is_rejected(self) -> None:
        document = copy.deepcopy(load_manifest(MANIFEST))
        document["studios"][0]["actions"].remove("dirty-close")
        errors = validate_manifest(PROJECT_ROOT, document, require_inputs=False)
        self.assertTrue(any("actions differ" in error for error in errors))

    def test_output_is_confined_below_build_root(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sibling = root / "private.txt"
            sibling.write_text("keep", encoding="utf-8")
            output = prepare_output(root, Path("build/ui_smoke"))
            (output / "old.txt").write_text("replace", encoding="utf-8")
            replaced = prepare_output(root, Path("build/ui_smoke"))
            self.assertFalse((replaced / "old.txt").exists())
            self.assertEqual(sibling.read_text(encoding="utf-8"), "keep")
            with self.assertRaisesRegex(ValueError, "unsafe"):
                prepare_output(root, Path("build"))


if __name__ == "__main__":
    unittest.main()
