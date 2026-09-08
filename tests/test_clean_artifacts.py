from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from clean_artifacts import clean_build_root  # noqa: E402


class CleanArtifactsTests(unittest.TestCase):
    def test_clean_removes_build_and_preserves_private_siblings(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build = root / "build"
            workspace = root / "content/workspace"
            reference = root / "reference"
            build.mkdir()
            workspace.mkdir(parents=True)
            reference.mkdir()
            (build / "result.txt").write_text("generated", encoding="utf-8")
            (workspace / "edit.json").write_text("private", encoding="utf-8")
            (reference / "capture.png").write_bytes(b"private")

            self.assertEqual(clean_build_root(root, build, False), 0)

            self.assertFalse(build.exists())
            self.assertTrue((workspace / "edit.json").is_file())
            self.assertTrue((reference / "capture.png").is_file())

    def test_clean_rejects_project_root_and_sibling(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for unsafe in (root, root / "reference"):
                with self.subTest(unsafe=unsafe):
                    with self.assertRaisesRegex(ValueError, "canonical build root"):
                        clean_build_root(root, unsafe, True)

    def test_dry_run_preserves_build_tree(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build = root / "build"
            build.mkdir()
            self.assertEqual(clean_build_root(root, build, True), 0)
            self.assertTrue(build.is_dir())


if __name__ == "__main__":
    unittest.main()
