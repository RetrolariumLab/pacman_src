#!/usr/bin/env python3
"""Classify a local NES ROM collection against the official revision matrix."""

from __future__ import annotations

import argparse
import json
import zlib
from dataclasses import dataclass
from pathlib import Path

from verify_revision_matrix import file_sha1, load_manifest


@dataclass(frozen=True)
class NesImage:
    path: Path
    header: bytes
    prg: bytes
    chr: bytes
    trailing: bytes
    mapper: int
    mirroring: str


def load_nes(path: Path) -> NesImage:
    data = path.read_bytes()
    if len(data) < 16 or data[:4] != b"NES\x1a":
        raise ValueError(f"not an iNES image: {path}")
    header = data[:16]
    trainer_size = 512 if header[6] & 0x04 else 0
    prg_size = header[4] * 16384
    chr_size = header[5] * 8192
    offset = 16 + trainer_size
    expected = offset + prg_size + chr_size
    if len(data) < expected:
        raise ValueError(f"truncated iNES payload: {path}")
    mapper = (header[6] >> 4) | (header[7] & 0xF0)
    mirroring = "four-screen" if header[6] & 0x08 else ("vertical" if header[6] & 0x01 else "horizontal")
    return NesImage(
        path, header, data[offset:offset + prg_size],
        data[offset + prg_size:expected], data[expected:], mapper, mirroring,
    )


def normalize_prg(prg: bytes) -> tuple[bytes, str]:
    if len(prg) == 32768:
        low, high = prg[:16384], prg[16384:]
        if low == high:
            return high, "mirrored 16 KiB PRG"
        different, _ = difference_runs(low, high)
        return high, f"32 KiB PRG; vector-bearing high bank compared; banks differ by {different} bytes"
    return prg, ""


def difference_runs(left: bytes, right: bytes) -> tuple[int, int]:
    changed = [index for index, (a, b) in enumerate(zip(left, right)) if a != b]
    changed.extend(range(min(len(left), len(right)), max(len(left), len(right))))
    if not changed:
        return 0, 0
    runs = 1 + sum(current != previous + 1 for previous, current in zip(changed, changed[1:]))
    return len(changed), runs


def changed_ranges(left: bytes, right: bytes) -> list[tuple[int, int]]:
    changed = [index for index, (a, b) in enumerate(zip(left, right)) if a != b]
    changed.extend(range(min(len(left), len(right)), max(len(left), len(right))))
    if not changed:
        return []
    ranges: list[tuple[int, int]] = []
    start = previous = changed[0]
    for current in changed[1:]:
        if current != previous + 1:
            ranges.append((start, previous + 1))
            start = current
        previous = current
    ranges.append((start, previous + 1))
    return ranges


def crc32(data: bytes) -> str:
    return f"{zlib.crc32(data) & 0xFFFFFFFF:08X}"


def analyze(collection: Path, manifest: Path, reference_dir: Path) -> list[dict[str, object]]:
    _, revisions = load_manifest(manifest)
    bases: dict[str, NesImage] = {}
    for revision in revisions:
        path = reference_dir / revision.rom
        if path.is_file() and file_sha1(path) == revision.sha1:
            bases[revision.profile_id] = load_nes(path)
    if not bases:
        raise ValueError("no verified official reference ROMs are available")

    rows: list[dict[str, object]] = []
    for path in sorted(collection.glob("*.nes"), key=lambda item: item.name.casefold()):
        image = load_nes(path)
        prg, normalization = normalize_prg(image.prg)
        comparisons = []
        for profile_id, base in bases.items():
            base_prg, _ = normalize_prg(base.prg)
            prg_bytes, prg_runs = difference_runs(prg, base_prg)
            chr_bytes, chr_runs = difference_runs(image.chr, base.chr)
            comparisons.append((prg_bytes + chr_bytes, prg_bytes, chr_bytes, prg_runs + chr_runs, profile_id))
        total, prg_bytes, chr_bytes, runs, closest = min(comparisons)
        base_prg, _ = normalize_prg(bases[closest].prg)
        prg_ranges = changed_ranges(prg, base_prg)
        notes = []
        if normalization:
            notes.append(normalization)
        if image.trailing:
            notes.append(f"{len(image.trailing)} trailing bytes")
        if total == 0:
            notes.append("payload-identical")
        rows.append({
            "filename": path.name,
            "sha1": file_sha1(path),
            "mapper": image.mapper,
            "mirroring": image.mirroring,
            "prg_size": len(image.prg),
            "chr_size": len(image.chr),
            "prg_crc32": crc32(prg),
            "chr_crc32": crc32(image.chr),
            "closest": closest,
            "prg_changed": prg_bytes,
            "chr_changed": chr_bytes,
            "changed_runs": runs,
            "notes": "; ".join(notes),
            "prg_ranges": prg_ranges,
        })
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--collection", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--reference-dir", type=Path, required=True)
    parser.add_argument("--json", action="store_true", dest="as_json")
    parser.add_argument("--details", action="store_true")
    parser.add_argument("--max-detail-runs", type=int, default=20)
    args = parser.parse_args()
    rows = analyze(args.collection, args.manifest, args.reference_dir)
    if args.as_json:
        print(json.dumps(rows, indent=2, ensure_ascii=False))
        return 0
    print("filename\tclosest\tPRG diff\tCHR diff\truns\tmapper\tPRG/CHR\tnotes")
    for row in rows:
        print(
            f"{row['filename']}\t{row['closest']}\t{row['prg_changed']}\t"
            f"{row['chr_changed']}\t{row['changed_runs']}\t{row['mapper']}\t"
            f"{row['prg_size']}/{row['chr_size']}\t{row['notes']}"
        )
        if args.details and row["prg_changed"]:
            cpu_base = 0xC000
            ranges = row["prg_ranges"]
            shown = ranges[:args.max_detail_runs]
            formatted = ", ".join(
                f"${cpu_base + start:04X}" if end == start + 1
                else f"${cpu_base + start:04X}-${cpu_base + end - 1:04X}"
                for start, end in shown
            )
            suffix = f", ... +{len(ranges) - len(shown)} runs" if len(ranges) > len(shown) else ""
            print(f"  PRG ranges: {formatted}{suffix}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
