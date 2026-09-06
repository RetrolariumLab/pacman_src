#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
from pathlib import Path

from revision_profiles import select_revision


def file_sha1(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build one official Pac-Man revision from the revision manifest."
    )
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--profile", required=True)
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--project-dir", type=Path, required=True)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument("--generated-chr", type=Path, required=True)
    parser.add_argument("--build-dir", type=Path, required=True)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()

    try:
        revision = select_revision(args.manifest, args.profile)
        reference_rom = args.reference_dir / revision.rom
        if not reference_rom.is_file():
            raise ValueError(f"missing reference ROM: {reference_rom}")
        actual_sha1 = file_sha1(reference_rom)
        if actual_sha1 != revision.sha1:
            raise ValueError(
                f"reference SHA1 {actual_sha1}, expected {revision.sha1}"
            )
        actual_sha256 = file_sha256(reference_rom)
        if actual_sha256 != revision.sha256:
            raise ValueError(
                f"reference SHA256 {actual_sha256}, expected {revision.sha256}"
            )
    except (OSError, ValueError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2

    build_dir = args.build_dir
    command = [
        sys.executable,
        str(args.project_dir / "scripts" / "build_native.py"),
        "--source", str(args.source),
        "--define", f"PACMAN_REVISION={revision.ca65_revision}",
        "--config", str(args.config),
        "--original-rom", str(reference_rom),
        "--object", str(build_dir / "pacman.o"),
        "--prg", str(build_dir / "pacman.prg"),
        "--labels", str(build_dir / "pacman.lbl"),
        "--map", str(build_dir / "pacman.map"),
        "--debug-info", str(build_dir / "pacman.dbg"),
        "--output-rom", str(build_dir / "pacman.nes"),
    ]
    if revision.chr_source == "reference":
        command.append("--chr-from-reference")
    else:
        command.extend(("--chr", str(args.generated_chr)))
    if args.verify:
        command.append("--verify")
    return subprocess.run(command, cwd=args.project_dir, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
