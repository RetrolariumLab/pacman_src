#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

from verify_revision_matrix import file_sha1, load_manifest


def parse_result(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        key, separator, value = line.partition("=")
        if not separator or not key:
            raise ValueError(f"invalid smoke result line: {line!r}")
        result[key] = value
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Run regional ROM boot and OAM smoke tests in FCEUX.")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--scenarios", type=Path, required=True)
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--project-dir", type=Path, required=True)
    parser.add_argument("--fceux", type=Path, required=True)
    parser.add_argument("--lua", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--make", default="make")
    parser.add_argument("--require-all", action="store_true")
    args = parser.parse_args()

    try:
        _, revisions = load_manifest(args.manifest)
        revision_by_id = {revision.profile_id: revision for revision in revisions}
        document = json.loads(args.scenarios.read_text(encoding="utf-8"))
        if document.get("format") != 1 or not isinstance(document.get("profiles"), list):
            raise ValueError("unsupported smoke scenario manifest")
        for required in (args.fceux, args.lua):
            if not required.is_file():
                raise ValueError(f"missing smoke-test input: {required}")
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2

    args.output_dir.mkdir(parents=True, exist_ok=True)
    statuses: list[tuple[str, str, str]] = []
    for scenario in document["profiles"]:
        profile_id = scenario.get("id")
        revision = revision_by_id.get(profile_id)
        if revision is None:
            statuses.append((str(profile_id), "FAIL", "profile is absent from revision manifest"))
            continue
        reference_rom = args.reference_dir / revision.rom
        if not reference_rom.is_file():
            statuses.append((profile_id, "MISSING", revision.rom))
            continue
        actual_sha1 = file_sha1(reference_rom)
        if actual_sha1 != revision.sha1:
            statuses.append((profile_id, "FAIL", f"reference SHA1 {actual_sha1}"))
            continue

        print(f"[RUN] {profile_id}: build symbols and boot title in FCEUX", flush=True)
        build = subprocess.run([
            args.make, "symbols-revision", f"REVISION={profile_id}",
            f"REVISION_REFERENCE_DIR={args.reference_dir.resolve()}",
        ], cwd=args.project_dir, check=False)
        if build.returncode:
            statuses.append((profile_id, "FAIL", f"symbol build exited {build.returncode}"))
            continue

        result_path = args.output_dir / f"{profile_id}.txt"
        result_path.unlink(missing_ok=True)
        environment = os.environ.copy()
        environment.update(
            PACMAN_REVISION_SMOKE_RESULT=str(result_path.resolve()).replace("\\", "/"),
            PACMAN_REVISION_SMOKE_MAX_FRAMES=str(scenario["max_frames"]),
            PACMAN_REVISION_SMOKE_OAM_FILL=str(scenario["title_oam_fill"]),
        )
        rom = args.project_dir / "build" / "revisions" / profile_id / "pacman.nes"
        completed = subprocess.run([
            str(args.fceux.resolve()), "-lua", str(args.lua.resolve()),
            "-max-frames", str(scenario["max_frames"] + 2), "-turbo", "1", "-nothrottle", "1",
            str(rom.resolve()),
        ], cwd=args.project_dir, env=environment, check=False)
        if completed.returncode or not result_path.is_file():
            statuses.append((profile_id, "FAIL", f"FCEUX exited {completed.returncode}; no result"))
            continue
        try:
            result = parse_result(result_path)
        except (OSError, ValueError) as exc:
            statuses.append((profile_id, "FAIL", str(exc)))
            continue
        if result.get("status") != "PASS":
            statuses.append((profile_id, "FAIL", f"menu={result.get('menu_hit')}, OAM mismatches={result.get('oam_mismatches')}"))
        else:
            statuses.append((profile_id, "PASS", f"menu frame {result['frames']}, {result['nmi_hits']} NMI"))

    print("\nRegional FCEUX smoke matrix")
    print(f"{'PROFILE':26} {'STATUS':8} DETAIL")
    for profile_id, status, detail in statuses:
        print(f"{profile_id:26} {status:8} {detail}")
    failed = any(status == "FAIL" for _, status, _ in statuses)
    missing = any(status == "MISSING" for _, status, _ in statuses)
    return 1 if failed or (args.require_all and missing) else 0


if __name__ == "__main__":
    raise SystemExit(main())
