#!/usr/bin/env python3
"""Launch the dependency-free local Pac-Man Sound Studio."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog, ttk

from render_sound_preview import render_stream, write_wav
from sound_authoring import midi_note_name, sound_byte_to_midi
from sound_studio_model import StudioDocument, load_collection, load_original_collection


PROJECT_ROOT = Path(__file__).resolve().parent.parent


class SoundStudio(tk.Tk):
    def __init__(self, model: StudioDocument, preview_path: Path) -> None:
        super().__init__()
        self.model = model
        self.preview_path = preview_path
        self.slot = tk.IntVar(value=0)
        self.note_name = tk.StringVar(value="A3")
        self.duration = tk.StringVar(value="8")
        self.status = tk.StringVar()
        self.title("Pac-Man Sound Studio")
        self.geometry("1180x760")
        self.minsize(900, 600)
        self.protocol("WM_DELETE_WINDOW", self.close)
        self._build_ui()
        self.refresh()

    def _build_ui(self) -> None:
        toolbar = ttk.Frame(self, padding=8)
        toolbar.pack(fill=tk.X)
        ttk.Label(toolbar, text="Sound slot:").pack(side=tk.LEFT)
        self.slot_box = ttk.Combobox(
            toolbar,
            state="readonly",
            width=43,
            values=[self.model.slot_label(slot) for slot in range(16)],
        )
        self.slot_box.current(0)
        self.slot_box.pack(side=tk.LEFT, padx=(6, 12))
        self.slot_box.bind("<<ComboboxSelected>>", self._select_slot)
        for label, command in (
            ("Preview", self.preview),
            ("Import MIDI...", self.import_midi),
            ("Save", self.save),
            ("Save As...", self.save_as),
            ("Build ROM", lambda: self.run_make("build-expanded")),
            ("Run FCEUX", lambda: self.run_make("run-expanded")),
        ):
            ttk.Button(toolbar, text=label, command=command).pack(side=tk.LEFT, padx=3)

        pane = ttk.Panedwindow(self, orient=tk.VERTICAL)
        pane.pack(fill=tk.BOTH, expand=True, padx=8)
        roll_frame = ttk.Labelframe(pane, text="Piano roll (horizontal: NTSC frames)", padding=4)
        self.canvas = tk.Canvas(roll_frame, background="#10151d", height=310)
        x_scroll = ttk.Scrollbar(roll_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        self.canvas.configure(xscrollcommand=x_scroll.set)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        x_scroll.pack(fill=tk.X)
        pane.add(roll_frame, weight=3)

        lower = ttk.Frame(pane)
        pane.add(lower, weight=2)
        self.tree = ttk.Treeview(
            lower,
            columns=("index", "kind", "description", "duration", "original"),
            show="headings",
            height=12,
        )
        for column, heading, width in (
            ("index", "#", 45), ("kind", "Kind", 80),
            ("description", "Edited note / command", 220), ("duration", "Frames", 75),
            ("original", "Original at index", 220),
        ):
            self.tree.heading(column, text=heading)
            self.tree.column(column, width=width, stretch=column == "description")
        self.tree.bind("<<TreeviewSelect>>", self._command_selected)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        editor = ttk.Labelframe(lower, text="Selected note", padding=10)
        editor.pack(side=tk.LEFT, fill=tk.Y, padx=(8, 0))
        ttk.Label(editor, text="Note name").grid(row=0, column=0, sticky=tk.W)
        ttk.Entry(editor, textvariable=self.note_name, width=12).grid(row=0, column=1, padx=5)
        ttk.Label(editor, text="Duration (frames)").grid(row=1, column=0, sticky=tk.W, pady=6)
        ttk.Entry(editor, textvariable=self.duration, width=12).grid(row=1, column=1, padx=5)
        ttk.Button(editor, text="Update note", command=self.update_note).grid(row=2, column=0, columnspan=2, sticky=tk.EW)
        ttk.Button(editor, text="Insert before", command=self.insert_note).grid(row=3, column=0, columnspan=2, sticky=tk.EW, pady=4)
        ttk.Button(editor, text="Delete note", command=self.delete_note).grid(row=4, column=0, columnspan=2, sticky=tk.EW)
        ttk.Separator(editor).grid(row=5, column=0, columnspan=2, sticky=tk.EW, pady=10)
        ttk.Button(editor, text="Restore original slot", command=self.restore_original).grid(row=6, column=0, columnspan=2, sticky=tk.EW)
        ttk.Label(
            editor,
            text="MIDI import replaces the slot.\nOnly contiguous monophonic notes\nare representable; velocity and\ninstruments are not imported.",
            foreground="#8b4513",
            justify=tk.LEFT,
        ).grid(row=7, column=0, columnspan=2, sticky=tk.W, pady=(12, 0))

        ttk.Label(self, textvariable=self.status, anchor=tk.W, padding=8).pack(fill=tk.X)

    def _select_slot(self, _event: object = None) -> None:
        self.slot.set(self.slot_box.current())
        self.refresh()

    def selected_index(self, default_to_end: bool = False) -> int:
        selection = self.tree.selection()
        if selection:
            return int(selection[0])
        if default_to_end:
            return len(self.model.commands(self.slot.get()))
        raise ValueError("Select a command first")

    def _command_selected(self, _event: object = None) -> None:
        try:
            command = self.model.commands(self.slot.get())[self.selected_index()]
            if command["kind"] == "note":
                self.note_name.set(midi_note_name(sound_byte_to_midi(int(command["value"]))))
                self.duration.set(str(command["duration"]))
        except (IndexError, ValueError):
            return

    def refresh(self, selected: int | None = None) -> None:
        slot = self.slot.get()
        commands = self.model.commands(slot)
        self.tree.delete(*self.tree.get_children())
        for index, command in enumerate(commands):
            if command["kind"] == "note":
                midi = sound_byte_to_midi(int(command["value"]))
                description = f"{midi_note_name(midi)}  byte ${int(command['value']):02X}"
            elif command["kind"] == "duration":
                description = f"marker ${int(command['marker']):02X}"
            else:
                operand = command.get("operand")
                description = f"opcode ${int(command['opcode']):02X}"
                if operand is not None:
                    description += f"  operand ${int(operand):02X}"
            original = self.model.original_command_description(slot, index)
            self.tree.insert(
                "", tk.END, iid=str(index),
                values=(index, command["kind"], description, command.get("duration", ""), original),
            )
        if selected is not None and str(selected) in self.tree.get_children():
            self.tree.selection_set(str(selected))
            self.tree.see(str(selected))
        self._draw_roll(commands)
        summary = self.model.summary(slot)
        comparison = "CHANGED from original" if summary["changed_from_original"] else "matches original"
        dirty = "unsaved edits" if self.model.dirty else "saved"
        self.status.set(
            f"Slot {slot:02X}: {summary['notes']} notes, {summary['frames']} frames, "
            f"{summary['bytes']} encoded bytes | {comparison} | {dirty} | {self.model.path}"
        )
        self.title("Pac-Man Sound Studio" + (" *" if self.model.dirty else ""))

    def _draw_roll(self, commands: list[dict[str, object]]) -> None:
        self.canvas.delete("all")
        notes = [command for command in commands if command["kind"] == "note"]
        if not notes:
            self.canvas.configure(scrollregion=(0, 0, 800, 300))
            return
        midi_values = [sound_byte_to_midi(int(command["value"])) for command in notes]
        low, high = min(midi_values) - 1, max(midi_values) + 1
        row_height, frame_width, x = 18, 5, 70
        height = (high - low + 1) * row_height + 20
        for midi in range(low, high + 1):
            y = 10 + (high - midi) * row_height
            color = "#253141" if midi % 12 in (1, 3, 6, 8, 10) else "#303d50"
            self.canvas.create_rectangle(0, y, 100000, y + row_height, fill=color, outline="#445066")
            self.canvas.create_text(34, y + row_height / 2, text=midi_note_name(midi), fill="#e5e9f0")
        for command in commands:
            duration = int(command.get("duration", 0))
            if command["kind"] == "note":
                midi = sound_byte_to_midi(int(command["value"]))
                y = 10 + (high - midi) * row_height + 2
                width = max(4, duration * frame_width)
                self.canvas.create_rectangle(x, y, x + width, y + row_height - 4, fill="#61afef", outline="#d7ecff")
                x += width
            elif command["kind"] == "duration":
                x += max(4, duration * frame_width)
        self.canvas.configure(scrollregion=(0, 0, max(850, x + 30), max(300, height)))

    def _edit_values(self) -> tuple[str, int]:
        return self.note_name.get(), int(self.duration.get(), 10)

    def update_note(self) -> None:
        self._guard(lambda: self.model.update_note(self.slot.get(), self.selected_index(), *self._edit_values()))

    def insert_note(self) -> None:
        self._guard(lambda: self.model.insert_note(self.slot.get(), self.selected_index(True), *self._edit_values()))

    def delete_note(self) -> None:
        index = self.selected_index()
        self._guard(lambda: self.model.delete_note(self.slot.get(), index))

    def restore_original(self) -> None:
        if messagebox.askyesno("Restore slot", "Replace this edited slot with the original extracted stream?"):
            self.model.reset_slot_to_original(self.slot.get())
            self.refresh()

    def _guard(self, action: object) -> None:
        try:
            action()
            self.refresh()
        except (OSError, ValueError, KeyError, TypeError) as error:
            messagebox.showerror("Sound Studio", str(error))

    def preview(self) -> None:
        try:
            pcm = render_stream(self.model.item(self.slot.get())["stream"])
            write_wav(self.preview_path, pcm, 44_100)
            if sys.platform == "win32":
                import winsound
                winsound.PlaySound(str(self.preview_path), winsound.SND_FILENAME | winsound.SND_ASYNC)
            self.status.set(f"Preview written to {self.preview_path}")
        except (OSError, ValueError, KeyError, TypeError) as error:
            messagebox.showerror("Preview failed", str(error))

    def import_midi(self) -> None:
        path = filedialog.askopenfilename(filetypes=(("MIDI files", "*.mid *.midi"), ("All files", "*.*")))
        if not path:
            return
        track = simpledialog.askinteger("MIDI track", "Track index:", initialvalue=0, minvalue=0)
        if track is None:
            return
        channel = simpledialog.askinteger("MIDI channel", "Channel (0-15):", initialvalue=0, minvalue=0, maxvalue=15)
        if channel is None:
            return
        if not messagebox.askyesno(
            "Lossy MIDI import",
            "Import replaces this slot. Velocity, instruments, polyphony and rests are not representable. Continue?",
        ):
            return
        self._guard(lambda: self.model.replace_from_midi(self.slot.get(), Path(path).read_bytes(), track, channel))

    def save(self) -> None:
        if messagebox.askyesno("Save sound JSON", f"Overwrite local editable file?\n\n{self.model.path}"):
            self._guard(lambda: self.model.save())

    def save_as(self) -> None:
        path = filedialog.asksaveasfilename(
            defaultextension=".json",
            initialfile=self.model.path.name,
            filetypes=(("JSON", "*.json"),),
        )
        if path:
            self._guard(lambda: self.model.save(Path(path)))

    def run_make(self, target: str) -> None:
        if self.model.dirty:
            messagebox.showwarning("Unsaved edits", "Save the JSON before building or launching the ROM.")
            return
        try:
            sound_assignment = f"EXPANDED_SOUND_JSON={self.model.path.resolve()}"
            subprocess.Popen(["make", target, sound_assignment], cwd=PROJECT_ROOT)
            self.status.set(f"Started: make {target} with {self.model.path}")
        except OSError as error:
            messagebox.showerror("Could not start command", str(error))

    def close(self) -> None:
        if self.model.dirty and not messagebox.askyesno("Unsaved edits", "Discard unsaved Sound Studio edits?"):
            return
        self.destroy()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sound-json", type=Path, default=PROJECT_ROOT / "hacks/local/sound_streams.json")
    parser.add_argument("--asset-manifest", type=Path, default=PROJECT_ROOT / "assets/manifest.json")
    parser.add_argument("--asset-dir", type=Path, default=PROJECT_ROOT / "assets/generated")
    parser.add_argument("--preview", type=Path, default=PROJECT_ROOT / "tmp/sound_studio_preview.wav")
    args = parser.parse_args()
    if not args.sound_json.exists():
        parser.error(f"editable sound JSON is missing: run make init-expanded-assets ({args.sound_json})")
    document = load_collection(args.sound_json)
    original = load_original_collection(args.asset_manifest, args.asset_dir)
    SoundStudio(StudioDocument(document, args.sound_json, original), args.preview).mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
