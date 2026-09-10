from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts" / "workflow"))

from verify_revision_matrix import Revision, load_manifest, verify_matrix  # noqa: E402


class RevisionMatrixTests(unittest.TestCase):
    def test_project_profiles_publish_complete_contracts(self) -> None:
        root = Path(__file__).resolve().parents[2]
        default_profile, revisions = load_manifest(root / "config/revisions.json")
        self.assertEqual(default_profile, "japan_v10")
        self.assertEqual(len(revisions), 7)
        self.assertTrue(all(revision.input_contracts for revision in revisions))
        self.assertTrue(
            all(revision.layout_contract == "nes_nrom128" for revision in revisions)
        )
        self.assertTrue(all(revision.output_size == 24592 for revision in revisions))
        self.assertEqual(
            [revision.artifact_id for revision in revisions],
            [f"pacman_{revision.profile_id}" for revision in revisions],
        )
        canonical = revisions[0]
        self.assertIn("canonical_relocation", canonical.capabilities)
        self.assertNotIn("canonical_relocation", revisions[1].capabilities)

    def test_matrix_distinguishes_pass_missing_and_hash_failure(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            good = b"good rom"
            (root / "good.nes").write_bytes(good)
            (root / "bad.nes").write_bytes(b"wrong rom")
            revisions = [
                Revision(
                    "good", "good.nes", hashlib.sha1(good).hexdigest(),
                    hashlib.sha256(good).hexdigest(),
                ),
                Revision("missing", "missing.nes", "0" * 40, "0" * 64),
                Revision("bad", "bad.nes", "1" * 40, "1" * 64),
            ]
            with patch("verify_revision_matrix.subprocess.run") as run:
                run.return_value.returncode = 0
                results = verify_matrix(revisions, root, root, "make")
            self.assertEqual([row[1] for row in results], ["PASS", "MISSING", "FAIL"])
            run.assert_called_once()

    def test_manifest_rejects_duplicate_profiles_and_unknown_default(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "revisions.json"
            base = {
                "id": "same", "rom": "a.nes", "sha1": "0" * 40,
                "sha256": "0" * 64, "ca65_revision": 0,
                "chr_source": "generated", "runtime_smoke": "title_menu_boot",
            }
            path.write_text(json.dumps({"format": 2, "default_profile": "same", "profiles": [base, base]}))
            with self.assertRaisesRegex(ValueError, "duplicate"):
                load_manifest(path)
            path.write_text(json.dumps({"format": 2, "default_profile": "other", "profiles": [base]}))
            with self.assertRaisesRegex(ValueError, "default profile"):
                load_manifest(path)

    def test_manifest_validates_build_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "revisions.json"
            base = {
                "id": "same", "rom": "a.nes", "sha1": "0" * 40,
                "sha256": "0" * 64, "ca65_revision": 0,
                "chr_source": "invalid", "runtime_smoke": "title_menu_boot",
            }
            path.write_text(json.dumps({
                "format": 2, "default_profile": "same", "profiles": [base],
            }))
            with self.assertRaisesRegex(ValueError, "chr_source"):
                load_manifest(path)

    def test_profile_contract_rejects_missing_capability(self) -> None:
        root = Path(__file__).resolve().parents[2]
        document = json.loads(
            (root / "config/revisions.json").read_text(encoding="utf-8")
        )
        document["profiles"][0]["capabilities"].remove("byte_identity")
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory)
            (project / "src").mkdir()
            (project / "src/main.asm").write_text("; fixture\n", encoding="utf-8")
            (project / "config/linker").mkdir(parents=True)
            (project / "config/linker/nrom128_prg_only.cfg").write_text(
                "# fixture\n", encoding="utf-8"
            )
            path = project / "config" / "revisions.json"
            path.parent.mkdir(exist_ok=True)
            path.write_text(json.dumps(document), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "required capabilities"):
                load_manifest(path)


if __name__ == "__main__":
    unittest.main()
