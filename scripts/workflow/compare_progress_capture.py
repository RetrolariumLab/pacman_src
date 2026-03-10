#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
from collections import Counter
from pathlib import Path


DIFF_RE = re.compile(r"^(screen_diff|memory_diff)\s+frame\s+(\d+)\s*$", re.IGNORECASE)
ASCII_SPRITE_RE = re.compile(
    r"^(\d+):\s+x=\s*(\d+)\s+y=\s*(\d+)\s+tile=([0-9A-Fa-f]{2})\s+attr=([0-9A-Fa-f]{2})\s+ch=(.)\s*$"
)


def list_frame_files(folder: Path, ext: str) -> dict[int, Path]:
    out: dict[int, Path] = {}
    if not folder.is_dir():
        return out
    for p in folder.glob(f"*.{ext}"):
        if not p.is_file():
            continue
        try:
            frame = int(p.stem)
        except ValueError:
            continue
        out[frame] = p
    return out


def remap_frame_keys(src: dict[int, Path], offset: int) -> dict[int, Path]:
    if offset == 0:
        return dict(src)
    out: dict[int, Path] = {}
    for frame, path in src.items():
        out[frame - offset] = path
    return out


def remap_frame_set(src: set[int], offset: int) -> set[int]:
    if offset == 0:
        return set(src)
    return {frame - offset for frame in src}


def parse_diff_report(path: Path) -> tuple[set[int], set[int]]:
    screen_diff_frames: set[int] = set()
    memory_diff_frames: set[int] = set()
    if not path.is_file():
        return screen_diff_frames, memory_diff_frames
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        m = DIFF_RE.match(line)
        if not m:
            continue
        kind = m.group(1).lower()
        frame = int(m.group(2))
        if kind == "screen_diff":
            screen_diff_frames.add(frame)
        elif kind == "memory_diff":
            memory_diff_frames.add(frame)
    return screen_diff_frames, memory_diff_frames


def bytes_equal(a: Path, b: Path) -> bool:
    return a.read_bytes() == b.read_bytes()


def diff_bytes(run_blob: bytes, ref_blob: bytes) -> list[tuple[int, int, int]]:
    diffs: list[tuple[int, int, int]] = []
    n = min(len(run_blob), len(ref_blob))
    for i in range(n):
        rb = run_blob[i]
        ob = ref_blob[i]
        if rb != ob:
            diffs.append((i, rb, ob))
    if len(run_blob) != len(ref_blob):
        longer, marker = (run_blob, -1) if len(run_blob) > len(ref_blob) else (ref_blob, -2)
        for i in range(n, len(longer)):
            b = longer[i]
            if marker == -1:
                diffs.append((i, b, -1))
            else:
                diffs.append((i, -2, b))
    return diffs


def build_ranges(addresses: list[int]) -> list[tuple[int, int]]:
    if not addresses:
        return []
    out: list[tuple[int, int]] = []
    start = addresses[0]
    prev = addresses[0]
    for addr in addresses[1:]:
        if addr == prev + 1:
            prev = addr
            continue
        out.append((start, prev))
        start = addr
        prev = addr
    out.append((start, prev))
    return out


def parse_ascii_dump(path: Path) -> dict[str, object]:
    raw_lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    out: dict[str, object] = {
        "frame": None,
        "selected_nt": None,
        "best_nt": None,
        "refresh_addr": None,
        "scroll_x": None,
        "scroll_y": None,
        "composite": [],
        "screen_with_sprites": [],
        "sprites": [],
    }

    if not raw_lines:
        return out

    header = raw_lines[0].strip()
    for token in header.split():
        if token.startswith("frame="):
            try:
                out["frame"] = int(token.split("=", 1)[1])
            except ValueError:
                pass
        elif token.startswith("selected_nt="):
            try:
                out["selected_nt"] = int(token.split("=", 1)[1])
            except ValueError:
                pass
        elif token.startswith("best_nt="):
            try:
                out["best_nt"] = int(token.split("=", 1)[1])
            except ValueError:
                pass
        elif token.startswith("refresh_addr="):
            raw = token.split("=", 1)[1]
            try:
                out["refresh_addr"] = int(raw, 16)
            except ValueError:
                pass
        elif token.startswith("scroll_x="):
            try:
                out["scroll_x"] = int(token.split("=", 1)[1])
            except ValueError:
                pass
        elif token.startswith("scroll_y="):
            try:
                out["scroll_y"] = int(token.split("=", 1)[1])
            except ValueError:
                pass

    section = ""
    screen_lines: list[str] = []
    composite_lines: list[str] = []
    nt_sections: dict[str, list[str]] = {"nt0": [], "nt1": [], "nt2": [], "nt3": []}
    sprites: list[tuple[int, int, int, int, str]] = []

    for raw in raw_lines[1:]:
        line = raw.rstrip("\r\n")
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            section = stripped[1:-1].strip().lower()
            continue

        if section == "composite":
            if line != "":
                composite_lines.append(line)
        elif section == "screen_with_sprites":
            if line != "":
                screen_lines.append(line)
        elif section in nt_sections:
            if line != "":
                nt_sections[section].append(line)
        elif section == "sprites":
            if stripped == "" or stripped == "(none)":
                continue
            m = ASCII_SPRITE_RE.match(stripped)
            if not m:
                continue
            x = int(m.group(2))
            y = int(m.group(3))
            tile = int(m.group(4), 16)
            attr = int(m.group(5), 16)
            ch = m.group(6)
            sprites.append((x, y, tile, attr, ch))

    out["composite"] = composite_lines
    if composite_lines:
        screen_lines = composite_lines
    elif not screen_lines:
        best_nt = out.get("best_nt")
        if isinstance(best_nt, int) and 0 <= best_nt <= 3 and nt_sections.get(f"nt{best_nt}"):
            screen_lines = nt_sections[f"nt{best_nt}"]
        elif nt_sections["nt0"]:
            screen_lines = nt_sections["nt0"]
    out["screen_with_sprites"] = screen_lines
    out["sprites"] = sprites
    return out


