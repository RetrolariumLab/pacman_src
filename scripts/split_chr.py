#!/usr/bin/env python3
import pathlib
import os
import stat
import sys


def fail(msg: str) -> None:
    print(f"[ERROR] {msg}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: split_chr.py <original_rom.nes> <out_chr.chr>")

    rom_path = pathlib.Path(sys.argv[1])
    out_path = pathlib.Path(sys.argv[2])

    if not rom_path.exists():
        fail(f"ROM not found: {rom_path}")

    data = rom_path.read_bytes()
    if len(data) < 16:
        fail("invalid ROM: too small")

    header = data[:16]
    if header[0:4] != b"NES\x1a":
        fail("invalid ROM header: expected iNES signature")

    prg_banks = header[4]
    chr_banks = header[5]
    prg_size = prg_banks * 16_384
    chr_size = chr_banks * 8_192

    trainer = 512 if (header[6] & 0x04) else 0
    chr_start = 16 + trainer + prg_size
    chr_end = chr_start + chr_size

    if chr_size == 0:
        fail("ROM has no CHR banks (CHR RAM cartridge)")
    if chr_end > len(data):
        fail("ROM is truncated: CHR region exceeds file size")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    payload = data[chr_start:chr_end]

    temp_path = out_path.with_suffix(out_path.suffix + ".tmp")
    temp_path.write_bytes(payload)

    if out_path.exists():
        mode = out_path.stat().st_mode
        if not (mode & stat.S_IWRITE):
            try:
                out_path.chmod(mode | stat.S_IWRITE)
            except OSError:
                pass

    try:
        os.replace(temp_path, out_path)
    except OSError as exc:
        try:
            temp_path.unlink(missing_ok=True)
        except OSError:
            pass
        fail(
            f"cannot replace output file: {out_path} ({exc}). "
            "Close emulator/file lock and retry."
        )

    print(f"[OK] Extracted CHR: {out_path} ({chr_size} bytes)")


if __name__ == "__main__":
    main()
