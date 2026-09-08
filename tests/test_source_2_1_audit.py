from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from source_2_1_audit import (  # noqa: E402
    EXPECTED_RELEASE_LINE,
    EXPECTED_PREDECESSOR,
    EXPECTED_RELEASE,
    EXPECTED_SCOPE,
    EXPECTED_TAG,
    make_targets,
    repository_make_targets,
    validate_delta_evidence,
    validate_layout,
    validate_release_metadata,
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


class Source21AuditTests(unittest.TestCase):
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
        text = "verify: build\n\tpython tool.py\nsource-2-1-audit:\n"
        self.assertEqual(make_targets(text), {"verify", "source-2-1-audit"})

    def test_project_make_targets_include_fragments(self) -> None:
        root = Path(__file__).resolve().parents[1]
        targets = repository_make_targets(root)
        self.assertIn("validate-expanded", targets)
        self.assertIn("source-2-1-audit", targets)

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
                "variant_entrypoints": ["src/main.asm"],
                "linker_configs": ["src/main.asm"],
                "tests_root": "tests",
                "required_test_modules": ["src/main.asm"],
            })
            self.assertTrue(any("src root ASM" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