def diff_ascii_screens(
    run_lines: list[str], ref_lines: list[str]
) -> tuple[list[tuple[int, int, str, str]], int, int]:
    tile_diffs: list[tuple[int, int, str, str]] = []

    def norm_ch(ch: str) -> str:
        # In Pac-Man captures, blank-looking background may be emitted as either
        # space or '-' depending on tile IDs/palette usage; treat them as equal.
        if ch == "-":
            return " "
        return ch

    height = min(len(run_lines), len(ref_lines))
    width = 32

    for y in range(height):
        run_row = run_lines[y]
        ref_row = ref_lines[y]
        row_w = min(len(run_row), len(ref_row), width)
        for x in range(row_w):
            rc = run_row[x]
            oc = ref_row[x]
            if norm_ch(rc) != norm_ch(oc):
                tile_diffs.append((y, x, rc, oc))
        if len(run_row) != len(ref_row):
            max_w = max(len(run_row), len(ref_row), width)
            for x in range(row_w, min(max_w, width)):
                rc = run_row[x] if x < len(run_row) else " "
                oc = ref_row[x] if x < len(ref_row) else " "
                if norm_ch(rc) != norm_ch(oc):
                    tile_diffs.append((y, x, rc, oc))

    if len(run_lines) != len(ref_lines):
        for y in range(height, min(max(len(run_lines), len(ref_lines)), 30)):
            run_row = run_lines[y] if y < len(run_lines) else ""
            ref_row = ref_lines[y] if y < len(ref_lines) else ""
            for x in range(width):
                rc = run_row[x] if x < len(run_row) else " "
                oc = ref_row[x] if x < len(ref_row) else " "
                if norm_ch(rc) != norm_ch(oc):
                    tile_diffs.append((y, x, rc, oc))

    run_counts = Counter(norm_ch(c) for c in "".join(run_lines))
    ref_counts = Counter(norm_ch(c) for c in "".join(ref_lines))
    shift_char_count = 0
    count_delta_chars = 0
    chars = set(run_counts) | set(ref_counts)
    for ch in chars:
        if run_counts[ch] == ref_counts[ch]:
            if run_counts[ch] > 0:
                run_pos = []
                ref_pos = []
                for y, row in enumerate(run_lines[:30]):
                    for x, c in enumerate(row[:32]):
                        if norm_ch(c) == ch:
                            run_pos.append((y, x))
                for y, row in enumerate(ref_lines[:30]):
                    for x, c in enumerate(row[:32]):
                        if norm_ch(c) == ch:
                            ref_pos.append((y, x))
                if run_pos != ref_pos:
                    shift_char_count += 1
        else:
            count_delta_chars += 1

    return tile_diffs, shift_char_count, count_delta_chars


