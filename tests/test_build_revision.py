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
from revision_profiles import Revision, RevisionLayout  # noqa: E402


class BuildRevisionTests(unittest.TestCase):
    def test_reference_layout_rejects_wrong_mapper(self) -> None:
        layout = RevisionLayout(
            "ines-1.0", 0, "horizontal", 16, 16384, 0xC000, True, 8192, 0,
        )
        revision = Revision(
            "fixture", "fixture.nes", "0" * 40, "0" * 64,
            layout_contract="nes_nrom128", layout=layout,
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "fixture.nes"
            header = b"NES\x1a" + bytes((1, 1, 0x10, 0)) + bytes(8)
            path.write_bytes(header + bytes(16384 + 8192))
            with self.assertRaisesRegex(ValueError, "mapper 1"):
                build_revision.validate_reference_layout(path, revision)

    def test_project_manifest_owns_default_build_paths(self) -> None:
        root = Path(__file__).resolve().parents[1]
        arguments = [
            "build_revision.py",
            "--manifest", str(root / "config/revisions.json"),
            "--profile", "japan_v10",
            "--reference-dir", str(root),
            "--project-dir", str(root),
        ]
        with patch.object(sys, "argv", arguments), patch(
            "build_revision.subprocess.run"
        ) as run:
            run.return_value.returncode = 0
            self.assertEqual(build_revision.main(), 0)
        command = run.call_args.args[0]
        self.assertEqual(
            Path(command[command.index("--source") + 1]), root / "src/main.asm"
        )
        self.assertEqual(
            Path(command[command.index("--config") + 1]),
            root / "config/linker/nrom128_prg_only.cfg",
        )
        self.assertEqual(
            Path(command[command.index("--output-rom") + 1]),
            root / "build/revisions/japan_v10/pacman.nes",
        )

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
