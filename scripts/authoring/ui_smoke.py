#!/usr/bin/env python3
"""Exercise real Tk Studio windows and their primary workstation actions."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import tkinter as tk
from pathlib import Path, PurePosixPath
from types import SimpleNamespace
from unittest.mock import patch


PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MANIFEST = PROJECT_ROOT / "config/authoring/ui_smokes.json"
EXPECTED_ACTIONS = {
    "sound": ["open", "edit", "preview", "save", "build-dispatch", "dirty-close"],
    "maze": ["open", "edit", "undo-redo", "save", "build-dispatch", "dirty-close"],
    "graphics": ["open", "edit", "undo", "save", "build-dispatch", "dirty-close"],
    "screen": ["open", "edit", "save", "build-dispatch", "dirty-close"],
}
EXPECTED_ENTRYPOINTS = {
    studio: f"scripts/authoring/{studio}_studio.py" for studio in EXPECTED_ACTIONS
}


def safe_relative_path(value: object, field: str) -> Path:
    if not isinstance(value, str) or not value:
        raise ValueError(f"{field} must be a non-empty relative path")
    pure = PurePosixPath(value)
    if pure.is_absolute() or ".." in pure.parts:
        raise ValueError(f"unsafe {field}: {value}")
    return Path(*pure.parts)


def load_manifest(path: Path) -> dict[str, object]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        raise ValueError("unsupported UI smoke manifest schema")
    return document


def validate_manifest(
    project_root: Path, document: dict[str, object], require_inputs: bool,
) -> list[str]:
    errors: list[str] = []
    if document.get("host") != {"os": "Windows", "toolkit": "tkinter"}:
        errors.append("UI smoke host contract must be Windows tkinter")
    try:
        output = safe_relative_path(document.get("output_root"), "UI smoke output_root")
        if output.as_posix() != "build/ui_smoke":
            errors.append("UI smoke output must be build/ui_smoke")
    except ValueError as error:
        errors.append(str(error))

    studios = document.get("studios")
    if not isinstance(studios, list):
        return errors + ["UI smoke studios must be a list"]
    ids = [row.get("id") for row in studios if isinstance(row, dict)]
    if ids != list(EXPECTED_ACTIONS):
        errors.append("UI smoke studio IDs or order differ from the supported Studios")
    for row in studios:
        if not isinstance(row, dict) or set(row) != {"id", "entrypoint", "inputs", "actions"}:
            errors.append("UI smoke studio row has an invalid shape")
            continue
        studio = row.get("id")
        if studio not in EXPECTED_ACTIONS:
            continue
        if row.get("entrypoint") != EXPECTED_ENTRYPOINTS[studio]:
            errors.append(f"UI smoke entrypoint differs for {studio}")
        elif not (project_root / row["entrypoint"]).is_file():
            errors.append(f"UI smoke entrypoint is missing for {studio}")
        if row.get("actions") != EXPECTED_ACTIONS[studio]:
            errors.append(f"UI smoke actions differ for {studio}")
        inputs = row.get("inputs")
        if not isinstance(inputs, dict) or not inputs:
            errors.append(f"UI smoke inputs are missing for {studio}")
            continue
        for name, value in inputs.items():
            try:
                relative = safe_relative_path(value, f"{studio}.{name}")
            except ValueError as error:
                errors.append(str(error))
                continue
            if require_inputs and not (project_root / relative).exists():
                errors.append(f"UI smoke input is missing: {relative.as_posix()}")
    return errors


def prepare_output(project_root: Path, relative: Path) -> Path:
    build_root = (project_root / "build").resolve()
    output = (project_root / relative).resolve()
    if output == build_root or build_root not in output.parents:
        raise ValueError(f"unsafe UI smoke output root: {output}")
    if output.exists():
        shutil.rmtree(output)
    output.mkdir(parents=True)
    return output


def copy_input(source: Path, output: Path, studio: str) -> Path:
    destination = output / "workspace" / studio / source.name
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)
    return destination


def show_window(window: object) -> None:
    window.update_idletasks()
    window.update()
    if not window.winfo_exists():
        raise ValueError("Studio window was not created")


def smoke_sound(project_root: Path, output: Path, inputs: dict[str, Path]) -> None:
    import sound_studio
    from sound_studio_model import StudioDocument, load_collection, load_original_collection

    editable = copy_input(inputs["sound_json"], output, "sound")
    document = load_collection(editable)
    original = load_original_collection(inputs["asset_manifest"], inputs["asset_dir"])
    model = StudioDocument(document, editable, original)
    app = sound_studio.SoundStudio(model, output / "sound_preview.wav")
    try:
        show_window(app)
        selection = next(
            (slot, index, command)
            for slot in range(16)
            for index, command in enumerate(model.commands(slot))
            if command["kind"] == "note"
        )
        slot, index, command = selection
        app.slot.set(slot)
        app.slot_box.current(slot)
        app.refresh(index)
        app.tree.selection_set(str(index))
        app._command_selected()
        duration = int(command["duration"])
        app.duration.set(str(duration - 1 if duration == 255 else duration + 1))
        app.update_note()
        with patch("winsound.PlaySound"):
            app.preview()
        if not app.preview_path.is_file():
            raise ValueError("Sound Studio preview action produced no WAV")
        with patch.object(sound_studio.messagebox, "askyesno", return_value=True):
            app.save()
        if model.dirty or not editable.is_file():
            raise ValueError("Sound Studio save action did not persist a clean document")
        with patch.object(sound_studio.subprocess, "Popen") as process:
            app.run_make("build-expanded")
        if process.call_count != 1:
            raise ValueError("Sound Studio build action did not dispatch Make")
        changed = int(model.commands(slot)[index]["duration"])
        model.commands(slot)[index]["duration"] = changed - 1 if changed == 255 else changed + 1
        app.refresh(index)
        with patch.object(sound_studio.messagebox, "askyesno", side_effect=[False, True]):
            app.close()
            if not app.winfo_exists():
                raise ValueError("Sound Studio dirty-close cancellation closed the window")
            app.close()
    finally:
        try:
            app.destroy()
        except Exception:
            pass


def smoke_maze(project_root: Path, output: Path, inputs: dict[str, Path]) -> None:
    import maze_studio
    from data_formats import decode_maze
    from maze_studio_model import MazeDocument, load_document

    editable = copy_input(inputs["maze_json"], output, "maze")
    original = decode_maze(inputs["original_rle"].read_bytes())
    model = MazeDocument(load_document(editable), editable, original)
    app = maze_studio.MazeStudio(model, inputs["chr"].read_bytes())
    try:
        show_window(app)
        old = model.grid[0][0]
        model.paint(0, 0, (old + 1) & 0x3F)
        app.refresh()
        app.undo()
        app.redo()
        app.undo()
        with patch.object(maze_studio.messagebox, "askyesno", return_value=True):
            app.save()
        with patch.object(maze_studio.subprocess, "Popen") as process:
            app.run_make("build-expanded")
        if process.call_count != 1:
            raise ValueError("Maze Studio build action did not dispatch Make")
        model.paint(0, 0, (old + 1) & 0x3F)
        app.refresh()
        with patch.object(maze_studio.messagebox, "askyesno", side_effect=[False, True]):
            app.close()
            if not app.winfo_exists():
                raise ValueError("Maze Studio dirty-close cancellation closed the window")
            app.close()
    finally:
        try:
            app.destroy()
        except Exception:
            pass


def smoke_graphics(project_root: Path, output: Path, inputs: dict[str, Path]) -> None:
    import graphics_studio

    editable_chr = output / "workspace/graphics/pacman.chr"
    actors = copy_input(inputs["actors"], output, "graphics")
    palettes = copy_input(inputs["palettes"], output, "graphics")
    app = graphics_studio.GraphicsStudio(
        inputs["chr"], editable_chr, actors, palettes, inputs["rom"], project_root,
    )
    try:
        show_window(app)
        old = app.document.tiles[0][0][0]
        app.document.begin_stroke(0)
        app.document.paint(0, 0, 0, old ^ 1)
        app.document.end_stroke()
        app.refresh()
        app.undo()
        app.document.begin_stroke(0)
        app.document.paint(0, 0, 0, old ^ 1)
        app.document.end_stroke()
        app.refresh()
        if not app.save() or not editable_chr.is_file():
            raise ValueError("Graphics Studio save action produced no CHR")
        with patch.object(
            graphics_studio.subprocess, "run", return_value=SimpleNamespace(returncode=0),
        ) as process:
            app.build_rom()
        if process.call_count != 1:
            raise ValueError("Graphics Studio build action did not dispatch Make")
        value = app.document.tiles[0][0][1]
        app.document.paint(0, 0, 1, value ^ 1)
        app.refresh()
        with patch.object(graphics_studio.messagebox, "askyesno", side_effect=[False, True]):
            app._close()
            if not app.winfo_exists():
                raise ValueError("Graphics Studio dirty-close cancellation closed the window")
            app._close()
    finally:
        try:
            app.destroy()
        except Exception:
            pass


def smoke_screen(project_root: Path, output: Path, inputs: dict[str, Path]) -> None:
    import screen_studio

    screens = copy_input(inputs["screens"], output, "screen")
    palettes = copy_input(inputs["palettes"], output, "screen")
    app = screen_studio.ScreenStudio(
        inputs["rom"], inputs["chr"], screens, palettes, project_root,
    )
    try:
        show_window(app)
        key = app.message_key.get()
        old = app.screen.get_message(key)
        replacement = ("B" if old[:1] == "A" else "A") + old[1:]
        app.message_text.set(replacement)
        app.apply_message()
        if not app.save() or not screens.is_file():
            raise ValueError("Screen Studio save action produced no JSON")
        with patch.object(
            screen_studio.subprocess, "run", return_value=SimpleNamespace(returncode=0),
        ) as process:
            app.build_rom()
        if process.call_count != 1:
            raise ValueError("Screen Studio build action did not dispatch Make")
        current = app.screen.get_message(key)
        app.screen.set_message(key, ("C" if current[:1] != "C" else "D") + current[1:])
        app.refresh_all()
        with patch.object(screen_studio.messagebox, "askyesno", side_effect=[False, True]):
            app._close()
            if not app.winfo_exists():
                raise ValueError("Screen Studio dirty-close cancellation closed the window")
            app._close()
    finally:
        try:
            app.destroy()
        except Exception:
            pass


SMOKE_RUNNERS = {
    "sound": smoke_sound,
    "maze": smoke_maze,
    "graphics": smoke_graphics,
    "screen": smoke_screen,
}


def run_ui_smokes(project_root: Path, document: dict[str, object]) -> Path:
    errors = validate_manifest(project_root, document, require_inputs=True)
    if errors:
        raise ValueError("; ".join(errors))
    if sys.platform != "win32":
        raise ValueError("UI interaction smoke is supported only on the declared Windows host")
    output = prepare_output(
        project_root, safe_relative_path(document["output_root"], "UI smoke output_root"),
    )
    results: list[dict[str, object]] = []
    for row in document["studios"]:
        studio = row["id"]
        inputs = {
            name: project_root / safe_relative_path(value, f"{studio}.{name}")
            for name, value in row["inputs"].items()
        }
        print(f"[RUN] {studio} Studio: {', '.join(row['actions'])}", flush=True)
        SMOKE_RUNNERS[studio](project_root, output, inputs)
        results.append({"id": studio, "status": "pass", "actions": row["actions"]})
        print(f"[OK] {studio} Studio interaction smoke passed.")
    report = output / "report.json"
    temporary = report.with_suffix(".json.tmp")
    temporary.write_text(
        json.dumps({"schema_version": 1, "studios": results}, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(report)
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=PROJECT_ROOT)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--check", action="store_true", help="validate the contract without opening windows")
    args = parser.parse_args(argv)
    try:
        document = load_manifest(args.manifest)
        errors = validate_manifest(args.project_root.resolve(), document, require_inputs=not args.check)
        if errors:
            raise ValueError("; ".join(errors))
        if args.check:
            print("[OK] UI smoke contract covers 4 Studios and their required actions.")
            return 0
        report = run_ui_smokes(args.project_root.resolve(), document)
    except (OSError, ValueError, json.JSONDecodeError, StopIteration, tk.TclError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    print(f"[OK] Workstation UI interaction report: {report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
