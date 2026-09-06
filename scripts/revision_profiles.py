#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Revision:
    profile_id: str
    rom: str
    sha1: str
    sha256: str = ""
    ca65_revision: int = 0
    chr_source: str = "generated"
    runtime_smoke: str = ""


def load_manifest(path: Path) -> tuple[str, list[Revision]]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("format") != 2:
        raise ValueError("unsupported revision manifest format")
    default_profile = document.get("default_profile")
    rows = document.get("profiles")
    if not isinstance(default_profile, str) or not isinstance(rows, list) or not rows:
        raise ValueError("manifest needs default_profile and a non-empty profiles list")

    revisions: list[Revision] = []
    seen_ids: set[str] = set()
    seen_ca65_revisions: set[int] = set()
    for row in rows:
        try:
            revision = Revision(
                row["id"], row["rom"], row["sha1"].lower(),
                row["sha256"].lower(), row["ca65_revision"], row["chr_source"],
                row["runtime_smoke"],
            )
        except (KeyError, TypeError, AttributeError) as exc:
            raise ValueError(
                "each profile needs id, rom, sha1, sha256, ca65_revision, "
                "chr_source, and runtime_smoke fields"
            ) from exc
        if not all(
            isinstance(value, str) and value
            for value in (
                revision.profile_id, revision.rom, revision.sha1,
                revision.sha256, revision.runtime_smoke,
            )
        ):
            raise ValueError(
                "profile id, rom, sha1, sha256, and runtime_smoke "
                "must be non-empty strings"
            )
        if revision.profile_id in seen_ids:
            raise ValueError(f"duplicate revision profile: {revision.profile_id}")
        if not isinstance(revision.ca65_revision, int) or revision.ca65_revision < 0:
            raise ValueError(f"invalid ca65_revision for {revision.profile_id}")
        if revision.ca65_revision in seen_ca65_revisions:
            raise ValueError(f"duplicate ca65_revision: {revision.ca65_revision}")
        if revision.chr_source not in {"generated", "reference"}:
            raise ValueError(f"invalid chr_source for {revision.profile_id}")
        if len(revision.sha1) != 40 or any(
            char not in "0123456789abcdef" for char in revision.sha1
        ):
            raise ValueError(f"invalid SHA1 for {revision.profile_id}")
        if len(revision.sha256) != 64 or any(
            char not in "0123456789abcdef" for char in revision.sha256
        ):
            raise ValueError(f"invalid SHA256 for {revision.profile_id}")
        seen_ids.add(revision.profile_id)
        seen_ca65_revisions.add(revision.ca65_revision)
        revisions.append(revision)
    if default_profile not in seen_ids:
        raise ValueError(f"default profile is not declared: {default_profile}")
    return default_profile, revisions


def select_revision(path: Path, profile_id: str) -> Revision:
    _, revisions = load_manifest(path)
    for revision in revisions:
        if revision.profile_id == profile_id:
            return revision
    raise ValueError(f"unknown revision profile: {profile_id}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Read Pac-Man revision metadata.")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--print-default", action="store_true")
    args = parser.parse_args()
    try:
        default_profile, _ = load_manifest(args.manifest)
    except (OSError, ValueError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2
    if args.print_default:
        print(default_profile)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
