from __future__ import annotations

import hashlib
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "scripts" / "workflow"))

from movie_format import (  # noqa: E402
    canonical_movie_bytes,
    canonical_movie_sha1,
    materialize_canonical_movie,
)


RAW_GIT_BLOB_SHA1 = "8377ff723142155b53bcb03294911f75895a9b2f"
CANONICAL_MOVIE_SHA1 = "f6a343fd9f50f4bc8773af48a79eda313c946961"


class MovieFormatTests(unittest.TestCase):
    def test_lf_and_crlf_serialize_to_identical_canonical_bytes(self) -> None:
        lf = b"version 3\n|0|........|\n"
        crlf = b"version 3\r\n|0|........|\r\n"
        self.assertEqual(canonical_movie_bytes(lf), crlf)
        self.assertEqual(canonical_movie_bytes(crlf), crlf)
        self.assertEqual(canonical_movie_sha1(lf), canonical_movie_sha1(crlf))

    def test_clean_checkout_git_blob_matches_canonical_movie_contract(self) -> None:
        completed = subprocess.run(
            ["git", "cat-file", "blob", "HEAD:movies/pacman_j_longplay.fm2"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            check=True,
        )
        blob = completed.stdout
        self.assertEqual(hashlib.sha1(blob).hexdigest(), RAW_GIT_BLOB_SHA1)
        self.assertNotIn(b"\r\n", blob)
        self.assertEqual(canonical_movie_sha1(blob), CANONICAL_MOVIE_SHA1)
        canonical = canonical_movie_bytes(blob)
        self.assertIn(b"\r\n", canonical)
        self.assertNotIn(b"\n", canonical.replace(b"\r\n", b""))

    def test_materialization_validates_hash_and_writes_atomically(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.fm2"
            output = root / "generated" / "canonical.fm2"
            source.write_bytes(b"version 3\n")
            expected = canonical_movie_sha1(source.read_bytes())
            self.assertEqual(
                materialize_canonical_movie(source, output, expected), output
            )
            self.assertEqual(output.read_bytes(), b"version 3\r\n")
            with self.assertRaisesRegex(ValueError, "canonical movie SHA-1 mismatch"):
                materialize_canonical_movie(source, output, "0" * 40)


if __name__ == "__main__":
    unittest.main()
