#!/usr/bin/env python3
"""Local CHR-backed editor for the expanded Pac-Man maze."""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

from data_formats import decode_maze
from maze_studio_model import COLUMNS, ROWS, MazeDocument, inspect_grid, load_document, semantic_overlays


ROOT = Path(__file__).resolve().parent.parent
CELL = 24
COLORS = ("#000000", "#001a8c", "#0868ff", "#ffffff")


def chr_pixels(data: bytes, tile: int) -> list[list[int]]:
    offset = tile * 16
    if offset + 16 > len(data):
        raise ValueError(f"CHR tile ${tile:02X} is unavailable")
    return [[((data[offset + y] >> (7 - x)) & 1) | (((data[offset + 8 + y] >> (7 - x)) & 1) << 1)
             for x in range(8)] for y in range(8)]


class MazeStudio(tk.Tk):
    def __init__(self, model: MazeDocument, chr_data: bytes) -> None:
        super().__init__()
        self.model = model
        self.tile = tk.IntVar(value=7)
        self.status = tk.StringVar()
        self.show_semantics = tk.BooleanVar(value=True)
        self.images = [self._tile_image(chr_data, tile) for tile in range(64)]
        self.title("Pac-Man Maze Studio")
        self.protocol("WM_DELETE_WINDOW", self.close)
        self._ui()
        self.refresh()

    def _tile_image(self, data: bytes, tile: int) -> tk.PhotoImage:
        image = tk.PhotoImage(width=8, height=8)
        pixels = chr_pixels(data, tile)
        for y, row in enumerate(pixels):
            image.put("{" + " ".join(COLORS[value] for value in row) + "}", to=(0, y))
        return image.zoom(3, 3)

    def _ui(self) -> None:
        bar = ttk.Frame(self, padding=7); bar.pack(fill=tk.X)
        for label, command in (("Undo", self.undo), ("Redo", self.redo),
                               ("Restore original", self.restore), ("Save", self.save),
                               ("Save As...", self.save_as),
                               ("Build ROM", lambda: self.run_make("build-expanded")),
                               ("Run FCEUX", lambda: self.run_make("run-expanded"))):
            ttk.Button(bar, text=label, command=command).pack(side=tk.LEFT, padx=2)
        ttk.Checkbutton(bar, text="Semantic overlays", variable=self.show_semantics,
                        command=self.refresh).pack(side=tk.LEFT, padx=10)
        body = ttk.Frame(self, padding=(7, 0)); body.pack(fill=tk.BOTH, expand=True)
        self.canvas = tk.Canvas(body, width=COLUMNS * CELL, height=ROWS * CELL, bg="#111")
        self.canvas.pack(side=tk.LEFT)
        self.canvas.bind("<Button-1>", self.paint)
        self.canvas.bind("<B1-Motion>", self.paint)
        palette = ttk.Labelframe(body, text="Tiles $00-$3F", padding=5); palette.pack(side=tk.LEFT, fill=tk.Y, padx=8)
        for tile in range(64):
            button = tk.Radiobutton(palette, image=self.images[tile], variable=self.tile, value=tile,
                                    indicatoron=False, selectcolor="#ffcc33", command=self.refresh)
            button.grid(row=tile // 8, column=tile % 8)
        ttk.Label(palette, text="Blue outline: differs from original\nRed outline: selected tile",
                  justify=tk.LEFT).grid(row=9, column=0, columnspan=8, sticky=tk.W, pady=8)
        ttk.Label(self, textvariable=self.status, padding=7, anchor=tk.W).pack(fill=tk.X)

    def paint(self, event: tk.Event) -> None:
        row, column = event.y // CELL, event.x // CELL
        if 0 <= row < ROWS and 0 <= column < COLUMNS:
            self.model.paint(row, column, self.tile.get()); self.refresh()

    def refresh(self) -> None:
        self.canvas.delete("all")
        for row in range(ROWS):
            for column in range(COLUMNS):
                tile = self.model.grid[row][column]; x, y = column * CELL, row * CELL
                self.canvas.create_image(x, y, image=self.images[tile], anchor=tk.NW)
                color = "#39a9ff" if self.model.changed(row, column) else "#252525"
                self.canvas.create_rectangle(x, y, x + CELL, y + CELL, outline=color)
        if self.show_semantics.get(): self._draw_semantics()
        report = inspect_grid(self.model.grid)
        issues = report["errors"] or report["warnings"] or ["structural checks pass"]
        self.status.set(f"Tile ${self.tile.get():02X} | pellets {report['pellets']}/192 | "
                        f"power {report['power_pellets']}/4 | RLE {report['minimum_rle_bytes']} -> 416 | "
                        f"{'; '.join(issues)}")
        self.title("Pac-Man Maze Studio" + (" *" if self.model.dirty else ""))

    def _draw_semantics(self) -> None:
        colors = {"tunnel": "#ff9f43", "ghost_house": "#b56cff", "door": "#ff4d6d",
                  "pacman": "#ffe600", "ghost": "#ff7675", "power": "#7bedff"}
        for overlay in semantic_overlays(self.model.grid):
            color = colors[overlay["kind"]]
            if "bounds" in overlay:
                top, left, bottom, right = overlay["bounds"]
                self.canvas.create_rectangle(left * CELL, top * CELL, (right + 1) * CELL,
                                             (bottom + 1) * CELL, outline=color, width=3)
                self.canvas.create_text(left * CELL + 3, top * CELL + 3, text=overlay["label"],
                                        fill=color, anchor=tk.NW, font=("TkDefaultFont", 8, "bold"))
            for row, column in overlay.get("cells", []):
                x, y = column * CELL, row * CELL
                self.canvas.create_rectangle(x + 2, y + 2, x + CELL - 2, y + CELL - 2,
                                             outline=color, width=2)
                if overlay["kind"] in ("pacman", "ghost", "door"):
                    self.canvas.create_text(x + CELL / 2, y + CELL / 2, text=overlay["label"],
                                            fill=color, font=("TkDefaultFont", 9, "bold"))

    def undo(self) -> None: self.model.undo(); self.refresh()
    def redo(self) -> None: self.model.redo(); self.refresh()
    def restore(self) -> None:
        if messagebox.askyesno("Restore", "Restore the complete original maze?"):
            self.model.restore_original(); self.refresh()

    def _save(self, path: Path | None = None) -> None:
        try: self.model.save(path); self.refresh()
        except ValueError as error: messagebox.showerror("Maze validation", str(error))

    def save(self) -> None:
        if messagebox.askyesno("Save", f"Overwrite editable maze?\n\n{self.model.path}"): self._save()

    def save_as(self) -> None:
        name = filedialog.asksaveasfilename(defaultextension=".json", filetypes=(("JSON", "*.json"),))
        if name: self._save(Path(name))

    def run_make(self, target: str) -> None:
        if self.model.dirty:
            messagebox.showwarning("Unsaved edits", "Save the maze before building."); return
        subprocess.Popen(["make", target, f"EXPANDED_MAZE_JSON={self.model.path.resolve()}"], cwd=ROOT)

    def close(self) -> None:
        if self.model.dirty and not messagebox.askyesno("Unsaved edits", "Discard maze edits?"): return
        self.destroy()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--maze-json", type=Path, default=ROOT / "hacks/local/maze.json")
    parser.add_argument("--original-rle", type=Path, default=ROOT / "assets/generated/maze/maze.rle")
    parser.add_argument("--chr", type=Path, default=ROOT / "assets/generated/chr/pacman.chr")
    args = parser.parse_args()
    model = MazeDocument(load_document(args.maze_json), args.maze_json,
                         decode_maze(args.original_rle.read_bytes()))
    MazeStudio(model, args.chr.read_bytes()).mainloop()
    return 0


if __name__ == "__main__": raise SystemExit(main())
