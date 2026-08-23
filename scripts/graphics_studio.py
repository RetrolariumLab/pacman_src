#!/usr/bin/env python3
"""Local Tk graphics editor for the expanded-ROM asset workflow."""

from __future__ import annotations

import argparse
import subprocess
import sys
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

from graphics_studio_model import (
    ActorDocument,
    GraphicsDocument,
    load_actor_document,
    load_actor_tables,
    metasprite_pixels,
)


# A conventional RGB approximation used only by the editor preview. The ROM stores
# six-bit NES color indexes; the emulator/console remains the rendering authority.
NES_RGB = (
    "#626262", "#001FB2", "#2404C8", "#5200B2", "#730076", "#800024", "#730B00", "#522800",
    "#244400", "#005700", "#005C00", "#005324", "#003C76", "#000000", "#000000", "#000000",
    "#ABABAB", "#0D57FF", "#4B30FF", "#8A13FF", "#BC08D6", "#D21269", "#C72E00", "#9D5400",
    "#607B00", "#209800", "#00A300", "#009942", "#007DB4", "#000000", "#000000", "#000000",
    "#FFFFFF", "#53AEFF", "#9085FF", "#D365FF", "#FF57FF", "#FF5DCF", "#FF7757", "#FA9E00",
    "#BDC700", "#7AE700", "#43F611", "#26EF7E", "#2CD5F6", "#4E4E4E", "#000000", "#000000",
    "#FFFFFF", "#B6E1FF", "#CED1FF", "#E9C3FF", "#FFBCFF", "#FFBDF4", "#FFC6C3", "#FFD59A",
    "#E9E681", "#CEF481", "#B6FB9A", "#A9FAC3", "#A9F0F4", "#B8B8B8", "#000000", "#000000",
)

PREVIEW_PALETTES = [
    [0x0F, 0x16, 0x29, 0x30],
    [0x0F, 0x06, 0x17, 0x28],
    [0x0F, 0x19, 0x2A, 0x30],
    [0x0F, 0x12, 0x21, 0x30],
]


