from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from documentation_audit import audit_documentation, topic_prefix  # noqa: E402


class DocumentationAuditTests(unittest.TestCase):
    def setUp(self) -> None:
        self.layout = json.loads(
            (PROJECT_ROOT / "config/documentation_layout.json").read_text(encoding="utf-8")
        )

    def fixture(self, root: Path) -> dict[str, object]:
        (root / "docs/nesdev").mkdir(parents=True)
        (root / "docs/index.md").write_text("# Index\n", encoding="utf-8")
        (root / "docs/review.md").write_text("# Review\n", encoding="utf-8")
        (root / "docs/nesdev/README.md").write_text("# Boundary\n", encoding="utf-8")
        (root / "docs/nesdev/fds.md").write_text(
            "# FDS\n\nSource: https://www.nesdev.org/wiki/FDS_disk_format\n",
            encoding="utf-8",
        )
        return {
            "schema_version": 1,
            "docs_root": "docs",
            "index": "docs/index.md",
            "review": "docs/review.md",
            "project_documents": ["docs/index.md", "docs/review.md"],
            "reader_journeys": [{"id": "read", "paths": ["docs/index.md"]}],
            "size_policy": {"recommended_max_lines": 20, "exceptions": []},
            "prefix_policy": {"minimum_cluster_size": 3, "exceptions": []},
            "vendored_boundary": {
                "root": "docs/nesdev",
                "policy": "docs/nesdev/README.md",
                "documents": ["docs/nesdev/README.md", "docs/nesdev/fds.md"],
            },
        }

    def test_project_documentation_corpus_passes_review_contract(self) -> None:
        self.assertEqual(audit_documentation(PROJECT_ROOT, self.layout), [])

    def test_topic_prefix_uses_two_words_for_flat_clusters(self) -> None:
        self.assertEqual(topic_prefix("docs/source_reconstruction_2_2.md"), "source_reconstruction")
        self.assertEqual(topic_prefix("docs/validation.md"), "validation")

    def test_uninventoried_document_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            layout = self.fixture(root)
            (root / "docs/orphan.md").write_text("# Orphan\n", encoding="utf-8")
            errors = audit_documentation(root, layout)
            self.assertTrue(any("not inventoried" in error for error in errors))

    def test_vendored_snapshot_without_source_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            layout = self.fixture(root)
            (root / "docs/nesdev/fds.md").write_text("# FDS\n", encoding="utf-8")
            errors = audit_documentation(root, layout)
            self.assertTrue(any("lacks source attribution" in error for error in errors))

    def test_unreviewed_filename_cluster_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            layout = self.fixture(root)
            for suffix in ("one", "two", "three"):
                relative = f"docs/ghost_detail_{suffix}.md"
                (root / relative).write_text(f"# {suffix.title()}\n", encoding="utf-8")
                layout["project_documents"].append(relative)
            errors = audit_documentation(root, layout)
            self.assertTrue(any("prefix cluster" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
