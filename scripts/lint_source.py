#!/usr/bin/env python3
"""Run fast source and documentation invariant checks."""

from __future__ import annotations

import re
import subprocess
import sys
from collections import Counter
from pathlib import Path


ASM_LINE_LIMIT = 700
APPROVED_EVIDENCE_TAGS = {
    "OBS",
    "ASSUME",
    "WHY?",
    "UNKNOWN",
    "BUG?",
    "UNUSED",
}
UNRESOLVED_EVIDENCE_TAGS = {"ASSUME", "WHY?", "UNKNOWN", "BUG?", "UNUSED"}
TEXT_SUFFIXES = {
    ".asm",
    ".cfg",
    ".fm2",
    ".inc",
    ".json",
    ".md",
    ".py",
    ".txt",
}
TEXT_FILENAMES = {".gitattributes", ".gitignore", "Makefile"}

DEFINITION_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*(?::|=)")
ADDRESS_NAME_RE = re.compile(
    r"(?:^|_)(?:[0-9A-Fa-f]{4,6})(?=_|$)"
)
EVIDENCE_TAG_RE = re.compile(r"!\(([^)]+)\)")
REGISTRY_ID_RE = re.compile(r"\b(?:RAM|SND|CODE|DATA)-\d{3}\b")
REGISTRY_HEADING_RE = re.compile(
    r"^### ((?:RAM|SND|CODE|DATA)-\d{3})\b", re.MULTILINE
)
RAW_HARDWARE_OPERAND_RE = re.compile(
    r"^\s*[A-Z]{3}\s+\$(?:200[0-7]|401[4-7])\b"
)
JSR_RE = re.compile(r"^\s*JSR\s+([A-Za-z_][A-Za-z0-9_]*)\b")
SUB_LABEL_RE = re.compile(r"^(sub_[A-Za-z0-9_]+):")


class LintResult:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.checked_text_files = 0
        self.checked_asm_modules = 0

    def error(self, path: Path | str, message: str, line: int | None = None) -> None:
        location = Path(path).as_posix()
        if line is not None:
            location += f":{line}"
        self.errors.append(f"{location}: {message}")


def git_source_files(project_root: Path) -> list[Path]:
    command = [
        "git",
        "ls-files",
        "--cached",
        "--others",
        "--exclude-standard",
        "-z",
    ]
    completed = subprocess.run(
        command,
        cwd=project_root,
        check=False,
        capture_output=True,
    )
    if completed.returncode != 0:
        message = completed.stderr.decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"git ls-files failed: {message}")

    paths: list[Path] = []
    for raw_path in completed.stdout.split(b"\0"):
        if not raw_path:
            continue
        relative = Path(raw_path.decode("utf-8", errors="strict"))
        absolute = project_root / relative
        if absolute.is_file():
            paths.append(relative)
    return sorted(set(paths), key=lambda path: path.as_posix())


def is_text_path(path: Path) -> bool:
    return path.name in TEXT_FILENAMES or path.suffix.lower() in TEXT_SUFFIXES


def read_text(project_root: Path, path: Path, result: LintResult) -> str | None:
    data = (project_root / path).read_bytes()
    try:
        return data.decode("utf-8", errors="strict")
    except UnicodeDecodeError as error:
        result.error(path, f"text file is not valid UTF-8: {error}")
        return None


def check_text_format(path: Path, text: str, result: LintResult) -> None:
    result.checked_text_files += 1
    if not text.endswith("\n"):
        result.error(path, "text file must end with one newline")
    elif text.endswith("\n\n"):
        result.error(path, "text file has a blank line at EOF")

    for line_number, line in enumerate(text.splitlines(), start=1):
        if line.endswith((" ", "\t")):
            result.error(path, "trailing whitespace", line_number)


def source_lines(text: str) -> list[tuple[int, str]]:
    lines: list[tuple[int, str]] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        code = line.split(";", 1)[0].rstrip()
        lines.append((line_number, code))
    return lines


def check_asm_file(
    path: Path,
    text: str,
    result: LintResult,
    sub_labels: dict[str, tuple[Path, int]],
    jsr_targets: dict[str, list[tuple[Path, int]]],
) -> None:
    if path.suffix.lower() == ".asm":
        result.checked_asm_modules += 1
        line_count = len(text.splitlines())
        if line_count > ASM_LINE_LIMIT:
            result.error(
                path,
                f"ASM module has {line_count} lines; limit is {ASM_LINE_LIMIT}",
            )

    for line_number, code in source_lines(text):
        if not code:
            continue

        definition = DEFINITION_RE.match(code)
        if definition is not None:
            symbol = definition.group(1)
            address_match = ADDRESS_NAME_RE.search(symbol)
            if address_match is not None:
                result.error(
                    path,
                    f"active symbol embeds address-like segment: {symbol}",
                    line_number,
                )

        sub_label = SUB_LABEL_RE.match(code)
        if sub_label is not None:
            name = sub_label.group(1)
            if name in sub_labels:
                previous_path, previous_line = sub_labels[name]
                result.error(
                    path,
                    f"duplicate subroutine label {name}; first at "
                    f"{previous_path.as_posix()}:{previous_line}",
                    line_number,
                )
            else:
                sub_labels[name] = (path, line_number)

        jsr = JSR_RE.match(code)
        if jsr is not None:
            target = jsr.group(1)
            jsr_targets.setdefault(target, []).append((path, line_number))
            if not target.startswith("sub_"):
                result.error(
                    path,
                    f"direct JSR target must use sub_ prefix: {target}",
                    line_number,
                )

        if RAW_HARDWARE_OPERAND_RE.match(code) is not None:
            result.error(
                path,
                f"raw NES hardware operand; use hardware.inc symbol: {code.strip()}",
                line_number,
            )


