from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import build_revision  # noqa: E402


class BuildRevisionTests(unittest.TestCase):
    def test_manifest_drives_define_rom_and_chr_mode(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            reference = root / "reference"
            reference.mkdir()
            rom = reference / "profile.nes"
            rom.write_bytes(b"reference")
            manifest = root / "revisions.json"
            manifest.write_text(json.dumps({
                "format": 2,
                "default_profile": "profile",
                "profiles": [{
                    "id": "profile",
                    "rom": rom.name,
                    "sha1": hashlib.sha1(rom.read_bytes()).hexdigest(),
                    "sha256": hashlib.sha256(rom.read_bytes()).hexdigest(),
                    "ca65_revision": 6,
                    "chr_source": "reference",
                    "runtime_smoke": "title_menu_boot",
                }],
            }), encoding="utf-8")
            arguments = [
                "build_revision.py",
                "--manifest", str(manifest),
                "--profile", "profile",
                "--reference-dir", str(reference),
                "--project-dir", str(root),
                "--source", str(root / "src/main.asm"),
                "--config", str(root / "config/linker.cfg"),
                "--generated-chr", str(root / "assets/chr.bin"),
                "--build-dir", str(root / "build/profile"),
                "--verify",
            ]
            with patch.object(sys, "argv", arguments), patch(
                "build_revision.subprocess.run"
            ) as run:
                run.return_value.returncode = 0
                self.assertEqual(build_revision.main(), 0)
            command = run.call_args.args[0]
            self.assertIn("PACMAN_REVISION=6", command)
            self.assertIn("--chr-from-reference", command)
            self.assertIn("--verify", command)

    def test_wrong_reference_hash_stops_before_build(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            rom = root / "profile.nes"
            rom.write_bytes(b"wrong")
            manifest = root / "revisions.json"
            manifest.write_text(json.dumps({
                "format": 2,
                "default_profile": "profile",
                "profiles": [{
                    "id": "profile", "rom": rom.name, "sha1": "0" * 40,
                    "sha256": "0" * 64, "ca65_revision": 0,
                    "chr_source": "generated", "runtime_smoke": "title_menu_boot",
                }],
            }), encoding="utf-8")
            arguments = [
                "build_revision.py", "--manifest", str(manifest),
                "--profile", "profile", "--reference-dir", str(root),
                "--project-dir", str(root), "--source", "main.asm",
                "--config", "linker.cfg", "--generated-chr", "chr.bin",
                "--build-dir", "build",
            ]
            with patch.object(sys, "argv", arguments), patch(
                "build_revision.subprocess.run"
            ) as run:
                self.assertEqual(build_revision.main(), 2)
            run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
