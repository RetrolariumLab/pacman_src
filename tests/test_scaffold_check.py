from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from scaffold_check import (  # noqa: E402
    clone_repository_history,
    copy_scaffold,
    repository_files,
    validate_no_private_inputs,
)


class ScaffoldCheckTests(unittest.TestCase):
    def test_repository_scaffold_excludes_ignored_private_inputs(self) -> None:
        values = {path.as_posix() for path in repository_files(PROJECT_ROOT)}
        self.assertFalse(any(path.endswith((".nes", ".fds")) for path in values))
        self.assertFalse(any(path.startswith("assets/generated/") for path in values))
        self.assertFalse(any(path.startswith("content/workspace/") for path in values))
        self.assertFalse(any(path.startswith("build/") for path in values))

    def test_private_input_detection_rejects_rom_and_workspace(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "content/workspace").mkdir(parents=True)
            (root / "game.nes").write_bytes(b"NES\x1a")
            with self.assertRaisesRegex(ValueError, "private/generated"):
                validate_no_private_inputs(root)

    def test_copy_scaffold_preserves_relative_tree(self) -> None:
        with tempfile.TemporaryDirectory() as source_dir, tempfile.TemporaryDirectory() as output_dir:
            source = Path(source_dir)
            output = Path(output_dir)
            relative = Path("docs/example.txt")
            (source / relative).parent.mkdir(parents=True)
            (source / relative).write_text("evidence", encoding="utf-8")
            copy_scaffold(source, output, [relative])
            self.assertEqual((output / relative).read_text(encoding="utf-8"), "evidence")

    def test_clone_preserves_release_history_and_tags(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory)
            source = parent / "source"
            source.mkdir()
            subprocess.run(["git", "init", "-q"], cwd=source, check=True)
            subprocess.run(["git", "config", "user.name", "Test"], cwd=source, check=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=source, check=True)
            (source / "tracked.txt").write_text("tracked\n", encoding="utf-8")
            subprocess.run(["git", "add", "tracked.txt"], cwd=source, check=True)
            subprocess.run(["git", "commit", "-q", "-m", "Base"], cwd=source, check=True)
            subprocess.run(
                ["git", "tag", "-a", "source-reconstruction-2.1", "-m", "Base"],
                cwd=source, check=True,
            )
            destination = parent / "clone"
            clone_repository_history(source, destination)
            tag_type = subprocess.run(
                ["git", "cat-file", "-t", "source-reconstruction-2.1"],
                cwd=destination, capture_output=True, text=True, check=True,
            ).stdout.strip()
        self.assertEqual(tag_type, "tag")


if __name__ == "__main__":
    unittest.main()
