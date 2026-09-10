#!/usr/bin/env python3
"""Prepare and validate a non-executed-EA relocation build."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from pathlib import Path


INCLUDE_RE = re.compile(r'^(?P<indent>\s*)\.include "(?P<path>[^"]+)"(?P<tail>.*)$')
VICE_LABEL_RE = re.compile(r"^al ([0-9A-Fa-f]{6}) \.([A-Za-z_][A-Za-z0-9_]*)$")
ORIGIN_RE = re.compile(r"^\.org \$C000$")
EA_DIRECTIVE = "    .byte $EA"
CPU_BASE = 0xC000
FIXED_POINTER = 0xFFF8
VECTOR_BASE = 0xFFFA
ALLOWED_SCRIPTS = {"00", "02", "04", "06", "08", "0A", "0C", "0E", "10", "FF"}


def sha1(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_json(path: Path, document: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")


def parse_modules(main_source: Path) -> list[str]:
    modules: list[str] = []
    for line in main_source.read_text(encoding="utf-8").splitlines():
        match = INCLUDE_RE.fullmatch(line)
        if match and match.group("path").endswith(".asm"):
            modules.append(match.group("path"))
    if len(modules) < 2 or modules[-1] != "data/tail_and_vectors.asm":
        raise ValueError("main source must end with data/tail_and_vectors.asm")
    return modules


def insert_origin_ea(source: str) -> str:
    output: list[str] = []
    inserted = 0
    for line in source.splitlines():
        output.append(line)
        if ORIGIN_RE.fullmatch(line):
            output.append(EA_DIRECTIVE)
            inserted += 1
    if inserted != 1:
        raise ValueError(f"expected one .org $C000 directive, found {inserted}")
    return "\n".join(output) + "\n"


def prepare_source(main_source: Path, output: Path, manifest_path: Path) -> dict[str, object]:
    project_root = main_source.resolve().parent.parent
    source_root = main_source.resolve().parent
    modules = parse_modules(main_source)
    active_modules = modules[:-1]
    generated_boot = output.parent / "boot_and_frame.asm"
    boot_source = source_root / modules[0]
    generated_boot.parent.mkdir(parents=True, exist_ok=True)
    generated_boot.write_text(
        insert_origin_ea(boot_source.read_text(encoding="utf-8")),
        encoding="utf-8",
        newline="\n",
    )

    anchors: list[dict[str, str]] = [
        {
            "id": "bank_origin",
            "kind": "before_module",
            "before_module": f"src/{modules[0]}",
        }
    ]
    generated_lines: list[str] = []
    module_index = 0
    for line in main_source.read_text(encoding="utf-8").splitlines():
        match = INCLUDE_RE.fullmatch(line)
        if match is None:
            generated_lines.append(line)
            continue
        include_path = match.group("path")
        generated_include = include_path
        if include_path == modules[0]:
            generated_include = generated_boot.name
        generated_lines.append(
            f'{match.group("indent")}.include "{generated_include}"'
            f'{match.group("tail")}'
        )
        if include_path.endswith(".asm"):
            if module_index < len(modules) - 2:
                generated_lines.append(EA_DIRECTIVE)
                anchors.append(
                    {
                        "id": (
                            "before_"
                            + modules[module_index + 1]
                            .removesuffix(".asm")
                            .replace("/", "_")
                        ),
                        "kind": "between_modules",
                        "after_module": f"src/{modules[module_index]}",
                        "before_module": f"src/{modules[module_index + 1]}",
                    }
                )
            module_index += 1
    if module_index != len(modules):
        raise ValueError("module include count changed while generating relocation source")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(generated_lines) + "\n", encoding="utf-8", newline="\n")

    manifest: dict[str, object] = {
        "format": 1,
        "description": (
            "Non-executed $EA bytes progressively shift every active fixed-bank "
            "module while preserving the fixed tail."
        ),
        "source": main_source.resolve().relative_to(project_root).as_posix(),
        "fill_byte": "$EA",
        "anchor_count": len(anchors),
        "anchors": anchors,
        "modules": [
            {
                "path": f"src/{module}",
                "expected_shift": index + 1,
            }
            for index, module in enumerate(active_modules)
        ],
        "tail_module": f"src/{modules[-1]}",
        "padding_label": "unused_bank_padding",
        "fixed_labels": ["tbl_maze_rle_stream_ptr"],
    }
    write_json(manifest_path, manifest)
    print(
        f"[OK] Prepared relocation source with {len(anchors)} non-executed "
        f"$EA anchors across {len(active_modules)} active modules."
    )
    return manifest


def load_labels(path: Path) -> dict[str, int]:
    labels: dict[str, int] = {}
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        match = VICE_LABEL_RE.fullmatch(line)
        if match:
            labels[match.group(2)] = int(match.group(1), 16)
        elif line.strip():
            raise ValueError(f"unsupported label line {path}:{line_number}: {line}")
    return labels


def load_label_paths(path: Path) -> dict[str, str]:
    document = json.loads(path.read_text(encoding="utf-8"))
    result = {item[1]: item[2] for item in document["renames"]}
    result.update({item[0]: item[1] for item in document["project_additions"]})
    return result


def read_prg(path: Path) -> bytes:
    payload = path.read_bytes()
    if len(payload) < 16 or payload[:4] != b"NES\x1A":
        raise ValueError(f"not an iNES ROM: {path}")
    trainer = 512 if payload[6] & 0x04 else 0
    prg_size = payload[4] * 16_384
    start = 16 + trainer
    return payload[start : start + prg_size]


def word(payload: bytes, address: int) -> int:
    offset = address - CPU_BASE
    return payload[offset] | payload[offset + 1] << 8


def verify_layout(
    manifest_path: Path,
    provenance_path: Path,
    base_labels_path: Path,
    candidate_labels_path: Path,
    base_rom_path: Path,
    candidate_rom_path: Path,
    probe_addresses_path: Path,
) -> None:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    base_labels = load_labels(base_labels_path)
    candidate_labels = load_labels(candidate_labels_path)
    label_paths = load_label_paths(provenance_path)
    module_shifts = {
        item["path"]: int(item["expected_shift"])
        for item in manifest["modules"]
    }
    checked = 0
    for name, source_path in label_paths.items():
        if source_path not in module_shifts or name not in base_labels:
            continue
        if name not in candidate_labels:
            raise ValueError(f"candidate build lost label: {name}")
        expected = base_labels[name] + module_shifts[source_path]
        if candidate_labels[name] != expected:
            raise ValueError(
                f"unexpected relocation for {name}: "
                f"${base_labels[name]:04X} -> ${candidate_labels[name]:04X}, "
                f"expected ${expected:04X}"
            )
        checked += 1
    if checked < 700:
        raise ValueError(f"too few relocated labels were checked: {checked}")

    anchor_count = int(manifest["anchor_count"])
    padding_label = str(manifest["padding_label"])
    if candidate_labels[padding_label] - base_labels[padding_label] != anchor_count:
        raise ValueError("unused padding did not absorb every relocation byte")
    for name in manifest["fixed_labels"]:
        if candidate_labels[name] != base_labels[name]:
            raise ValueError(f"fixed-tail label moved: {name}")

    candidate_prg = read_prg(candidate_rom_path)
    base_prg = read_prg(base_rom_path)
    if len(candidate_prg) != 16_384 or len(base_prg) != 16_384:
        raise ValueError("relocation test requires a 16 KiB NROM PRG")
    if candidate_prg == base_prg:
        raise ValueError("relocation candidate unexpectedly matches the base PRG")

    probe_addresses: list[int] = []
    for anchor in manifest["anchors"]:
        module = anchor["before_module"]
        names = [
            name for name, source_path in label_paths.items()
            if source_path == module and name in candidate_labels
        ]
        if not names:
            raise ValueError(f"no candidate labels found for anchor module: {module}")
        first_address = min(candidate_labels[name] for name in names)
        probe_address = first_address - 1
        if candidate_prg[probe_address - CPU_BASE] != 0xEA:
            raise ValueError(
                f"missing $EA before {module} at ${probe_address:04X}"
            )
        probe_addresses.append(probe_address)

    if len(probe_addresses) != len(set(probe_addresses)):
        raise ValueError("relocation probe addresses are not unique")
    probe_addresses_path.parent.mkdir(parents=True, exist_ok=True)
    probe_addresses_path.write_text(
        "".join(f"{address:04X}\n" for address in probe_addresses),
        encoding="ascii",
        newline="\n",
    )

    vectors = {
        VECTOR_BASE: "vec_nmi_handler",
        VECTOR_BASE + 2: "vec_reset_entry",
        VECTOR_BASE + 4: "vec_irq_handler",
    }
    for address, name in vectors.items():
        if word(candidate_prg, address) != candidate_labels[name]:
            raise ValueError(f"vector ${address:04X} does not follow relocated {name}")
    if word(candidate_prg, FIXED_POINTER) != candidate_labels["tbl_maze_rle_stream"]:
        raise ValueError("fixed maze pointer does not follow relocated maze data")
    print(
        f"[OK] Relocation layout: {anchor_count} hidden $EA bytes, "
        f"{checked} shifted labels, fixed pointer and vectors valid."
    )


def prepare_scenario(
    base_path: Path, candidate_rom: Path, output: Path, max_frames: int,
    heartbeat_interval: int,
) -> None:
    document = json.loads(base_path.read_text(encoding="utf-8"))
    scenarios: list[dict[str, object]] = []
    for source_scenario in document["scenarios"]:
        scenario = dict(source_scenario)
        if scenario["id"] == "natural-longplay":
            scenario["method"] = "29-anchor non-executed-EA relocation longplay"
            scenario["max_frames"] = max_frames
            scenario["heartbeat_interval"] = heartbeat_interval
        scenarios.append(scenario)
    output_document = {
        "format": document["format"],
        "rom_sha1": sha1(candidate_rom),
        "movie": document["movie"],
        "movie_sha1": document["movie_sha1"],
        "scenarios": scenarios,
    }
    write_json(output, output_document)
    print(
        f"[OK] Prepared relocation runtime manifest with a "
        f"{max_frames}-frame natural scenario."
    )


def rehash_manifest(base_path: Path, candidate_rom: Path, output: Path) -> None:
    document = json.loads(base_path.read_text(encoding="utf-8"))
    if "rom_sha1" not in document:
        raise ValueError(f"manifest has no rom_sha1 field: {base_path}")
    document["rom_sha1"] = sha1(candidate_rom)
    write_json(output, document)
    print(f"[OK] Rehashed runtime manifest for {candidate_rom.name}.")


def has_ordered_details(rows: list[dict[str, str]], details: list[str]) -> bool:
    position = 0
    for row in rows:
        if row["event"] == "stage_changed" and row["detail"] == details[position]:
            position += 1
            if position == len(details):
                return True
    return False


def validate_runtime(
    trace_path: Path, max_frames: int, heartbeat_interval: int,
    trace_dir: Path | None = None,
) -> None:
    with trace_path.open(encoding="utf-8", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows or rows[0]["event"] != "trace_start" or rows[-1]["event"] != "trace_end":
        raise ValueError("relocation trace did not complete cleanly")
    if int(rows[-1]["frame"]) != max_frames:
        raise ValueError("relocation trace ended at the wrong frame")
    probe_traces = [trace_path]
    if trace_dir is not None:
        probe_traces = sorted(trace_dir.glob("*.csv"))
        if not probe_traces:
            raise ValueError("relocation runtime trace directory is empty")
    for path in probe_traces:
        with path.open(encoding="utf-8", newline="") as stream:
            scenario_rows = csv.DictReader(stream)
            executed = [
                row["detail"] for row in scenario_rows
                if row["event"] == "relocation_probe_executed"
            ]
        if executed:
            raise ValueError(
                f"relocation probe executed in {path.name}: {', '.join(executed)}"
            )
    if not has_ordered_details(rows, ["00>01", "01>02", "02>03"]):
        raise ValueError("relocation longplay did not advance through four rounds")

    heartbeats = [row for row in rows if row["event"] == "heartbeat"]
    expected_frames = [0, *range(heartbeat_interval, max_frames + 1, heartbeat_interval)]
    actual_frames = [int(row["frame"]) for row in heartbeats]
    if actual_frames != expected_frames:
        raise ValueError("relocation heartbeat sequence is incomplete")
    counters = [int(row["detail"].removeprefix("frame_counter="), 16) for row in heartbeats]
    moving_pairs = sum(left != right for left, right in zip(counters, counters[1:]))
    if moving_pairs < max(1, len(counters) * 3 // 4):
        raise ValueError("game frame counter stopped advancing during relocation run")

    invalid_scripts = sorted({row["script"] for row in rows} - ALLOWED_SCRIPTS)
    if invalid_scripts:
        raise ValueError(f"invalid game scripts observed: {', '.join(invalid_scripts)}")
    meaningful = [
        int(row["frame"]) for row in rows
        if row["event"] not in {"trace_start", "trace_end", "heartbeat"}
    ]
    if not meaningful or max(meaningful) < max_frames - 10_000:
        raise ValueError("no late semantic activity in relocation longplay")
    print(
        f"[OK] Relocation runtime: four rounds, {len(heartbeats)} heartbeats, "
        f"semantic activity through frame {max(meaningful)}."
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    prepare = subparsers.add_parser("prepare")
    prepare.add_argument("--main", required=True, type=Path)
    prepare.add_argument("--output", required=True, type=Path)
    prepare.add_argument("--manifest", required=True, type=Path)

    verify = subparsers.add_parser("verify-layout")
    verify.add_argument("--manifest", required=True, type=Path)
    verify.add_argument("--provenance", required=True, type=Path)
    verify.add_argument("--base-labels", required=True, type=Path)
    verify.add_argument("--candidate-labels", required=True, type=Path)
    verify.add_argument("--base-rom", required=True, type=Path)
    verify.add_argument("--candidate-rom", required=True, type=Path)
    verify.add_argument("--probe-addresses-output", required=True, type=Path)

    scenario = subparsers.add_parser("prepare-scenario")
    scenario.add_argument("--base", required=True, type=Path)
    scenario.add_argument("--candidate-rom", required=True, type=Path)
    scenario.add_argument("--output", required=True, type=Path)
    scenario.add_argument("--max-frames", required=True, type=int)
    scenario.add_argument("--heartbeat-interval", required=True, type=int)

    rehash = subparsers.add_parser("rehash-manifest")
    rehash.add_argument("--base", required=True, type=Path)
    rehash.add_argument("--candidate-rom", required=True, type=Path)
    rehash.add_argument("--output", required=True, type=Path)

    runtime = subparsers.add_parser("validate-runtime")
    runtime.add_argument("--trace", required=True, type=Path)
    runtime.add_argument("--max-frames", required=True, type=int)
    runtime.add_argument("--heartbeat-interval", required=True, type=int)
    runtime.add_argument("--trace-dir", type=Path)
    args = parser.parse_args()

    if args.command == "prepare":
        prepare_source(args.main, args.output, args.manifest)
    elif args.command == "verify-layout":
        verify_layout(
            args.manifest, args.provenance, args.base_labels,
            args.candidate_labels, args.base_rom, args.candidate_rom,
            args.probe_addresses_output,
        )
    elif args.command == "prepare-scenario":
        prepare_scenario(
            args.base, args.candidate_rom, args.output,
            args.max_frames, args.heartbeat_interval,
        )
    elif args.command == "rehash-manifest":
        rehash_manifest(args.base, args.candidate_rom, args.output)
    else:
        validate_runtime(
            args.trace, args.max_frames, args.heartbeat_interval, args.trace_dir,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
