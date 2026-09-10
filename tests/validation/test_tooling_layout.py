from __future__ import annotations

import contextlib
import io
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch


PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))
sys.path.insert(0, str(PROJECT_ROOT / "scripts" / "validation"))

import run  # noqa: E402
from source_2_2_audit import validate_tooling_layout  # noqa: E402


REGISTRY = PROJECT_ROOT / "config/tooling_layout.json"


class ToolingLayoutTests(unittest.TestCase):
    def test_project_tooling_inventory_has_exact_owners(self) -> None:
        self.assertEqual(validate_tooling_layout(PROJECT_ROOT, REGISTRY), [])

    def test_launcher_lists_registry_commands_in_stable_order(self) -> None:
        expected = sorted(run.load_commands())
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            result = run.main(["list"])
        self.assertEqual(result, 0)
        self.assertEqual(output.getvalue().splitlines(), expected)

    def test_launcher_forwards_arguments_from_project_root(self) -> None:
        with patch.object(
            run.subprocess, "run", return_value=SimpleNamespace(returncode=7),
        ) as execute:
            result = run.main(["lint", "--help"])
        self.assertEqual(result, 7)
        command = execute.call_args.args[0]
        self.assertEqual(command[0], sys.executable)
        self.assertEqual(Path(command[1]), PROJECT_ROOT / "scripts/validation/lint_source.py")
        self.assertEqual(command[2:], ["--help"])
        self.assertEqual(execute.call_args.kwargs["cwd"], PROJECT_ROOT)

    def test_registry_rejects_an_unowned_executable(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(PROJECT_ROOT / "scripts", root / "scripts")
            shutil.copytree(PROJECT_ROOT / "tests", root / "tests")
            (root / "scripts/orphan.py").write_text("", encoding="utf-8")
            config = root / "config"
            config.mkdir()
            registry = config / "tooling_layout.json"
            registry.write_text(REGISTRY.read_text(encoding="utf-8"), encoding="utf-8")
            errors = validate_tooling_layout(root, registry)
        self.assertTrue(any("unowned tooling paths" in error for error in errors))

    def test_registry_requires_review_for_every_oversized_tool(self) -> None:
        document = json.loads(REGISTRY.read_text(encoding="utf-8"))
        document["size_exceptions"].pop()
        with tempfile.TemporaryDirectory() as directory:
            registry = Path(directory) / "tooling_layout.json"
            registry.write_text(json.dumps(document), encoding="utf-8")
            errors = validate_tooling_layout(PROJECT_ROOT, registry)
        self.assertTrue(any("size exceptions differ" in error for error in errors))

    def test_launcher_rejects_unknown_command(self) -> None:
        error = io.StringIO()
        with contextlib.redirect_stderr(error):
            result = run.main(["does-not-exist"])
        self.assertEqual(result, 2)
        self.assertIn("unknown tool command", error.getvalue())


if __name__ == "__main__":
    unittest.main()
