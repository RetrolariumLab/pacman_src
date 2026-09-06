from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts" / "workflow"))

from verify_revision_matrix import Revision, load_manifest, verify_matrix  # noqa: E402


class RevisionMatrixTests(unittest.TestCase):
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


if __name__ == "__main__":
    unittest.main()
