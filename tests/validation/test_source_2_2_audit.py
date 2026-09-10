from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts" / "validation"))

from source_2_2_audit import (  # noqa: E402
    EXPECTED_RELEASE_LINE,
    EXPECTED_PREDECESSOR,
    EXPECTED_RELEASE,
    EXPECTED_SCOPE,
    EXPECTED_TAG,
    make_targets,
    repository_make_targets,
    validate_delta_evidence,
    validate_history,
    validate_layout,
    validate_output_layout,
    validate_public_text_language,
    validate_release_metadata,
    validate_source_layout,
)


def release_manifest() -> dict[str, object]:
    return {
        "release_line": EXPECTED_RELEASE_LINE,
        "release": EXPECTED_RELEASE.copy(),
        "release_kind": "compatible_minor",
        "tag": EXPECTED_TAG,
        "predecessor": EXPECTED_PREDECESSOR.copy(),
        "included_scope": list(EXPECTED_SCOPE),
        "excluded_scope": [{
            "id": "future", "status": "planned", "reason": "Deferred.",
        }],
        "delta": [{
            "id": "change",
            "kind": "evidence",
            "summary": "summary",
            "evidence": ["docs/evidence.md"],
        }],
    }


class Source22AuditTests(unittest.TestCase):
    def test_release_metadata_accepts_exact_semantic_contract(self) -> None:
        self.assertEqual(validate_release_metadata(release_manifest()), [])

    def test_release_metadata_rejects_wrong_predecessor(self) -> None:
        manifest = release_manifest()
        manifest["predecessor"] = {"tag": "source-reconstruction-1.0"}
        self.assertTrue(validate_release_metadata(manifest))

    def test_release_metadata_requires_evidence_backed_delta(self) -> None:
        manifest = release_manifest()
        manifest["delta"] = [{"id": "change", "kind": "evidence"}]
        self.assertTrue(validate_release_metadata(manifest))

    def test_release_delta_evidence_must_exist(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            errors = validate_delta_evidence(
                Path(directory), [{"evidence": ["missing.md"]}],
            )
        self.assertTrue(any("missing release-delta evidence" in error for error in errors))

    def test_make_target_parser_ignores_recipe_lines(self) -> None:
        text = "verify: build\n\tpython tool.py\nsource-2-2-audit:\n"
        self.assertEqual(make_targets(text), {"verify", "source-2-2-audit"})

    def test_project_make_targets_include_fragments(self) -> None:
        root = Path(__file__).resolve().parents[2]
        targets = repository_make_targets(root)
        self.assertIn("test-relocation", targets)
        self.assertIn("source-2-2-audit", targets)

    def test_tracked_cyrillic_public_text_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            (root / "docs").mkdir()
            (root / "docs" / "public.md").write_text(
                "\u041d\u0435 \u0430\u043d\u0433\u043b\u0438\u0439\u0441\u043a\u0438\u0439.\n",
                encoding="utf-8",
            )
            subprocess.run(["git", "add", "-A"], cwd=root, check=True)
            errors = validate_public_text_language(root)
        self.assertTrue(any("non-English script" in error for error in errors))

    def test_release_history_rejects_an_empty_commit(self) -> None:
        message = (
            "Record a substantive result\n\n"
            "Change the tracked release evidence for this test.\n\n"
            "Preserve the declared compatibility boundary and checks.\n\n"
            "Co-Authored-By: Codex <noreply@openai.com>"
        )
        empty_message = message.replace(
            "Record a substantive result", "Trigger an empty release marker",
        )
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.name", "Test"], cwd=root, check=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=root, check=True)
            (root / "manifest.json").write_text("{}\n", encoding="utf-8")
            subprocess.run(["git", "add", "manifest.json"], cwd=root, check=True)
            subprocess.run(["git", "commit", "-q", "-m", "Base"], cwd=root, check=True)
            base = subprocess.run(
                ["git", "rev-parse", "HEAD"], cwd=root, capture_output=True,
                text=True, check=True,
            ).stdout.strip()
            subprocess.run(
                ["git", "tag", "-a", "source-reconstruction-2.1", "-m", "Base"],
                cwd=root, check=True,
            )
            (root / "release.txt").write_text("evidence\n", encoding="utf-8")
            subprocess.run(["git", "add", "release.txt"], cwd=root, check=True)
            subprocess.run(["git", "commit", "-q", "-m", message], cwd=root, check=True)
            subprocess.run(
                ["git", "commit", "-q", "--allow-empty", "-m", empty_message],
                cwd=root, check=True,
            )
            errors = validate_history(
                root,
                {"commit": base, "tag": "source-reconstruction-2.1", "manifest": "manifest.json"},
                {
                    "range_start": base,
                    "commit_count": 2,
                    "commits": [
                        {"subject": "Record a substantive result", "delta_ids": ["change"], "paths": ["release.txt"]},
                        {"subject": "Trigger an empty release marker", "delta_ids": ["change"], "paths": ["release.txt"]},
                    ],
                },
                [{"id": "change", "kind": "tooling", "summary": "Test", "evidence": ["release.txt"]}],
            )
        self.assertTrue(any("empty commit" in error for error in errors))

    def test_project_source_layout_is_complete(self) -> None:
        root = Path(__file__).resolve().parents[2]
        self.assertEqual(
            validate_source_layout(
                root, root / "config/reconstruction/source_layout.json",
            ),
            [],
        )

    def test_project_output_layout_is_confined(self) -> None:
        root = Path(__file__).resolve().parents[2]
        manifest = json.loads(
            (root / "config/source_reconstruction_2_2.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual(validate_output_layout(root, manifest["output_layout"]), [])

    def test_layout_rejects_extra_root_entrypoint(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "src").mkdir()
            (root / "src" / "main.asm").write_text("", encoding="utf-8")
            (root / "src" / "extra.asm").write_text("", encoding="utf-8")
            (root / "tests").mkdir()
            errors = validate_layout(root, {
                "src_root_asm": ["main.asm"],
                "canonical_source": "src/main.asm",
                "revision_ids": "src/main.asm",
                "source_layout_registry": "src/missing-layout.json",
                "variant_entrypoints": ["src/main.asm"],
                "linker_configs": ["src/main.asm"],
                "tests_root": "tests",
                "required_test_modules": ["src/main.asm"],
            })
            self.assertTrue(any("src root ASM" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
