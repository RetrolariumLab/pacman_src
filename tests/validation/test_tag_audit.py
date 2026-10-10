from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts" / "validation"))

from tag_audit import run_at_tag  # noqa: E402


def git(root: Path, *arguments: str) -> None:
    subprocess.run(["git", *arguments], cwd=root, check=True, capture_output=True)


class TagAuditTests(unittest.TestCase):
    def test_the_tag_runs_its_own_script_on_its_own_tree(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            git(root, "init", "-q")
            git(root, "config", "user.name", "Test")
            git(root, "config", "user.email", "test@example.com")
            script = root / "audit.py"
            script.write_text(
                "import pathlib, sys\n"
                "sys.exit(0 if pathlib.Path(sys.argv[1], 'evidence.txt').is_file() else 1)\n",
                encoding="utf-8")
            (root / "evidence.txt").write_text("released\n", encoding="utf-8")
            git(root, "add", "-A")
            git(root, "commit", "-q", "-m", "Release")
            git(root, "tag", "-a", "release-1", "-m", "Release")
            # Later work removes the evidence and changes the script.
            (root / "evidence.txt").unlink()
            script.write_text("import sys\nsys.exit(3)\n", encoding="utf-8")
            git(root, "commit", "-q", "-am", "Move on")
            self.assertEqual(run_at_tag(root, "release-1", ["audit.py", "{root}"]), 0)
            with self.assertRaisesRegex(ValueError, "cannot check out"):
                run_at_tag(root, "release-2", ["audit.py"])


if __name__ == "__main__":
    unittest.main()
