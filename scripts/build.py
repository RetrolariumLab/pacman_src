#!/usr/bin/env python3
from __future__ import annotations

import math
import os
import subprocess
import sys
from pathlib import Path
from shutil import which


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def resolve_cl65(project_dir: Path) -> str | None:
    candidates = [
        project_dir / "cc65-snapshot-win64" / "bin" / "cl65.exe",
        project_dir / "cc65-snapshot-win64" / "bin" / "cl65",
        project_dir / "bin" / "cl65.exe",
        project_dir / "bin" / "cl65",
    ]
    for candidate in candidates:
        if candidate.is_file():
            return str(candidate)
    return which("cl65")


def build_with_cl65(
    cl65_path: str,
    src_dir: Path,
    cfg: Path,
    tmp_rom: Path,
    toolchain_home: Path,
) -> tuple[bool, str]:
    print("[INFO] Building PRG with cc65 toolchain...")
    cmd = [
        cl65_path,
        "-O",
        f"-I{src_dir}",
        "-t",
        "nes",
        "-C",
        str(cfg),
        str(src_dir / "main.c"),
        str(src_dir / "neslib.c"),
        "-o",
        str(tmp_rom),
    ]
    env = os.environ.copy()
    env["CC65_HOME"] = str(toolchain_home)
    asminc_dir = toolchain_home / "asminc"
    if asminc_dir.is_dir():
        current_inc = env.get("CA65_INC", "")
        sep = ";" if os.name == "nt" else ":"
        env["CA65_INC"] = (
            f"{asminc_dir}{sep}{current_inc}" if current_inc else str(asminc_dir)
        )
    result = subprocess.run(cmd, check=False, env=env, capture_output=True)
    if result.returncode == 0:
        return True, ""
    raw = result.stderr or result.stdout or b""
    details = raw.decode("utf-8", errors="replace").strip()
    return False, details


def build_from_listing(project_dir: Path, out_rom: Path, chr_rom: Path) -> bool:
    listing = project_dir / "bank_FF.asm"
    builder = project_dir / "scripts" / "ghidra" / "build_reference_rom.py"
    if not builder.is_file() or not listing.is_file():
        return False
    print("[WARN] Falling back to listing-based build (bank_FF.asm).")
    cmd = [
        sys.executable,
        str(builder),
        str(listing),
        "-o",
        str(out_rom),
        "--chr",
        str(chr_rom),
    ]
    result = subprocess.run(cmd, check=False)
    return result.returncode == 0


def main() -> int:
    project_dir = Path(__file__).resolve().parent.parent
    src_dir = project_dir / "src"
    tmp_rom = project_dir / "pacman_c_tmp.nes"
    out_rom = project_dir / "pacman_c.nes"
    chr_rom = project_dir / "pacman.chr"
    cfg = src_dir / "nrom128.cfg"

    cl65_path = resolve_cl65(project_dir)
    if not cl65_path:
        fail("cl65 not found. Place cl65(.exe) in bin/ or add it to PATH.")
    if not chr_rom.is_file():
        fail(f"CHR ROM not found: {chr_rom}")
    if cl65_path and cfg.is_file():
        cl65_bin = Path(cl65_path).resolve()
        toolchain_home = cl65_bin.parent.parent
        c_ok, c_err = build_with_cl65(
            cl65_path,
            src_dir,
            cfg,
            tmp_rom,
            toolchain_home,
        )
        if c_ok:
            print(r"[INFO] Injecting CHR bank from pacman.chr...")
            tmp_bytes = tmp_rom.read_bytes()
            chr_bytes = chr_rom.read_bytes()

            if len(tmp_bytes) < 16:
                fail("Invalid temporary NES ROM.")

            prg = tmp_bytes[16:]
            if not prg:
                fail("Invalid PRG payload size.")

            header = bytearray(tmp_bytes[:16])
            header[4] = 1
            header[5] = math.ceil(len(chr_bytes) / 8192.0)
            header[6] = 0
            header[7] = 0

            out_bytes = bytes(header) + prg + chr_bytes
            out_rom.write_bytes(out_bytes)

            if tmp_rom.exists():
                tmp_rom.unlink()

            print(f"[OK] Build completed: {out_rom}")
            return 0
        if c_err:
            lines = [ln.strip() for ln in c_err.splitlines() if ln.strip()]
            msg = lines[-1] if lines else "unknown error"
            print(f"[WARN] cc65 build failed: {msg}")

    if build_from_listing(project_dir, out_rom, chr_rom):
        print(f"[OK] Build completed via fallback: {out_rom}")
        return 0

    fail("Build failed with both cc65 and listing fallback paths.")


if __name__ == "__main__":
    raise SystemExit(main())