def diff_ascii_sprites(
    run_sprites: list[tuple[int, int, int, int, str]],
    ref_sprites: list[tuple[int, int, int, int, str]],
) -> tuple[list[tuple[int, int, int, int, str]], list[tuple[int, int, int, int, str]], list[tuple[int, int, tuple[int, int, str], tuple[int, int, str]]]]:
    run_by_pos = {(x, y): (tile, attr, ch) for x, y, tile, attr, ch in run_sprites}
    ref_by_pos = {(x, y): (tile, attr, ch) for x, y, tile, attr, ch in ref_sprites}

    missing: list[tuple[int, int, int, int, str]] = []
    extra: list[tuple[int, int, int, int, str]] = []
    mismatch: list[tuple[int, int, tuple[int, int, str], tuple[int, int, str]]] = []

    for (x, y), rv in run_by_pos.items():
        ov = ref_by_pos.get((x, y))
        if ov is None:
            extra.append((x, y, rv[0], rv[1], rv[2]))
        elif rv != ov:
            mismatch.append((x, y, rv, ov))

    for (x, y), ov in ref_by_pos.items():
        if (x, y) not in run_by_pos:
            missing.append((x, y, ov[0], ov[1], ov[2]))

    return missing, extra, mismatch


def screen_has_visible_content(lines: list[str]) -> bool:
    for row in lines:
        for ch in row:
            if ch not in (" ", "-"):
                return True
    return False


def format_ascii_frame_block(parsed: dict[str, object], title: str) -> list[str]:
    lines: list[str] = [title]
    frame = parsed.get("frame")
    selected_nt = parsed.get("selected_nt")
    refresh_addr = parsed.get("refresh_addr")
    scroll_x = parsed.get("scroll_x")
    scroll_y = parsed.get("scroll_y")
    lines.append(
        " ".join(
            [
                f"frame={frame if frame is not None else 'unknown'}",
                f"selected_nt={selected_nt if selected_nt is not None else 'unknown'}",
                f"refresh_addr={refresh_addr if refresh_addr is not None else 'unknown'}",
                f"scroll_x={scroll_x if scroll_x is not None else 'unknown'}",
                f"scroll_y={scroll_y if scroll_y is not None else 'unknown'}",
            ]
        )
    )
    lines.append("[screen_with_sprites]")
    for row in parsed.get("screen_with_sprites", []):
        lines.append(str(row))
    lines.append("[sprites]")
    sprites = parsed.get("sprites", [])
    if not sprites:
        lines.append("(none)")
    else:
        for x, y, tile, attr, ch in sprites:
            lines.append(f"x={x:3d} y={y:3d} tile={tile:02X} attr={attr:02X} ch={ch}")
    return lines