def check_evidence(
    path: Path,
    text: str,
    registry_ids: set[str],
    result: LintResult,
) -> None:
    for line_number, line in enumerate(text.splitlines(), start=1):
        if re.search(r"\bbzk\b", line, re.IGNORECASE):
            result.error(path, "legacy bzk uncertainty annotation", line_number)

        tags = EVIDENCE_TAG_RE.findall(line)
        for tag in tags:
            if tag not in APPROVED_EVIDENCE_TAGS:
                result.error(path, f"unsupported evidence tag !({tag})", line_number)
            if tag in UNRESOLVED_EVIDENCE_TAGS:
                ids = REGISTRY_ID_RE.findall(line)
                if not ids:
                    result.error(
                        path,
                        f"!({tag}) annotation must reference a registry ID",
                        line_number,
                    )
                for registry_id in ids:
                    if registry_id not in registry_ids:
                        result.error(
                            path,
                            f"evidence annotation references missing {registry_id}",
                            line_number,
                        )


def registry_ids(
    project_root: Path,
    text_by_path: dict[Path, str],
    result: LintResult,
) -> set[str]:
    path = Path("docs/unknowns.md")
    text = text_by_path.get(path)
    if text is None:
        result.error(path, "canonical unknowns registry is missing or unreadable")
        return set()

    ids = REGISTRY_HEADING_RE.findall(text)
    counts = Counter(ids)
    for registry_id, count in sorted(counts.items()):
        if count > 1:
            result.error(path, f"duplicate registry ID {registry_id} ({count} entries)")
    return set(ids)


def check_registry_references(
    text_by_path: dict[Path, str],
    known_ids: set[str],
    result: LintResult,
) -> None:
    for path, text in text_by_path.items():
        if path == Path("docs/roadmap.md"):
            continue
        for line_number, line in enumerate(text.splitlines(), start=1):
            for registry_id in REGISTRY_ID_RE.findall(line):
                if registry_id not in known_ids:
                    result.error(
                        path,
                        f"reference to missing registry ID {registry_id}",
                        line_number,
                    )


def check_subroutine_calls(
    sub_labels: dict[str, tuple[Path, int]],
    jsr_targets: dict[str, list[tuple[Path, int]]],
    result: LintResult,
) -> None:
    for name, (path, line_number) in sorted(sub_labels.items()):
        if name not in jsr_targets:
            result.error(path, f"subroutine label has no direct JSR caller: {name}", line_number)

    for target, call_sites in sorted(jsr_targets.items()):
        if target.startswith("sub_") and target not in sub_labels:
            for path, line_number in call_sites:
                result.error(path, f"JSR target is not defined: {target}", line_number)


def main() -> int:
    project_root = Path(__file__).resolve().parent.parent
    result = LintResult()

    try:
        source_files = git_source_files(project_root)
    except RuntimeError as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        return 1

    text_by_path: dict[Path, str] = {}
    for path in source_files:
        if not is_text_path(path):
            continue
        text = read_text(project_root, path, result)
        if text is None:
            continue
        text_by_path[path] = text
        check_text_format(path, text, result)

    known_registry_ids = registry_ids(project_root, text_by_path, result)
    check_registry_references(text_by_path, known_registry_ids, result)

    sub_labels: dict[str, tuple[Path, int]] = {}
    jsr_targets: dict[str, list[tuple[Path, int]]] = {}
    for path, text in text_by_path.items():
        if path.suffix.lower() not in {".asm", ".inc"}:
            continue
        check_asm_file(path, text, result, sub_labels, jsr_targets)
        check_evidence(path, text, known_registry_ids, result)

    check_subroutine_calls(sub_labels, jsr_targets, result)

    if result.errors:
        for error in sorted(result.errors):
            print(f"[ERROR] {error}")
        print(f"[FAIL] {len(result.errors)} lint error(s).")
        return 1

    print(
        f"[OK] Lint passed: {result.checked_text_files} text files, "
        f"{result.checked_asm_modules} ASM modules, "
        f"{len(known_registry_ids)} registry IDs, "
        f"{len(sub_labels)} subroutines."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
