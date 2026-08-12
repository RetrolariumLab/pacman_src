#!/usr/bin/env python3
"""Prepare the local toolchain and build the instrumented FCEUX dependency."""

from __future__ import annotations

import argparse
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
    parser.add_argument("--repo", default="https://github.com/oranguthang/fceux_automation.git")
    parser.add_argument("--configuration", default="Release")
    parser.add_argument("--platform", default="x64")
    parser.add_argument("--toolset", default="v143")
    parser.add_argument("--msbuild", default="")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    for tool in (project_root / "bin" / "ca65.exe", project_root / "bin" / "ld65.exe"):
        if not tool.is_file():
            fail(f"Bundled tool not found: {tool}")

    fceux_dir = rooted(project_root, args.fceux_dir)
    solution = fceux_dir / "vc" / "vc14_fceux.sln"
    executable = fceux_dir / "vc" / args.platform / args.configuration / "fceux64.exe"

    if executable.is_file():
        print(f"[OK] Development tools are ready: {executable}")
        return 0

    if not fceux_dir.exists():
        git = shutil.which("git")
        if not git:
            fail("Git not found in PATH; it is required to clone fceux_automation.")
        fceux_dir.parent.mkdir(parents=True, exist_ok=True)
        run([git, "clone", args.repo, str(fceux_dir)], project_root)

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

    print(f"[OK] Development tools are ready: {executable}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