def main() -> int:
    ap = argparse.ArgumentParser(description="Compare FCEUX run capture against reference by frame.")
    ap.add_argument("--run-dir", required=True, help="Run capture directory (contains screens/, memory/, diff_report.txt).")
    ap.add_argument("--reference-dir", required=True, help="Reference capture directory.")
    ap.add_argument("--output-dir", required=True, help="Directory for report files.")
    ap.add_argument("--label", default="c0_longplay", help="Output file label.")
    ap.add_argument(
        "--run-frame-offset",
        type=int,
        default=0,
        help="Align run frame N to reference frame N-offset (e.g. 1 => compare ref 46 with run 47).",
    )
    ap.add_argument(
        "--ascii-sample-count",
        type=int,
        default=10,
        help="How many ASCII mismatch samples to include in the text report.",
    )
    ap.add_argument(
        "--ascii-sample-step",
        type=int,
        default=5,
        help="Take every N-th ASCII mismatch frame for the text report.",
    )
    args = ap.parse_args()

    run_dir = Path(args.run_dir)
    ref_dir = Path(args.reference_dir)
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    run_screens_raw = list_frame_files(run_dir / "screens", "png")
    ref_screens = list_frame_files(ref_dir / "screens", "png")
    run_memory_raw = list_frame_files(run_dir / "memory", "bin")
    ref_memory = list_frame_files(ref_dir / "memory", "bin")
    run_ascii_raw = list_frame_files(run_dir / "ascii", "txt")
    ref_ascii = list_frame_files(ref_dir / "ascii", "txt")
    screen_diff_frames_raw, memory_diff_frames_raw = parse_diff_report(run_dir / "diff_report.txt")

    run_screens = remap_frame_keys(run_screens_raw, args.run_frame_offset)
    run_memory = remap_frame_keys(run_memory_raw, args.run_frame_offset)
    run_ascii = remap_frame_keys(run_ascii_raw, args.run_frame_offset)
    screen_diff_frames = remap_frame_set(screen_diff_frames_raw, args.run_frame_offset)
    memory_diff_frames = remap_frame_set(memory_diff_frames_raw, args.run_frame_offset)

    all_frames = sorted(
        set(run_screens)
        | set(ref_screens)
        | set(run_memory)
        | set(ref_memory)
        | set(run_ascii)
        | set(ref_ascii)
        | screen_diff_frames
        | memory_diff_frames
    )

    rows: list[dict[str, object]] = []
    screen_mismatch: list[int] = []
    memory_mismatch: list[int] = []
    frame_memdiff_rows: list[dict[str, object]] = []
    addr_counter: Counter[int] = Counter()
    addr_first_last: dict[int, tuple[int, int]] = {}
    first_memdiff_frame: int | None = None
    first_memdiff_examples: list[tuple[int, int, int]] = []
    per_frame_memory_diff_counts: dict[int, int] = {}

    ascii_rows: list[dict[str, object]] = []
    ascii_detail_rows: list[dict[str, object]] = []
    ascii_mismatch_frames: list[int] = []
    ascii_tile_mismatch_frames: list[int] = []
    ascii_sprite_mismatch_frames: list[int] = []
    ascii_scroll_mismatch_frames: list[int] = []
    ascii_tile_pos_counter: Counter[tuple[int, int]] = Counter()
    ascii_sprite_pos_counter: Counter[tuple[int, int]] = Counter()
    ascii_tile_diffs_total = 0
    ascii_sprite_events_total = 0
    first_ascii_mismatch_dump: tuple[int, dict[str, object], dict[str, object], int, int, int] | None = None
    ascii_mismatch_dumps: list[tuple[int, dict[str, object], dict[str, object], int, int, int]] = []

    for frame in all_frames:
        run_screen = run_screens.get(frame)
        ref_screen = ref_screens.get(frame)
        run_mem = run_memory.get(frame)
        ref_mem = ref_memory.get(frame)

        screen_in_run = run_screen is not None
        screen_in_ref = ref_screen is not None
        memory_in_run = run_mem is not None
        memory_in_ref = ref_mem is not None

        screen_equal: bool | None = None
        memory_equal: bool | None = None

        if screen_in_run and screen_in_ref:
            screen_equal = bytes_equal(run_screen, ref_screen)
            if not screen_equal:
                screen_mismatch.append(frame)

        if memory_in_run and memory_in_ref:
            memory_equal = bytes_equal(run_mem, ref_mem)
            if not memory_equal:
                memory_mismatch.append(frame)
                run_blob = run_mem.read_bytes()
                ref_blob = ref_mem.read_bytes()
                diffs = diff_bytes(run_blob, ref_blob)
                per_frame_memory_diff_counts[frame] = len(diffs)
                for addr, run_v, ref_v in diffs:
                    addr_counter[addr] += 1
                    if addr in addr_first_last:
                        first_f, _ = addr_first_last[addr]
                        addr_first_last[addr] = (first_f, frame)
                    else:
                        addr_first_last[addr] = (frame, frame)
                    frame_memdiff_rows.append(
                        {
                            "frame": frame,
                            "address_hex": f"{addr:04X}",
                            "address_dec": addr,
                            "run": "" if run_v < 0 else f"{run_v:02X}",
                            "ref": "" if ref_v < 0 else f"{ref_v:02X}",
                            "kind": "length" if (run_v < 0 or ref_v < 0) else "byte",
                        }
                    )
                if first_memdiff_frame is None:
                    first_memdiff_frame = frame
                    first_memdiff_examples = diffs[:64]
            else:
                per_frame_memory_diff_counts[frame] = 0

        rows.append(
            {
                "frame": frame,
                "screen_in_run": int(screen_in_run),
                "screen_in_ref": int(screen_in_ref),
                "screen_equal": "" if screen_equal is None else int(screen_equal),
                "memory_in_run": int(memory_in_run),
                "memory_in_ref": int(memory_in_ref),
                "memory_equal": "" if memory_equal is None else int(memory_equal),
                "screen_diff_reported": int(frame in screen_diff_frames),
                "memory_diff_reported": int(frame in memory_diff_frames),
            }
        )

        run_ascii_path = run_ascii.get(frame)
        ref_ascii_path = ref_ascii.get(frame)

        ascii_in_run = run_ascii_path is not None
        ascii_in_ref = ref_ascii_path is not None
        ascii_equal: bool | None = None
        tile_diff_count = 0
        tile_shift_chars = 0
        tile_count_delta_chars = 0
        sprite_missing_count = 0
        sprite_extra_count = 0
        sprite_mismatch_count = 0
        scroll_equal: bool | None = None
        scroll_dx = 0
        scroll_dy = 0
        run_scroll_x: int | None = None
        run_scroll_y: int | None = None
        ref_scroll_x: int | None = None
        ref_scroll_y: int | None = None

        if ascii_in_run and ascii_in_ref:
            run_dump = parse_ascii_dump(run_ascii_path)
            ref_dump = parse_ascii_dump(ref_ascii_path)

            run_screen_lines = run_dump.get("screen_with_sprites", [])
            ref_screen_lines = ref_dump.get("screen_with_sprites", [])
            run_sprites = run_dump.get("sprites", [])
            ref_sprites = ref_dump.get("sprites", [])
            if isinstance(run_dump.get("scroll_x"), int):
                run_scroll_x = int(run_dump["scroll_x"])
            if isinstance(run_dump.get("scroll_y"), int):
                run_scroll_y = int(run_dump["scroll_y"])
            if isinstance(ref_dump.get("scroll_x"), int):
                ref_scroll_x = int(ref_dump["scroll_x"])
            if isinstance(ref_dump.get("scroll_y"), int):
                ref_scroll_y = int(ref_dump["scroll_y"])

            if isinstance(run_screen_lines, list) and isinstance(ref_screen_lines, list):
                tile_diffs, tile_shift_chars, tile_count_delta_chars = diff_ascii_screens(run_screen_lines, ref_screen_lines)
                run_has_content = screen_has_visible_content(run_screen_lines)
                ref_has_content = screen_has_visible_content(ref_screen_lines)
            else:
                tile_diffs = []
                run_has_content = False
                ref_has_content = False

            if isinstance(run_sprites, list) and isinstance(ref_sprites, list):
                sprite_missing, sprite_extra, sprite_mismatch = diff_ascii_sprites(run_sprites, ref_sprites)
            else:
                sprite_missing, sprite_extra, sprite_mismatch = [], [], []

            tile_diff_count = len(tile_diffs)
            sprite_missing_count = len(sprite_missing)
            sprite_extra_count = len(sprite_extra)
            sprite_mismatch_count = len(sprite_mismatch)
            if (
                run_scroll_x is not None
                and run_scroll_y is not None
                and ref_scroll_x is not None
                and ref_scroll_y is not None
            ):
                scroll_dx = run_scroll_x - ref_scroll_x
                scroll_dy = run_scroll_y - ref_scroll_y
                scroll_equal = (scroll_dx == 0 and scroll_dy == 0)
                if (not run_has_content) and (not ref_has_content):
                    # Ignore pure scroll mismatch on fully blank frames.
                    scroll_equal = True
            else:
                scroll_equal = None

            ascii_equal = (
                tile_diff_count == 0
                and sprite_missing_count == 0
                and sprite_extra_count == 0
                and sprite_mismatch_count == 0
                and (scroll_equal is not False)
            )

            if not ascii_equal:
                ascii_mismatch_frames.append(frame)
                if tile_diff_count > 0:
                    ascii_tile_mismatch_frames.append(frame)
                if (sprite_missing_count + sprite_extra_count + sprite_mismatch_count) > 0:
                    ascii_sprite_mismatch_frames.append(frame)
                if scroll_equal is False:
                    ascii_scroll_mismatch_frames.append(frame)

                ascii_tile_diffs_total += tile_diff_count
                ascii_sprite_events_total += sprite_missing_count + sprite_extra_count + sprite_mismatch_count
                if first_ascii_mismatch_dump is None:
                    first_ascii_mismatch_dump = (
                        frame,
                        run_dump,
                        ref_dump,
                        tile_diff_count,
                        sprite_missing_count + sprite_extra_count + sprite_mismatch_count,
                        tile_shift_chars,
                    )
                ascii_mismatch_dumps.append(
                    (
                        frame,
                        run_dump,
                        ref_dump,
                        tile_diff_count,
                        sprite_missing_count + sprite_extra_count + sprite_mismatch_count,
                        tile_shift_chars,
                    )
                )

                for y, x, rc, oc in tile_diffs[:32]:
                    ascii_tile_pos_counter[(y, x)] += 1
                    ascii_detail_rows.append(
                        {
                            "frame": frame,
                            "kind": "tile_mismatch",
                            "y": y,
                            "x": x,
                            "run": rc,
                            "ref": oc,
                            "run_tile_hex": "",
                            "ref_tile_hex": "",
                        }
                    )

                for x, y, tile, attr, ch in sprite_missing[:24]:
                    ascii_sprite_pos_counter[(x, y)] += 1
                    ascii_detail_rows.append(
                        {
                            "frame": frame,
                            "kind": "sprite_missing",
                            "y": y,
                            "x": x,
                            "run": "",
                            "ref": ch,
                            "run_tile_hex": "",
                            "ref_tile_hex": f"{tile:02X}/{attr:02X}",
                        }
                    )
                for x, y, tile, attr, ch in sprite_extra[:24]:
                    ascii_sprite_pos_counter[(x, y)] += 1
                    ascii_detail_rows.append(
                        {
                            "frame": frame,
                            "kind": "sprite_extra",
                            "y": y,
                            "x": x,
                            "run": ch,
                            "ref": "",
                            "run_tile_hex": f"{tile:02X}/{attr:02X}",
                            "ref_tile_hex": "",
                        }
                    )
                for x, y, rv, ov in sprite_mismatch[:24]:
                    ascii_sprite_pos_counter[(x, y)] += 1
                    ascii_detail_rows.append(
                        {
                            "frame": frame,
                            "kind": "sprite_mismatch",
                            "y": y,
                            "x": x,
                            "run": rv[2],
                            "ref": ov[2],
                            "run_tile_hex": f"{rv[0]:02X}/{rv[1]:02X}",
                            "ref_tile_hex": f"{ov[0]:02X}/{ov[1]:02X}",
                        }
                    )
                if scroll_equal is False:
                    ascii_detail_rows.append(
                        {
                            "frame": frame,
                            "kind": "scroll_mismatch",
                            "y": "",
                            "x": "",
                            "run": f"{run_scroll_x},{run_scroll_y}",
                            "ref": f"{ref_scroll_x},{ref_scroll_y}",
                            "run_tile_hex": "",
                            "ref_tile_hex": "",
                        }
                    )

        ascii_rows.append(
            {
                "frame": frame,
                "ascii_in_run": int(ascii_in_run),
                "ascii_in_ref": int(ascii_in_ref),
                "ascii_equal": "" if ascii_equal is None else int(ascii_equal),
                "run_scroll_x": "" if run_scroll_x is None else run_scroll_x,
                "run_scroll_y": "" if run_scroll_y is None else run_scroll_y,
                "ref_scroll_x": "" if ref_scroll_x is None else ref_scroll_x,
                "ref_scroll_y": "" if ref_scroll_y is None else ref_scroll_y,
                "scroll_equal": "" if scroll_equal is None else int(scroll_equal),
                "scroll_dx": scroll_dx,
                "scroll_dy": scroll_dy,
                "tile_diff_count": tile_diff_count,
                "tile_shift_char_count": tile_shift_chars,
                "tile_count_delta_chars": tile_count_delta_chars,
                "sprite_missing_count": sprite_missing_count,
                "sprite_extra_count": sprite_extra_count,
                "sprite_mismatch_count": sprite_mismatch_count,
            }
        )

    def first_or_empty(items: list[int]) -> str:
        return "" if not items else f"{items[0]:06d}"

    summary = {
        "label": args.label,
        "run_dir": str(run_dir),
        "reference_dir": str(ref_dir),
        "run_frame_offset": args.run_frame_offset,
        "frames_total": len(all_frames),
        "run_screens": len(run_screens_raw),
        "ref_screens": len(ref_screens),
        "run_memory": len(run_memory_raw),
        "ref_memory": len(ref_memory),
        "run_ascii": len(run_ascii_raw),
        "ref_ascii": len(ref_ascii),
        "screen_compared": sum(1 for r in rows if r["screen_equal"] != ""),
        "memory_compared": sum(1 for r in rows if r["memory_equal"] != ""),
        "ascii_compared": sum(1 for r in ascii_rows if r["ascii_equal"] != ""),
        "screen_mismatch_count": len(screen_mismatch),
        "memory_mismatch_count": len(memory_mismatch),
        "ascii_mismatch_count": len(ascii_mismatch_frames),
        "ascii_tile_mismatch_frames": len(ascii_tile_mismatch_frames),
        "ascii_sprite_mismatch_frames": len(ascii_sprite_mismatch_frames),
        "ascii_scroll_mismatch_frames": len(ascii_scroll_mismatch_frames),
        "first_screen_mismatch": first_or_empty(screen_mismatch),
        "first_memory_mismatch": first_or_empty(memory_mismatch),
        "first_ascii_mismatch": first_or_empty(ascii_mismatch_frames),
        "screen_diff_report_lines": len(screen_diff_frames),
        "memory_diff_report_lines": len(memory_diff_frames),
        "memory_byte_diffs_total": sum(per_frame_memory_diff_counts.values()),
        "first_memory_mismatch_byte_count": 0
        if first_memdiff_frame is None
        else per_frame_memory_diff_counts.get(first_memdiff_frame, 0),
        "hotspot_unique_addresses": len(addr_counter),
        "ascii_tile_diffs_total": ascii_tile_diffs_total,
        "ascii_sprite_events_total": ascii_sprite_events_total,
    }

    txt_path = out_dir / f"progress_report_{args.label}.txt"
    csv_path = out_dir / f"progress_frames_{args.label}.csv"
    json_path = out_dir / f"progress_report_{args.label}.json"
    memdiff_csv_path = out_dir / f"progress_memdiff_{args.label}.csv"
    hotspots_csv_path = out_dir / f"progress_hotspots_{args.label}.csv"
    ascii_csv_path = out_dir / f"progress_ascii_frames_{args.label}.csv"
    ascii_details_csv_path = out_dir / f"progress_ascii_details_{args.label}.csv"
    ascii_tile_hotspots_csv_path = out_dir / f"progress_ascii_tile_hotspots_{args.label}.csv"
    ascii_sprite_hotspots_csv_path = out_dir / f"progress_ascii_sprite_hotspots_{args.label}.csv"
    ascii_first_mismatch_txt_path = out_dir / f"progress_ascii_first_mismatch_{args.label}.txt"
    md_path = out_dir / f"progress_report_{args.label}.md"

    txt_lines = [f"{k}={v}" for k, v in summary.items()]
    txt_path.write_text("\n".join(txt_lines) + "\n", encoding="utf-8")

    with csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "frame",
                "screen_in_run",
                "screen_in_ref",
                "screen_equal",
                "memory_in_run",
                "memory_in_ref",
                "memory_equal",
                "screen_diff_reported",
                "memory_diff_reported",
            ],
        )
        w.writeheader()
        w.writerows(rows)

    with memdiff_csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["frame", "address_hex", "address_dec", "run", "ref", "kind"],
        )
        w.writeheader()
        w.writerows(frame_memdiff_rows)

    hotspots_rows = []
    for addr, count in addr_counter.most_common():
        first_frame, last_frame = addr_first_last.get(addr, ("", ""))
        hotspots_rows.append(
            {
                "address_hex": f"{addr:04X}",
                "address_dec": addr,
                "diff_frames_count": count,
                "first_frame": first_frame,
                "last_frame": last_frame,
            }
        )

    with hotspots_csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["address_hex", "address_dec", "diff_frames_count", "first_frame", "last_frame"],
        )
        w.writeheader()
        w.writerows(hotspots_rows)

    with ascii_csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "frame",
                "ascii_in_run",
                "ascii_in_ref",
                "ascii_equal",
                "run_scroll_x",
                "run_scroll_y",
                "ref_scroll_x",
                "ref_scroll_y",
                "scroll_equal",
                "scroll_dx",
                "scroll_dy",
                "tile_diff_count",
                "tile_shift_char_count",
                "tile_count_delta_chars",
                "sprite_missing_count",
                "sprite_extra_count",
                "sprite_mismatch_count",
            ],
        )
        w.writeheader()
        w.writerows(ascii_rows)

    with ascii_details_csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=["frame", "kind", "y", "x", "run", "ref", "run_tile_hex", "ref_tile_hex"],
        )
        w.writeheader()
        w.writerows(ascii_detail_rows)

    ascii_tile_hotspots_rows = [
        {"y": y, "x": x, "diff_frames_count": count}
        for (y, x), count in ascii_tile_pos_counter.most_common()
    ]
    with ascii_tile_hotspots_csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["y", "x", "diff_frames_count"])
        w.writeheader()
        w.writerows(ascii_tile_hotspots_rows)

    ascii_sprite_hotspots_rows = [
        {"x": x, "y": y, "diff_frames_count": count}
        for (x, y), count in ascii_sprite_pos_counter.most_common()
    ]
    with ascii_sprite_hotspots_csv_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["x", "y", "diff_frames_count"])
        w.writeheader()
        w.writerows(ascii_sprite_hotspots_rows)

    ascii_first_lines: list[str] = []
    if first_ascii_mismatch_dump is None:
        ascii_first_lines.append("No ASCII mismatch found.")
    else:
        sample_step = max(1, args.ascii_sample_step)
        sample_count = max(1, args.ascii_sample_count)
        sample_index = 0
        sample_written = 0
        ascii_first_lines.append(f"ascii_mismatch_total={len(ascii_mismatch_dumps)}")
        ascii_first_lines.append(f"sample_step={sample_step}")
        ascii_first_lines.append(f"sample_count={sample_count}")
        ascii_first_lines.append("")
        while sample_index < len(ascii_mismatch_dumps) and sample_written < sample_count:
            frame, run_dump, ref_dump, tile_diff_count, sprite_event_count, shift_chars = ascii_mismatch_dumps[sample_index]
            ascii_first_lines.append(f"sample={sample_written + 1}")
            ascii_first_lines.append(f"mismatch_frame={frame:06d}")
            ascii_first_lines.append(f"tile_diff_count={tile_diff_count}")
            ascii_first_lines.append(f"sprite_event_count={sprite_event_count}")
            ascii_first_lines.append(f"tile_shift_char_count={shift_chars}")
            ascii_first_lines.append("")
            ascii_first_lines.extend(format_ascii_frame_block(ref_dump, "expected:"))
            ascii_first_lines.append("")
            ascii_first_lines.extend(format_ascii_frame_block(run_dump, "actual:"))
            ascii_first_lines.append("")
            ascii_first_lines.append("=" * 64)
            ascii_first_lines.append("")
            sample_written += 1
            sample_index += sample_step
    ascii_first_mismatch_txt_path.write_text("\n".join(ascii_first_lines) + "\n", encoding="utf-8")

    first_ranges: list[str] = []
    if first_memdiff_frame is not None:
        first_addrs = sorted([a for a, _, _ in first_memdiff_examples])
        ranges = build_ranges(first_addrs)
        first_ranges = [f"${a:04X}-${b:04X}" if a != b else f"${a:04X}" for a, b in ranges[:24]]

    md_lines = [
        f"# Progress Report: {args.label}",
        "",
        "## Summary",
    ]
    md_lines.extend([f"- `{k}`: `{v}`" for k, v in summary.items()])
    md_lines.extend(["", "## First Memory Mismatch Snapshot"])
    if first_memdiff_frame is None:
        md_lines.append("- No memory mismatch found.")
    else:
        md_lines.append(f"- `frame`: `{first_memdiff_frame:06d}`")
        md_lines.append(f"- `byte_diffs`: `{per_frame_memory_diff_counts.get(first_memdiff_frame, 0)}`")
        if first_ranges:
            md_lines.append(f"- `changed_ranges(sample)`: `{', '.join(first_ranges)}`")
        md_lines.append("")
        md_lines.append("| addr | run | ref |")
        md_lines.append("|---|---|---|")
        for addr, run_v, ref_v in first_memdiff_examples[:32]:
            rv = "--" if run_v < 0 else f"{run_v:02X}"
            ov = "--" if ref_v < 0 else f"{ref_v:02X}"
            md_lines.append(f"| `{addr:04X}` | `{rv}` | `{ov}` |")
    md_lines.extend(["", "## Top Memory Hotspots"])
    if not hotspots_rows:
        md_lines.append("- No hotspots.")
    else:
        md_lines.append("| addr | diff_frames | first | last |")
        md_lines.append("|---|---:|---:|---:|")
        for row in hotspots_rows[:25]:
            md_lines.append(
                f"| `{row['address_hex']}` | `{row['diff_frames_count']}` | `{int(row['first_frame']):06d}` | `{int(row['last_frame']):06d}` |"
            )
    md_lines.extend(["", "## ASCII Diff Summary"])
    md_lines.append(f"- `ascii_mismatch_frames`: `{len(ascii_mismatch_frames)}`")
    md_lines.append(f"- `first_ascii_mismatch`: `{summary['first_ascii_mismatch']}`")
    md_lines.append(f"- `tile_diff_frames`: `{len(ascii_tile_mismatch_frames)}`")
    md_lines.append(f"- `sprite_diff_frames`: `{len(ascii_sprite_mismatch_frames)}`")
    md_lines.append(f"- `tile_diffs_total`: `{ascii_tile_diffs_total}`")
    md_lines.append(f"- `sprite_events_total`: `{ascii_sprite_events_total}`")
    md_lines.extend(["", "### Top ASCII Tile Hotspots"])
    if not ascii_tile_hotspots_rows:
        md_lines.append("- No tile hotspots.")
    else:
        md_lines.append("| y | x | diff_frames |")
        md_lines.append("|---:|---:|---:|")
        for row in ascii_tile_hotspots_rows[:25]:
            md_lines.append(f"| `{row['y']}` | `{row['x']}` | `{row['diff_frames_count']}` |")
    md_lines.extend(["", "### Top ASCII Sprite Hotspots"])
    if not ascii_sprite_hotspots_rows:
        md_lines.append("- No sprite hotspots.")
    else:
        md_lines.append("| x | y | diff_frames |")
        md_lines.append("|---:|---:|---:|")
        for row in ascii_sprite_hotspots_rows[:25]:
            md_lines.append(f"| `{row['x']}` | `{row['y']}` | `{row['diff_frames_count']}` |")
    md_path.write_text("\n".join(md_lines) + "\n", encoding="utf-8")

    json_path.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"[OK] Summary: {txt_path}")
    print(f"[OK] Frame CSV: {csv_path}")
    print(f"[OK] MemDiff CSV: {memdiff_csv_path}")
    print(f"[OK] Hotspots CSV: {hotspots_csv_path}")
    print(f"[OK] ASCII Frame CSV: {ascii_csv_path}")
    print(f"[OK] ASCII Details CSV: {ascii_details_csv_path}")
    print(f"[OK] ASCII Tile Hotspots CSV: {ascii_tile_hotspots_csv_path}")
    print(f"[OK] ASCII Sprite Hotspots CSV: {ascii_sprite_hotspots_csv_path}")
    print(f"[OK] ASCII First Mismatch TXT: {ascii_first_mismatch_txt_path}")
    print(f"[OK] Markdown: {md_path}")
    print(f"[OK] JSON: {json_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
