#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "workflow"))

from verify_revision_matrix import file_sha1, file_sha256, load_manifest  # noqa: E402


def parse_result(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        key, separator, value = line.partition("=")
        if not separator or not key:
            raise ValueError(f"invalid smoke result line: {line!r}")
        result[key] = value
    return result


def validate_result(
    result: dict[str, str], scenario: dict[str, object],
) -> tuple[int, int]:
    required = {
        "frames", "nmi_hits", "menu_hit", "oam_value", "oam_uniform",
        "oam_first_difference",
    }
    missing = sorted(required - set(result))
    if missing:
        raise ValueError(f"capture lacks fields: {', '.join(missing)}")
    try:
        frames = int(result["frames"])
        nmi_hits = int(result["nmi_hits"])
        oam_value = int(result["oam_value"])
        first_difference = int(result["oam_first_difference"])
    except ValueError as error:
        raise ValueError("capture contains a non-integer numeric field") from error
    if result["menu_hit"] not in {"true", "false"} or result["oam_uniform"] not in {
        "true", "false",
    }:
        raise ValueError("capture contains an invalid Boolean field")
    if result["menu_hit"] != "true":
        raise ValueError("title menu was not reached")
    if frames < 0 or frames > int(scenario["max_frames"]):
        raise ValueError(f"title menu frame {frames} exceeds the scenario budget")
    if nmi_hits <= 0:
        raise ValueError("no NMI execution was observed")
    if result["oam_uniform"] != "true" or first_difference != -1:
        raise ValueError(f"shadow OAM is not uniform; first difference {first_difference}")
    expected_oam = int(scenario["title_oam_fill"])
    if oam_value != expected_oam:
        raise ValueError(f"shadow OAM value {oam_value}, expected {expected_oam}")
    return frames, nmi_hits


def validate_scenarios(
    rows: object, revision_by_id: dict[str, object], require_all: bool,
) -> list[dict[str, object]]:
    if not isinstance(rows, list):
        raise ValueError("smoke profiles must be a list")
    scenarios: list[dict[str, object]] = []
    seen: set[str] = set()
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError("each smoke profile must be an object")
        profile_id = row.get("id")
        if not isinstance(profile_id, str) or not profile_id:
            raise ValueError("each smoke profile needs a non-empty id")
        if profile_id in seen:
            raise ValueError(f"duplicate smoke profile: {profile_id}")
        revision = revision_by_id.get(profile_id)
        if revision is None:
            raise ValueError(f"smoke profile is absent from revision manifest: {profile_id}")
        if row.get("scenario") != revision.runtime_smoke:
            raise ValueError(
                f"runtime smoke mismatch for {profile_id}: "
                f"{row.get('scenario')} != {revision.runtime_smoke}"
            )
        if not isinstance(row.get("max_frames"), int) or row["max_frames"] <= 0:
            raise ValueError(f"invalid max_frames for {profile_id}")
        if not isinstance(row.get("title_oam_fill"), int) or not (
            0 <= row["title_oam_fill"] <= 0xFF
        ):
            raise ValueError(f"invalid title_oam_fill for {profile_id}")
        seen.add(profile_id)
        scenarios.append(row)
    if require_all:
        missing = sorted(set(revision_by_id) - seen)
        if missing:
            raise ValueError(
                f"supported profiles lack direct runtime smoke: {', '.join(missing)}"
            )
    return scenarios


def main() -> int:
    parser = argparse.ArgumentParser(description="Run revision ROM boot and OAM smoke tests in FCEUX.")
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
        scenarios = validate_scenarios(
            document["profiles"], revision_by_id, args.require_all,
        )
        for required in (args.fceux, args.lua):
            if not required.is_file():
                raise ValueError(f"missing smoke-test input: {required}")
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 2

    args.output_dir.mkdir(parents=True, exist_ok=True)
    statuses: list[tuple[str, str, str]] = []
    for scenario in scenarios:
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
        actual_sha256 = file_sha256(reference_rom)
        if actual_sha256 != revision.sha256:
            statuses.append((profile_id, "FAIL", f"reference SHA256 {actual_sha256}"))
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
            frames, nmi_hits = validate_result(result, scenario)
        except (OSError, ValueError) as exc:
            statuses.append((profile_id, "FAIL", str(exc)))
            continue
        statuses.append((profile_id, "PASS", f"menu frame {frames}, {nmi_hits} NMI"))

    print("\nRevision FCEUX smoke matrix")
    print(f"{'PROFILE':26} {'STATUS':8} DETAIL")
    for profile_id, status, detail in statuses:
        print(f"{profile_id:26} {status:8} {detail}")
    failed = any(status == "FAIL" for _, status, _ in statuses)
    missing = any(status == "MISSING" for _, status, _ in statuses)
    return 1 if failed or (args.require_all and missing) else 0


if __name__ == "__main__":
    raise SystemExit(main())