class GraphicsStudio(tk.Tk):
    def __init__(self, source: Path, output: Path, actor_path: Path, rom: Path, project: Path) -> None:
        super().__init__()
        self.title("Pac-Man Graphics Studio")
        self.geometry("1240x820")
        self.minsize(1050, 700)
        self.project = project
        self.rom = rom
        load_path = output if output.exists() else source
        self.document = GraphicsDocument(load_path.read_bytes(), output)
        original_actors = load_actor_tables(rom.read_bytes())
        self.actor_document: ActorDocument = load_actor_document(actor_path, original_actors)
        self.actors = self.actor_document.actors
        self.tile_index = 0
        self.paint_color = tk.IntVar(value=1)
        self.preview_palette = tk.IntVar(value=0)
        self.bank = tk.IntVar(value=0)
        self.actor_table = tk.StringVar(value="standard")
        self.actor_frame = tk.IntVar(value=0)
        self.status = tk.StringVar()
        self.palette_labels: list[list[tk.Label]] = []
        self.palette_picker: tk.Toplevel | None = None
        self.actor_tile_vars = [tk.IntVar() for _ in range(4)]
        self.actor_palette_vars = [tk.IntVar() for _ in range(4)]
        self.actor_priority_vars = [tk.BooleanVar() for _ in range(4)]
        self.actor_hflip_vars = [tk.BooleanVar() for _ in range(4)]
        self.actor_vflip_vars = [tk.BooleanVar() for _ in range(4)]
        self._build_ui()
        self._bind_shortcuts()
        self.protocol("WM_DELETE_WINDOW", self._close)
        self.refresh()
        self.load_actor_controls()

    def _build_ui(self) -> None:
        toolbar = ttk.Frame(self, padding=6)
        toolbar.pack(fill="x")
        for text, command in (("Save", self.save), ("Save As…", self.save_as),
                              ("Undo", self.undo), ("Restore tile", self.restore_tile),
                              ("Build expanded ROM", self.build_rom), ("Run in FCEUX", self.run_rom)):
            ttk.Button(toolbar, text=text, command=command).pack(side="left", padx=2)
        ttk.Label(toolbar, textvariable=self.status).pack(side="right", padx=8)

        body = ttk.Panedwindow(self, orient="horizontal")
        body.pack(fill="both", expand=True, padx=6, pady=(0, 6))
        browser = ttk.Frame(body, padding=6)
        editor = ttk.Frame(body, padding=6)
        actor = ttk.Frame(body, padding=6)
        body.add(browser, weight=4)
        body.add(editor, weight=3)
        body.add(actor, weight=3)

        ttk.Label(browser, text="CHR tile bank", font=("Segoe UI", 11, "bold")).pack(anchor="w")
        switch = ttk.Frame(browser)
        switch.pack(fill="x", pady=4)
        for label, value in (("Background $000–$0FF", 0), ("Sprites $100–$1FF", 1)):
            ttk.Radiobutton(switch, text=label, variable=self.bank, value=value,
                            command=self._bank_changed).pack(side="left", padx=(0, 8))
        self.bank_canvas = tk.Canvas(browser, width=512, height=512, bg="#202020", highlightthickness=0)
        self.bank_canvas.pack(fill="both", expand=True)
        self.bank_canvas.bind("<Configure>", lambda _event: self.draw_bank())
        self.bank_canvas.bind("<Button-1>", self._select_tile)

        ttk.Label(editor, text="8×8 2bpp tile", font=("Segoe UI", 11, "bold")).pack(anchor="w")
        self.tile_name = ttk.Label(editor)
        self.tile_name.pack(anchor="w", pady=(2, 8))
        self.pixel_canvas = tk.Canvas(editor, width=320, height=320, bg="#202020", highlightthickness=0)
        self.pixel_canvas.pack(fill="x")
        self.pixel_canvas.bind("<Button-1>", self._paint)
        self.pixel_canvas.bind("<B1-Motion>", self._paint)
        self.pixel_canvas.bind("<ButtonRelease-1>", self._end_stroke)
        ttk.Label(editor, text="Preview palettes (not written to ROM)").pack(anchor="w", pady=(12, 3))
        palette_grid = ttk.Frame(editor)
        palette_grid.pack(anchor="w")
        for palette_index in range(4):
            ttk.Radiobutton(palette_grid, text=str(palette_index), variable=self.preview_palette,
                            value=palette_index, command=self._palette_changed).grid(
                                row=palette_index, column=0, padx=(0, 4))
            row_labels = []
            for color_index in range(4):
                label = tk.Label(palette_grid, width=7, height=2, relief="raised", cursor="hand2")
                label.grid(row=palette_index, column=color_index + 1, padx=2, pady=1)
                label.bind("<Button-1>", lambda _event, palette=palette_index, color=color_index:
                           self._select_ink(palette, color))
                label.bind("<Button-3>", lambda _event, palette=palette_index, slot=color_index:
                           self.choose_nes_color(palette, slot))
                row_labels.append(label)
            self.palette_labels.append(row_labels)
        ttk.Label(editor, text="Select a row to recolor tile banks instantly. Left click chooses ink; right click edits color.",
                  wraplength=320).pack(anchor="w", pady=5)

        ttk.Label(actor, text="Actor metasprite inspector", font=("Segoe UI", 11, "bold")).pack(anchor="w")
        controls = ttk.Frame(actor)
        controls.pack(fill="x", pady=5)
        table_box = ttk.Combobox(controls, textvariable=self.actor_table, values=("standard", "alternate"),
                                 state="readonly", width=11)
        table_box.pack(side="left")
        table_box.bind("<<ComboboxSelected>>", lambda _event: self._actor_table_changed())
        ttk.Label(controls, text="Frame").pack(side="left", padx=(10, 3))
        self.frame_spin = ttk.Spinbox(controls, from_=0, to=63, textvariable=self.actor_frame, width=5,
                                     command=self._actor_frame_changed)
        self.frame_spin.pack(side="left")
        self.frame_spin.bind("<Return>", lambda _event: self._actor_frame_changed())
        self.actor_canvas = tk.Canvas(actor, width=320, height=320, bg="#202020", highlightthickness=0)
        self.actor_canvas.pack(fill="x", pady=6)
        mapping = ttk.LabelFrame(actor, text="Editable frame mapping", padding=5)
        mapping.pack(fill="x", pady=(2, 6))
        for column, title in enumerate(("Quad", "Tile", "Pal", "Behind", "H", "V")):
            ttk.Label(mapping, text=title).grid(row=0, column=column, padx=2)
        for quad in range(4):
            ttk.Label(mapping, text=str(quad)).grid(row=quad + 1, column=0)
            ttk.Spinbox(mapping, from_=0, to=255, textvariable=self.actor_tile_vars[quad],
                        width=5).grid(row=quad + 1, column=1, padx=2)
            ttk.Spinbox(mapping, from_=0, to=3, textvariable=self.actor_palette_vars[quad],
                        width=3).grid(row=quad + 1, column=2, padx=2)
            ttk.Checkbutton(mapping, variable=self.actor_priority_vars[quad]).grid(row=quad + 1, column=3)
            ttk.Checkbutton(mapping, variable=self.actor_hflip_vars[quad]).grid(row=quad + 1, column=4)
            ttk.Checkbutton(mapping, variable=self.actor_vflip_vars[quad]).grid(row=quad + 1, column=5)
        ttk.Button(mapping, text="Apply frame mapping", command=self.apply_actor_mapping).grid(
            row=5, column=0, columnspan=6, sticky="ew", pady=(5, 0))
        self.actor_details = ttk.Label(actor, justify="left", font=("Consolas", 9), wraplength=330)
        self.actor_details.pack(anchor="w")
        note = ("Tile, palette, priority, and flip edits are saved to the expanded actor table. "
                "The shared signed 16x16 OAM offsets remain read-only.")
        ttk.Label(actor, text=note, wraplength=330).pack(anchor="w", pady=(14, 0))

    def _bind_shortcuts(self) -> None:
        self.bind("<Control-s>", lambda _event: self.save())
        self.bind("<Control-z>", lambda _event: self.undo())

    def refresh(self) -> None:
        marker = " *" if self.document.dirty or self.actor_document.dirty else ""
        self.status.set(f"{self.document.path}{marker}")
        changed = " · modified" if self.document.changed(self.tile_index) else ""
        self.tile_name.configure(text=f"Tile ${self.tile_index:03X}{changed}")
        for palette_index, labels in enumerate(self.palette_labels):
            for color_index, label in enumerate(labels):
                value = PREVIEW_PALETTES[palette_index][color_index]
                selected = self.preview_palette.get() == palette_index and self.paint_color.get() == color_index
                label.configure(bg=NES_RGB[value], text=f"{color_index}: ${value:02X}",
                                relief="sunken" if selected else "raised")
        self.draw_bank()
        self.draw_tile()
        self.draw_actor()

    @staticmethod
    def _draw_pixels(canvas: tk.Canvas, pixels: list[list[int]], palette: list[int]) -> None:
        canvas.delete("all")
        width = max(canvas.winfo_width(), 16)
        height = max(canvas.winfo_height(), 16)
        cell = max(1, min(width, height) // len(pixels))
        for row, values in enumerate(pixels):
            for column, pixel in enumerate(values):
                canvas.create_rectangle(column * cell, row * cell, (column + 1) * cell, (row + 1) * cell,
                                        fill=NES_RGB[palette[pixel]], outline="#404040")

    def draw_bank(self) -> None:
        canvas = self.bank_canvas
        canvas.delete("all")
        cell = max(8, min(max(canvas.winfo_width(), 256), max(canvas.winfo_height(), 256)) // 16)
        first = self.bank.get() * 256
        palette = PREVIEW_PALETTES[self.preview_palette.get()]
        for local in range(256):
            tile = self.document.tiles[first + local]
            base_x, base_y = (local % 16) * cell, (local // 16) * cell
            scale = cell / 8
            for row in range(8):
                for column in range(8):
                    canvas.create_rectangle(base_x + column * scale, base_y + row * scale,
                                            base_x + (column + 1) * scale, base_y + (row + 1) * scale,
                                            fill=NES_RGB[palette[tile[row][column]]], outline="")
            if self.document.changed(first + local):
                canvas.create_oval(base_x + 2, base_y + 2, base_x + 7, base_y + 7, fill="#ff5050", outline="")
        local = self.tile_index - first
        if 0 <= local < 256:
            x, y = (local % 16) * cell, (local // 16) * cell
            canvas.create_rectangle(x, y, x + cell, y + cell, outline="#ffffff", width=2)

    def draw_tile(self) -> None:
        self._draw_pixels(self.pixel_canvas, self.document.tiles[self.tile_index],
                          PREVIEW_PALETTES[self.preview_palette.get()])

    def draw_actor(self) -> None:
        alternate = self.actor_table.get() == "alternate"
        count = 13 if alternate else 64
        try:
            frame = max(0, min(int(self.actor_frame.get()), count - 1))
        except (ValueError, tk.TclError):
            frame = 0
        self.actor_frame.set(frame)
        pixels = metasprite_pixels(self.document.tiles, self.actors, frame, alternate)
        self.actor_canvas.delete("all")
        cell = max(1, min(self.actor_canvas.winfo_width(), self.actor_canvas.winfo_height()) // 16)
        for row, values in enumerate(pixels):
            for column, (pixel, _palette_index) in enumerate(values):
                color = NES_RGB[PREVIEW_PALETTES[self.preview_palette.get()][pixel]]
                self.actor_canvas.create_rectangle(column * cell, row * cell, (column + 1) * cell,
                                                   (row + 1) * cell, fill=color, outline="#404040")
        tile_key = "alternate_tile_quads" if alternate else "standard_tile_quads"
        attr_key = "alternate_attribute_quads" if alternate else "standard_attribute_quads"
        tiles = self.actors[tile_key][frame]
        attrs = self.actors[attr_key][frame]
        offsets = self.actors["oam_offsets_yx"]
        lines = []
        for index, (tile, attr, (y, x)) in enumerate(zip(tiles, attrs, offsets)):
            signed_y, signed_x = (y if y < 128 else y - 256), (x if x < 128 else x - 256)
            flags = ("H" if attr & 0x40 else "-") + ("V" if attr & 0x80 else "-")
            lines.append(f"{index}: tile ${tile:02X}  attr ${attr:02X}  pal {attr & 3}  {flags}  y {signed_y:+d} x {signed_x:+d}")
        self.actor_details.configure(text="\n".join(lines))

    def _bank_changed(self) -> None:
        self.tile_index = self.bank.get() * 256
        self.refresh()

    def _select_tile(self, event: tk.Event) -> None:
        cell = max(8, min(max(self.bank_canvas.winfo_width(), 256),
                          max(self.bank_canvas.winfo_height(), 256)) // 16)
        column, row = int(event.x) // cell, int(event.y) // cell
        if 0 <= column < 16 and 0 <= row < 16:
            self.tile_index = self.bank.get() * 256 + row * 16 + column
            self.refresh()

    def _paint(self, event: tk.Event) -> None:
        cell = max(1, min(self.pixel_canvas.winfo_width(), self.pixel_canvas.winfo_height()) // 8)
        column, row = int(event.x) // cell, int(event.y) // cell
        if not 0 <= column < 8 or not 0 <= row < 8:
            return
        if self.document.stroke_tile is None:
            self.document.begin_stroke(self.tile_index)
        if self.document.paint(self.tile_index, row, column, self.paint_color.get()):
            self.draw_tile()
            self.draw_actor()
            self.status.set(f"{self.document.path} *")
            self.tile_name.configure(text=f"Tile ${self.tile_index:03X} · modified")

    def _end_stroke(self, _event: tk.Event) -> None:
        self.document.end_stroke()
        self.draw_bank()

    def _select_ink(self, palette: int, color: int) -> None:
        self.preview_palette.set(palette)
        self.paint_color.set(color)
        self._palette_changed()

    def _palette_changed(self) -> None:
        self.refresh()

    def choose_nes_color(self, palette: int, slot: int) -> None:
        if self.palette_picker is not None and self.palette_picker.winfo_exists():
            self.palette_picker.lift()
            self.palette_picker.focus_force()
            return
        picker = tk.Toplevel(self)
        self.palette_picker = picker
        picker.title(f"NES color for slot {slot}")
        picker.resizable(False, False)
        picker.protocol("WM_DELETE_WINDOW", self._close_palette_picker)
        for value, color in enumerate(NES_RGB):
            button = tk.Button(picker, bg=color, text=f"{value:02X}", width=4, height=2,
                               command=lambda selected=value: self._set_preview_color(palette, slot, selected, picker))
            button.grid(row=value // 16, column=value % 16)

    def _set_preview_color(self, palette: int, slot: int, value: int, picker: tk.Toplevel) -> None:
        PREVIEW_PALETTES[palette][slot] = value
        picker.destroy()
        self.palette_picker = None
        self.refresh()

    def _close_palette_picker(self) -> None:
        if self.palette_picker is not None:
            self.palette_picker.destroy()
            self.palette_picker = None

    def _actor_table_changed(self) -> None:
        self.frame_spin.configure(to=12 if self.actor_table.get() == "alternate" else 63)
        self.actor_frame.set(0)
        self.draw_actor()
        self.load_actor_controls()

    def _actor_frame_changed(self) -> None:
        self.draw_actor()
        self.load_actor_controls()

    def load_actor_controls(self) -> None:
        alternate = self.actor_table.get() == "alternate"
        frame = max(0, min(int(self.actor_frame.get()), 12 if alternate else 63))
        tile_key = "alternate_tile_quads" if alternate else "standard_tile_quads"
        attr_key = "alternate_attribute_quads" if alternate else "standard_attribute_quads"
        for quad, (tile, attr) in enumerate(zip(self.actors[tile_key][frame], self.actors[attr_key][frame])):
            self.actor_tile_vars[quad].set(tile)
            self.actor_palette_vars[quad].set(attr & 0x03)
            self.actor_priority_vars[quad].set(bool(attr & 0x20))
            self.actor_hflip_vars[quad].set(bool(attr & 0x40))
            self.actor_vflip_vars[quad].set(bool(attr & 0x80))

    def apply_actor_mapping(self) -> None:
        alternate = self.actor_table.get() == "alternate"
        try:
            frame = int(self.actor_frame.get())
            tiles = [int(value.get()) for value in self.actor_tile_vars]
            attributes = []
            for quad in range(4):
                attribute = int(self.actor_palette_vars[quad].get())
                attribute |= 0x20 if self.actor_priority_vars[quad].get() else 0
                attribute |= 0x40 if self.actor_hflip_vars[quad].get() else 0
                attribute |= 0x80 if self.actor_vflip_vars[quad].get() else 0
                attributes.append(attribute)
            self.actor_document.set_frame(alternate, frame, tiles, attributes)
        except (ValueError, tk.TclError) as error:
            messagebox.showerror("Invalid actor mapping", str(error))
            self.load_actor_controls()
            return
        self.draw_actor()
        self.refresh()

    def undo(self) -> None:
        if self.document.undo():
            self.refresh()

    def restore_tile(self) -> None:
        self.document.restore_tile(self.tile_index)
        self.refresh()

    def save(self) -> bool:
        try:
            path = self.document.save()
            actor_path = self.actor_document.save()
        except (OSError, ValueError) as error:
            messagebox.showerror("Save failed", str(error))
            return False
        self.refresh()
        self.status.set(f"Saved CHR {path.name} and actor mappings {actor_path.name}")
        return True

    def save_as(self) -> None:
        selected = filedialog.asksaveasfilename(defaultextension=".chr", filetypes=(("NES CHR", "*.chr"),))
        if selected:
            self.document.path = Path(selected)
            self.save()

    def _make(self, target: str) -> None:
        needs_save = (self.document.dirty or self.actor_document.dirty
                      or not self.actor_document.path.exists())
        if needs_save and not self.save():
            return
        if target == "run-expanded":
            if not self._run_make("verify-expanded"):
                return
        self._run_make(target)

    def _run_make(self, target: str) -> bool:
        command = [
            "make", target,
            f"GENERATED_CHR={self.document.path.resolve().as_posix()}",
            f"EXPANDED_ACTOR_JSON={self.actor_document.path.resolve().as_posix()}",
        ]
        try:
            completed = subprocess.run(command, cwd=self.project, check=False)
        except OSError as error:
            messagebox.showerror("Could not start make", str(error))
            return False
        if completed.returncode:
            messagebox.showerror("Build failed", f"{' '.join(command)} exited with {completed.returncode}.")
            return False
        else:
            self.status.set(f"make {target} completed")
            return True

    def build_rom(self) -> None:
        self._make("verify-expanded")

    def run_rom(self) -> None:
        self._make("run-expanded")

    def _close(self) -> None:
        dirty = self.document.dirty or self.actor_document.dirty
        if not dirty or messagebox.askyesno("Unsaved graphics", "Discard unsaved CHR or actor edits?"):
            self.destroy()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--chr", type=Path, required=True, help="Original 8 KiB CHR source")
    parser.add_argument("--output", type=Path, required=True, help="Ignored local editable CHR")
    parser.add_argument("--actors", type=Path, required=True, help="Ignored local actor mapping JSON")
    parser.add_argument("--rom", type=Path, required=True, help="Original iNES ROM used for actor tables")
    parser.add_argument("--project", type=Path, default=Path(__file__).resolve().parents[1])
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        app = GraphicsStudio(
            args.chr.resolve(), args.output.resolve(), args.actors.resolve(),
            args.rom.resolve(), args.project.resolve(),
        )
    except (OSError, ValueError) as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        return 1
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
