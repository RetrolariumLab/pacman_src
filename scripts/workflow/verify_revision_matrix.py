#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence


@dataclass(frozen=True)
class Revision:
    profile_id: str
    rom: str
    sha1: str


def load_manifest(path: Path) -> tuple[str, list[Revision]]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("format") != 1:
        raise ValueError("unsupported revision manifest format")
    default_profile = document.get("default_profile")
    rows = document.get("profiles")
    if not isinstance(default_profile, str) or not isinstance(rows, list) or not rows:
        raise ValueError("manifest needs default_profile and a non-empty profiles list")

    revisions: list[Revision] = []
    seen: set[str] = set()
    for row in rows:
        try:
            revision = Revision(row["id"], row["rom"], row["sha1"].lower())
        except (KeyError, TypeError, AttributeError) as exc:
            raise ValueError("each profile needs string id, rom, and sha1 fields") from exc
        if not all(isinstance(value, str) and value for value in (revision.profile_id, revision.rom, revision.sha1)):
            raise ValueError("each profile needs non-empty string id, rom, and sha1 fields")
        if revision.profile_id in seen:
            raise ValueError(f"duplicate revision profile: {revision.profile_id}")
        if len(revision.sha1) != 40 or any(char not in "0123456789abcdef" for char in revision.sha1):
            raise ValueError(f"invalid SHA1 for {revision.profile_id}")
        seen.add(revision.profile_id)
        revisions.append(revision)
    if default_profile not in seen:
        raise ValueError(f"default profile is not declared: {default_profile}")
    return default_profile, revisions


def file_sha1(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_matrix(
    revisions: Sequence[Revision], reference_dir: Path, project_dir: Path,
    make_command: str, selected: set[str] | None = None,
) -> list[tuple[str, str, str]]:
    results: list[tuple[str, str, str]] = []
    for revision in revisions:
        if selected is not None and revision.profile_id not in selected:
            continue
        rom_path = reference_dir / revision.rom
        if not rom_path.is_file():
            results.append((revision.profile_id, "MISSING", revision.rom))
            continue
        actual_sha1 = file_sha1(rom_path)
        if actual_sha1 != revision.sha1:
            results.append((revision.profile_id, "FAIL", f"SHA1 {actual_sha1}, expected {revision.sha1}"))
            continue
        command = [
            make_command, "verify-revision", f"REVISION={revision.profile_id}",
            f"REVISION_REFERENCE_DIR={reference_dir.resolve()}",
        ]
        completed = subprocess.run(command, cwd=project_dir, check=False)
        if completed.returncode:
            results.append((revision.profile_id, "FAIL", f"make exited {completed.returncode}"))
        else:
            results.append((revision.profile_id, "PASS", revision.sha1))
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify every available official Pac-Man ROM revision.")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--project-dir", type=Path, required=True)
    parser.add_argument("--make", default="make")
    parser.add_argument("--profile", action="append", default=[])
    parser.add_argument("--require-all", action="store_true")
    args = parser.parse_args()
    try:
        _, revisions = load_manifest(args.manifest)
        known = {revision.profile_id for revision in revisions}
        selected = set(args.profile) if args.profile else None
        unknown = (selected or set()) - known
        if unknown:
            raise ValueError(f"unknown profiles: {', '.join(sorted(unknown))}")
        results = verify_matrix(revisions, args.reference_dir, args.project_dir, args.make, selected)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2

    print("\nRevision verification matrix")
    print(f"{'PROFILE':26} {'STATUS':8} DETAIL")
    for profile_id, status, detail in results:
        print(f"{profile_id:26} {status:8} {detail}")
    failed = any(status == "FAIL" for _, status, _ in results)
    missing = any(status == "MISSING" for _, status, _ in results)
    if failed or (args.require_all and missing):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
