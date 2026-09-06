import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from build_dev import load_toolchain_manifest, verify_file_hash


class BuildDevTests(unittest.TestCase):
    def manifest(self, digest: str) -> dict[str, object]:
        return {
            "format": 1,
            "hosts": [{
                "os": "Windows",
                "architecture": "x64",
                "shell": "PowerShell with GNU Make",
                "python_tested": "3.14.6",
                "status": "tested",
            }],
            "components": {
                "ca65": {
                    "path": "bin/ca65.exe",
                    "version": "ca65 test",
                    "source": "https://example.invalid/cc65",
                    "source_commit": "abc123",
                    "binary_sha256": digest,
                    "provenance": "bundled",
                },
                "ld65": {
                    "path": "bin/ld65.exe",
                    "version": "ld65 test",
                    "source": "https://example.invalid/cc65",
                    "source_commit": "abc123",
                    "binary_sha256": digest,
                    "provenance": "bundled",
                },
                "fceux_automation": {
                    "source": "https://example.invalid/fceux",
                    "source_commit": "d" * 40,
                    "binary_sha256": digest,
                    "configuration": "Release",
                    "platform": "x64",
                    "toolset": "v143",
                    "provenance": "source-built external checkout",
                },
            },
        }

    def test_manifest_and_binary_hash_are_accepted(self) -> None:
        payload = b"pinned tool"
        digest = hashlib.sha256(payload).hexdigest()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest_path = root / "toolchain.json"
            binary_path = root / "tool.exe"
            manifest_path.write_text(json.dumps(self.manifest(digest)), encoding="utf-8")
            binary_path.write_bytes(payload)

            components = load_toolchain_manifest(manifest_path)
            verify_file_hash(binary_path, digest, "tool")

        self.assertEqual(set(components), {"ca65", "ld65", "fceux_automation"})

    def test_invalid_manifest_digest_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "toolchain.json"
            path.write_text(json.dumps(self.manifest("not-a-digest")), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "invalid binary_sha256"):
                load_toolchain_manifest(path)

    def test_binary_hash_mismatch_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "tool.exe"
            path.write_bytes(b"different")
            with self.assertRaisesRegex(ValueError, "SHA256"):
                verify_file_hash(path, "0" * 64, "tool")


if __name__ == "__main__":
    unittest.main()
