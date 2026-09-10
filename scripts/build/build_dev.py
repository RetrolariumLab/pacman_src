#!/usr/bin/env python3
"""Prepare the local toolchain and build the instrumented FCEUX dependency."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def rooted(project_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else (project_root / path).resolve()


def run(command: list[str], cwd: Path) -> None:
    print("[RUN]", " ".join(command))
    result = subprocess.run(command, cwd=str(cwd), check=False)
    if result.returncode != 0:
        fail(f"Command failed with exit code {result.returncode}")


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_toolchain_manifest(path: Path) -> dict[str, dict[str, object]]:
    document = json.loads(path.read_text(encoding="utf-8"))
    components = document.get("components")
    hosts = document.get("hosts")
    if document.get("format") != 1 or not isinstance(components, dict):
        raise ValueError("unsupported toolchain manifest")
    if not isinstance(hosts, list) or not hosts:
        raise ValueError("toolchain manifest requires at least one tested host")
    for host in hosts:
        if not isinstance(host, dict) or not all(
            isinstance(host.get(field), str) and host[field]
            for field in ("os", "architecture", "shell", "python_tested", "status")
        ):
            raise ValueError("toolchain manifest contains an incomplete host")
    required = {"ca65", "ld65", "fceux_automation"}
    if set(components) != required:
        raise ValueError(
            "toolchain components must be exactly: "
            + ", ".join(sorted(required))
        )
    for component_id, component in components.items():
        if not isinstance(component, dict):
            raise ValueError(f"toolchain component must be an object: {component_id}")
        digest = component.get("binary_sha256")
        if not isinstance(digest, str) or len(digest) != 64 or any(
            char not in "0123456789abcdef" for char in digest
        ):
            raise ValueError(f"invalid binary_sha256 for {component_id}")
        if not isinstance(component.get("source"), str) or not component["source"]:
            raise ValueError(f"missing source for {component_id}")
        if not isinstance(component.get("source_commit"), str) or not component["source_commit"]:
            raise ValueError(f"missing source_commit for {component_id}")
        if not isinstance(component.get("provenance"), str) or not component["provenance"]:
            raise ValueError(f"missing provenance for {component_id}")
    for component_id in ("ca65", "ld65"):
        component = components[component_id]
        if not isinstance(component.get("path"), str):
            raise ValueError(f"missing path for {component_id}")
        if not isinstance(component.get("version"), str):
            raise ValueError(f"missing version for {component_id}")
    for field in ("configuration", "platform", "toolset"):
        if not isinstance(components["fceux_automation"].get(field), str):
            raise ValueError(f"missing {field} for fceux_automation")
    fceux_commit = components["fceux_automation"]["source_commit"]
    if len(fceux_commit) != 40 or any(
        char not in "0123456789abcdef" for char in fceux_commit
    ):
        raise ValueError("fceux_automation source_commit must be a full Git object ID")
    return components


def verify_file_hash(path: Path, expected: str, component_id: str) -> None:
    if not path.is_file():
        raise ValueError(f"missing {component_id} binary: {path}")
    actual = file_sha256(path)
    if actual != expected:
        raise ValueError(f"{component_id} SHA256 {actual}, expected {expected}")


def command_output(command: list[str], cwd: Path) -> str:
    completed = subprocess.run(
        command, cwd=str(cwd), capture_output=True, text=True, check=False,
    )
    if completed.returncode:
        raise ValueError(
            f"command exited {completed.returncode}: {' '.join(command)}"
        )
    return (completed.stdout + completed.stderr).strip()


def verify_bundled_tool(
    project_root: Path, component_id: str, component: dict[str, object],
) -> None:
    path = (project_root / str(component["path"])).resolve()
    verify_file_hash(path, str(component["binary_sha256"]), component_id)
    actual_version = command_output([str(path), "--version"], project_root).splitlines()[0]
    if actual_version != component.get("version"):
        raise ValueError(
            f"{component_id} version {actual_version!r}, "
            f"expected {component.get('version')!r}"
        )


def verify_fceux_source(
    fceux_dir: Path, component: dict[str, object],
) -> None:
    head = command_output(["git", "rev-parse", "HEAD"], fceux_dir)
    expected_head = str(component["source_commit"])
    if head != expected_head:
        raise ValueError(f"FCEUX commit {head}, expected {expected_head}")
    tracked_changes = command_output(
        ["git", "status", "--porcelain", "--untracked-files=no"], fceux_dir,
    )
    if tracked_changes:
        raise ValueError("FCEUX checkout has tracked local changes")


def verify_fceux_checkout(
    fceux_dir: Path, executable: Path, component: dict[str, object],
) -> None:
    verify_fceux_source(fceux_dir, component)
    verify_file_hash(
        executable, str(component["binary_sha256"]), "fceux_automation",
    )


def supports_cpp_toolset(msbuild: Path, platform: str, toolset: str) -> bool:
    try:
        installation = msbuild.resolve().parents[3]
    except IndexError:
        return False
    vc_targets = installation / "MSBuild" / "Microsoft" / "VC"
    return any(
        (version_dir / "Microsoft.Cpp.Default.props").is_file()
        and (
            version_dir
            / "Platforms"
            / platform
            / "PlatformToolsets"
            / toolset
            / "Toolset.props"
        ).is_file()
        for version_dir in vc_targets.glob("v*")
    )


def discover_msbuild(explicit: str, platform: str, toolset: str) -> Path:
    if explicit:
        candidate = Path(explicit)
        if candidate.is_file() and supports_cpp_toolset(candidate, platform, toolset):
            return candidate.resolve()
        fail(f"Configured MSBuild lacks the {toolset} C++ toolset for {platform}: {candidate}")

    program_files_x86 = os.environ.get("ProgramFiles(x86)")
    if program_files_x86:
        vswhere = Path(program_files_x86) / "Microsoft Visual Studio" / "Installer" / "vswhere.exe"
        if vswhere.is_file():
            query = subprocess.run(
                [
                    str(vswhere),
                    "-all",
                    "-products",
                    "*",
                    "-find",
                    r"MSBuild\**\Bin\MSBuild.exe",
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            matches = [Path(line.strip()) for line in query.stdout.splitlines() if line.strip()]
            for candidate in reversed(matches):
                if candidate.is_file() and supports_cpp_toolset(candidate, platform, toolset):
                    return candidate.resolve()

    for name in ("MSBuild.exe", "msbuild"):
        found = shutil.which(name)
        if found and supports_cpp_toolset(Path(found), platform, toolset):
            return Path(found).resolve()

    program_files = os.environ.get("ProgramFiles")
    if program_files:
        editions = ("Community", "Professional", "Enterprise", "BuildTools")
        for edition in editions:
            candidate = (
                Path(program_files)
                / "Microsoft Visual Studio"
                / "2022"
                / edition
                / "MSBuild"
                / "Current"
                / "Bin"
                / "MSBuild.exe"
            )
            if candidate.is_file() and supports_cpp_toolset(candidate, platform, toolset):
                return candidate.resolve()

    fail(
        f"MSBuild with the {toolset} C++ toolset for {platform} was not found. "
        "Install Visual Studio 2022 Build Tools with the C++ desktop workload."
    )
    raise AssertionError


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fceux-dir", default="../fceux_automation")
    parser.add_argument("--manifest", default="config/toolchain.json")
    parser.add_argument("--repo", default="")
    parser.add_argument("--configuration", default="Release")
    parser.add_argument("--platform", default="x64")
    parser.add_argument("--toolset", default="v143")
    parser.add_argument("--msbuild", default="")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parents[2]
    try:
        components = load_toolchain_manifest(rooted(project_root, args.manifest))
        verify_bundled_tool(project_root, "ca65", components["ca65"])
        verify_bundled_tool(project_root, "ld65", components["ld65"])
    except (OSError, ValueError, json.JSONDecodeError) as error:
        fail(str(error))

    fceux = components["fceux_automation"]
    repository = str(fceux["source"])
    if args.repo and args.repo != repository:
        fail(f"FCEUX repository {args.repo!r}, expected manifest value {repository!r}")
    expected_options = {
        "configuration": str(fceux["configuration"]),
        "platform": str(fceux["platform"]),
        "toolset": str(fceux["toolset"]),
    }
    for option, expected in expected_options.items():
        actual = getattr(args, option)
        if actual != expected:
            fail(f"FCEUX {option} {actual!r}, expected manifest value {expected!r}")

    fceux_dir = rooted(project_root, args.fceux_dir)
    solution = fceux_dir / "vc" / "vc14_fceux.sln"
    executable = fceux_dir / "vc" / args.platform / args.configuration / "fceux64.exe"

    if executable.is_file():
        try:
            verify_fceux_checkout(fceux_dir, executable, fceux)
        except ValueError as error:
            fail(str(error))
        print(f"[OK] Development tools are ready: {executable}")
        return 0

    if not fceux_dir.exists():
        git = shutil.which("git")
        if not git:
            fail("Git not found in PATH; it is required to clone fceux_automation.")
        fceux_dir.parent.mkdir(parents=True, exist_ok=True)
        run([git, "clone", "--no-checkout", repository, str(fceux_dir)], project_root)
        run(
            [git, "checkout", "--detach", str(fceux["source_commit"])],
            fceux_dir,
        )

    try:
        verify_fceux_source(fceux_dir, fceux)
    except ValueError as error:
        fail(str(error))

    if not solution.is_file():
        fail(f"FCEUX solution not found: {solution}")

    msbuild = discover_msbuild(args.msbuild, args.platform, args.toolset)
    run(
        [
            str(msbuild),
            str(solution),
            "/m",
            f"/p:Configuration={args.configuration}",
            f"/p:Platform={args.platform}",
            f"/p:PlatformToolset={args.toolset}",
        ],
        project_root,
    )
    if not executable.is_file():
        fail(f"Build completed but the FCEUX executable was not produced: {executable}")

    try:
        verify_fceux_checkout(fceux_dir, executable, fceux)
    except ValueError as error:
        fail(str(error))

    print(f"[OK] Development tools are ready: {executable}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
