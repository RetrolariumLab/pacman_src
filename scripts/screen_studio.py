#!/usr/bin/env python3
"""Standalone Tk editor for title, attract, HUD, and intermission visuals."""

from __future__ import annotations

import argparse
import subprocess
import sys
import tkinter as tk
from pathlib import Path
from tkinter import messagebox, ttk

from graphics_studio_model import decode_chr
from graphics_studio import NES_RGB
from palette_assets import decode_palette_collection, load_palette_document
from screen_assets import (
    ScreenDocument,
    TEXT_MESSAGES,
    decode_screen_collection,
    load_screen_document,
    parse_tile_text,
    tile_text,
)


EDITABLE_RAW = {
    "Title palette attributes": "title_attributes",
    "Menu prompt packet": "menu_prompt",
    "Player-count glyphs": "player_count_glyphs",
    "HUD blocks": "hud_blocks",
    "HUD player packets": "hud_player_packets",
    "Pause visible/blank": "pause_tiles",
}

VISUAL_TABLES = {
    "Cycle tiles": "cycle_tiles",
    "Cycle pattern indexes": "cycle_pattern_indexes",
    "Banner tile quads": "banner_tile_quads",
}


class ScreenStudio(tk.Tk):
    def __init__(self, rom: Path, chr_path: Path, screen_path: Path, palette_path: Path,
                 project: Path) -> None:
        super().__init__()
        self.title("Pac-Man Screen Studio")
        self.geometry("1280x860")
        self.minsize(1100, 720)
        self.project = project
        self.tiles = decode_chr(chr_path.read_bytes())
        rom_data = rom.read_bytes()
        self.screen: ScreenDocument = load_screen_document(
            screen_path, decode_screen_collection(rom_data)
        )
        self.palettes = load_palette_document(
            palette_path, decode_palette_collection(rom_data)
        )
        self.selected_tile = tk.IntVar(value=0x20)
        self.packet_group = tk.StringVar(value="title_packets")
        self.packet_index = tk.IntVar(value=0)
        self.packet_address = tk.StringVar()
        self.packet_text = tk.StringVar()
        self.raw_section = tk.StringVar(value=next(iter(EDITABLE_RAW)))
        self.raw_hex = tk.StringVar()
        self.message_key = tk.StringVar(value=TEXT_MESSAGES[0]["key"])
        self.message_text = tk.StringVar()
        self.visual_section = tk.StringVar(value=next(iter(VISUAL_TABLES)))
        self.visual_hex = tk.StringVar()
        self.status = tk.StringVar()
        self._build_ui()
        self.protocol("WM_DELETE_WINDOW", self._close)
        self.bind("<Control-s>", lambda _event: self.save())
        self.refresh_all()

    def _build_ui(self) -> None:
        toolbar = ttk.Frame(self, padding=6)
        toolbar.pack(fill="x")
        for text, command in (("Save", self.save), ("Build expanded ROM", self.build_rom),
                              ("Run in FCEUX", self.run_rom)):
            ttk.Button(toolbar, text=text, command=command).pack(side="left", padx=2)
        ttk.Label(toolbar, textvariable=self.status).pack(side="right", padx=8)

        notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True, padx=6, pady=(0, 6))
        self._build_screen_tab(notebook)
        self._build_packet_tab(notebook)
        self._build_hud_tab(notebook)
        self._build_intermission_tab(notebook)

    def _build_screen_tab(self, notebook: ttk.Notebook) -> None:
        tab = ttk.Frame(notebook, padding=6)
        notebook.add(tab, text="Title Screen")
        preview = ttk.Frame(tab)
        preview.pack(side="left", fill="both", expand=True)
        ttk.Label(preview, text="Composed 32x30 nametable preview").pack(anchor="w")
        self.screen_canvas = tk.Canvas(preview, width=512, height=480, bg="#111111",
                                       highlightthickness=0)
        self.screen_canvas.pack(anchor="nw", pady=4)
        self.screen_canvas.bind("<Button-1>", self._paint_logo)

        browser = ttk.Frame(tab, padding=(10, 0, 0, 0))
        browser.pack(side="left", fill="y")
        ttk.Label(browser, text="Background tile bank").pack(anchor="w")
        self.tile_canvas = tk.Canvas(browser, width=384, height=384, bg="#202020",
                                     highlightthickness=0)
        self.tile_canvas.pack(pady=4)
        self.tile_canvas.bind("<Button-1>", self._select_tile)
        self.tile_label = ttk.Label(browser)
        self.tile_label.pack(anchor="w")
        ttk.Label(
            browser,
            text="Select a tile, then click inside the 23x6 title-logo rectangle. "
                 "Text packets are edited on the next tab.",
            wraplength=370,
        ).pack(anchor="w", pady=8)

    def _build_packet_tab(self, notebook: ttk.Notebook) -> None:
        tab = ttk.Frame(notebook, padding=12)
        notebook.add(tab, text="Text Packets")
        row = ttk.Frame(tab)
        row.pack(fill="x")
        ttk.Label(row, text="Group").pack(side="left")
        group = ttk.Combobox(row, textvariable=self.packet_group,
                             values=("title_packets", "attract_packets"), state="readonly", width=20)
        group.pack(side="left", padx=5)
        group.bind("<<ComboboxSelected>>", lambda _event: self._packet_group_changed())
        ttk.Label(row, text="Packet").pack(side="left", padx=(10, 2))
        self.packet_spin = ttk.Spinbox(row, from_=0, to=5, textvariable=self.packet_index,
                                       width=5, command=self.load_packet)
        self.packet_spin.pack(side="left")
        self.packet_spin.bind("<Return>", lambda _event: self.load_packet())

        form = ttk.LabelFrame(tab, text="Addressed PPU packet", padding=10)
        form.pack(fill="x", pady=12)
        ttk.Label(form, text="PPU address (hex)").grid(row=0, column=0, sticky="w")
        ttk.Entry(form, textvariable=self.packet_address, width=10).grid(row=0, column=1, sticky="w")
        ttk.Label(form, text="Text / tile notation").grid(row=1, column=0, sticky="nw", pady=(8, 0))
        ttk.Entry(form, textvariable=self.packet_text, width=90).grid(
            row=1, column=1, sticky="ew", pady=(8, 0))
        form.columnconfigure(1, weight=1)
        ttk.Button(form, text="Apply packet", command=self.apply_packet).grid(
            row=2, column=0, columnspan=2, sticky="ew", pady=(12, 0))
        ttk.Label(
            tab,
            text="Printable tile IDs use ordinary characters. Non-ASCII graphics use <XX>, "
                 "for example <C0><C1>. Zero bytes inside multi-command attract packets use <00>.",
            wraplength=900,
        ).pack(anchor="w")
        self.packet_preview = tk.Canvas(tab, width=512, height=480, bg="#111111",
                                        highlightthickness=0)
        self.packet_preview.pack(anchor="w", pady=12)

    def _build_hud_tab(self, notebook: ttk.Notebook) -> None:
        tab = ttk.Frame(notebook, padding=12)
        notebook.add(tab, text="HUD & Dynamic Text")
        messages = ttk.LabelFrame(tab, text="English game-font messages", padding=10)
        messages.pack(fill="x", pady=(0, 16))
        self.message_select = ttk.Combobox(
            messages, textvariable=self.message_key,
            values=tuple(item["key"] for item in TEXT_MESSAGES), state="readonly", width=28,
        )
        self.message_select.grid(row=0, column=0, sticky="w")
        self.message_select.bind("<<ComboboxSelected>>", lambda _event: self.load_message())
        self.message_label = ttk.Label(messages)
        self.message_label.grid(row=0, column=1, sticky="w", padx=10)
        ttk.Entry(messages, textvariable=self.message_text, width=70).grid(
            row=1, column=0, columnspan=2, sticky="ew", pady=(8, 0))
        ttk.Button(messages, text="Apply English text", command=self.apply_message).grid(
            row=2, column=0, columnspan=2, sticky="ew", pady=(8, 0))
        messages.columnconfigure(1, weight=1)
        ttk.Label(
            messages,
            text="Lowercase input maps to the game's uppercase glyphs. Unsupported symbols "
                 "are rejected; shorter messages are padded with spaces.",
            wraplength=900,
        ).grid(row=3, column=0, columnspan=2, sticky="w", pady=(8, 0))

        select = ttk.Combobox(tab, textvariable=self.raw_section, values=tuple(EDITABLE_RAW),
                              state="readonly", width=28)
        select.pack(anchor="w")
        select.bind("<<ComboboxSelected>>", lambda _event: self.load_raw())
        ttk.Label(tab, text="Fixed-layout bytes (hex, spaces optional)").pack(anchor="w", pady=(12, 2))
        ttk.Entry(tab, textvariable=self.raw_hex, width=110).pack(fill="x")
        ttk.Button(tab, text="Apply fixed-layout block", command=self.apply_raw).pack(
            anchor="w", pady=8)
        ttk.Label(
            tab,
            text="Addresses, lengths, terminators, and player-side packet widths are validated. "
                 "These blocks stay fixed-size because their consumers use hard-coded offsets.",
            wraplength=900,
        ).pack(anchor="w")

    def _build_intermission_tab(self, notebook: ttk.Notebook) -> None:
        tab = ttk.Frame(notebook, padding=12)
        notebook.add(tab, text="Intermission")
        ttk.Label(tab, text="Editable visual animation tables").pack(anchor="w")
        select = ttk.Combobox(tab, textvariable=self.visual_section, values=tuple(VISUAL_TABLES),
                              state="readonly", width=28)
        select.pack(anchor="w", pady=4)
        select.bind("<<ComboboxSelected>>", lambda _event: self.load_visual())
        ttk.Entry(tab, textvariable=self.visual_hex, width=100).pack(fill="x", pady=(6, 0))
        ttk.Button(tab, text="Apply visual table", command=self.apply_visual).pack(anchor="w", pady=8)
        ttk.Separator(tab).pack(fill="x", pady=12)
        ttk.Label(tab, text="Read-only code dispatch tables").pack(anchor="w")
        tree = ttk.Treeview(tab, columns=("address", "kind", "values"), show="headings", height=10)
        for column, title, width in (("address", "CPU address", 110), ("kind", "Kind", 90),
                                     ("values", "Handler values", 650)):
            tree.heading(column, text=title)
            tree.column(column, width=width, anchor="w")
        tree.pack(fill="both", expand=True, pady=5)
        for item in self.screen.document["read_only_code_tables"]:
            values = " ".join(f"${value:04X}" for value in item["values"])
            tree.insert("", "end", values=(f"${item['address']:04X}", item["kind"], values))
        ttk.Label(
            tab,
            text="These are executable handler pointers. They are catalogued for context but cannot be edited or exported as tiles.",
            wraplength=900,
        ).pack(anchor="w")

    def title_nametable(self) -> list[int]:
        nametable = [0x20] * (32 * 30)
        logo = self.screen.document["title_logo"]
        start = int(logo["ppu_address"]) - 0x2000
        for row in range(6):
            for column in range(23):
                nametable[start + row * 32 + column] = logo["tiles"][row * 23 + column]
        for packet in self.screen.document["title_packets"]:
            self._apply_packet_to_nametable(nametable, packet)
        menu = self.screen.document["menu_prompt"]
        self._apply_packet_to_nametable(nametable, {
            "address": menu[0] << 8 | menu[1], "bytes": menu[2:-1],
        })
        return nametable

    @staticmethod
    def _apply_packet_to_nametable(nametable: list[int], packet: dict[str, object]) -> None:
        address = int(packet["address"])
        cursor = address - 0x2000
        for value in packet["bytes"]:
            if value == 0x00:
                break
            if 0 <= cursor < len(nametable):
                nametable[cursor] = value
            cursor += 1

    def _title_palette_index(self, row: int, column: int) -> int:
        attr_address = 0x23C0 + (row // 4) * 8 + column // 4
        attrs = self.screen.document["title_attributes"]
        offset = attr_address - int(attrs["ppu_address"])
        if not 0 <= offset < len(attrs["bytes"]):
            return 0
        shift = ((row % 4) // 2) * 4 + ((column % 4) // 2) * 2
        return attrs["bytes"][offset] >> shift & 0x03

    def draw_nametable(self, canvas: tk.Canvas, nametable: list[int]) -> None:
        canvas.delete("all")
        palettes = self.palettes.document["title_background"]
        for row in range(30):
            for column in range(32):
                tile = self.tiles[nametable[row * 32 + column]]
                palette_index = self._title_palette_index(row, column)
                palette = palettes[palette_index * 4:palette_index * 4 + 4]
                for y in range(8):
                    for x in range(8):
                        color = NES_RGB[palette[tile[y][x]]]
                        left, top = (column * 8 + x) * 2, (row * 8 + y) * 2
                        canvas.create_rectangle(left, top, left + 2, top + 2, fill=color, outline="")

    def draw_tile_bank(self) -> None:
        self.tile_canvas.delete("all")
        palette = self.palettes.document["title_background"][:4]
        scale = 3
        for index in range(256):
            base_x, base_y = (index % 16) * 8 * scale, (index // 16) * 8 * scale
            for y in range(8):
                for x in range(8):
                    self.tile_canvas.create_rectangle(
                        base_x + x * scale, base_y + y * scale,
                        base_x + (x + 1) * scale, base_y + (y + 1) * scale,
                        fill=NES_RGB[palette[self.tiles[index][y][x]]], outline="",
                    )
        index = self.selected_tile.get()
        x, y = (index % 16) * 24, (index // 16) * 24
        self.tile_canvas.create_rectangle(x, y, x + 24, y + 24, outline="#FFFFFF", width=2)
        self.tile_label.configure(text=f"Selected tile ${index:02X}")

    def _select_tile(self, event: tk.Event) -> None:
        column, row = int(event.x) // 24, int(event.y) // 24
        if 0 <= column < 16 and 0 <= row < 16:
            self.selected_tile.set(row * 16 + column)
            self.draw_tile_bank()

    def _paint_logo(self, event: tk.Event) -> None:
        column, row = int(event.x) // 16, int(event.y) // 16
        logo_column, logo_row = column - 5, row - 7
        if not 0 <= logo_column < 23 or not 0 <= logo_row < 6:
            return
        values = list(self.screen.document["title_logo"]["tiles"])
        values[logo_row * 23 + logo_column] = self.selected_tile.get()
        self.screen.set_tiles("title_logo", values)
        self.refresh_all()

    def _packet_group_changed(self) -> None:
        self.packet_spin.configure(to=5 if self.packet_group.get() == "title_packets" else 9)
        self.packet_index.set(0)
        self.load_packet()

    def load_packet(self) -> None:
        group = self.packet_group.get()
        maximum = 5 if group == "title_packets" else 9
        index = max(0, min(int(self.packet_index.get()), maximum))
        self.packet_index.set(index)
        packet = self.screen.document[group][index]
        self.packet_address.set(f"{int(packet['address']):04X}")
        self.packet_text.set(tile_text(packet["bytes"]))
        nametable = [0x20] * (32 * 30)
        self._apply_packet_to_nametable(nametable, packet)
        self.draw_nametable(self.packet_preview, nametable)

    def apply_packet(self) -> None:
        try:
            address = int(self.packet_address.get().removeprefix("$"), 16)
            values = parse_tile_text(self.packet_text.get())
            self.screen.set_packet(self.packet_group.get(), int(self.packet_index.get()), address, values)
        except (ValueError, IndexError) as error:
            messagebox.showerror("Invalid packet", str(error))
            return
        self.refresh_all()

    def load_raw(self) -> None:
        section = EDITABLE_RAW[self.raw_section.get()]
        values = (self.screen.document[section]["bytes"] if section == "title_attributes"
                  else self.screen.document[section])
        self.raw_hex.set(" ".join(f"{value:02X}" for value in values))

    def load_message(self) -> None:
        spec = next(item for item in TEXT_MESSAGES if item["key"] == self.message_key.get())
        self.message_label.configure(text=f"{spec['label']} (max {spec['width']})")
        self.message_text.set(self.screen.get_message(spec["key"]))

    def apply_message(self) -> None:
        try:
            self.screen.set_message(self.message_key.get(), self.message_text.get())
        except ValueError as error:
            messagebox.showerror("Invalid English game text", str(error))
            return
        self.refresh_all()

    @staticmethod
    def _parse_hex(text: str) -> list[int]:
        compact = "".join(text.split())
        if len(compact) % 2:
            raise ValueError("Hex data must contain complete bytes")
        try:
            return list(bytes.fromhex(compact))
        except ValueError as error:
            raise ValueError("Hex data contains a non-hex character") from error

    def apply_raw(self) -> None:
        section = EDITABLE_RAW[self.raw_section.get()]
        try:
            self.screen.set_tiles(section, self._parse_hex(self.raw_hex.get()))
        except ValueError as error:
            messagebox.showerror("Invalid fixed-layout block", str(error))
            return
        self.refresh_all()

    def load_visual(self) -> None:
        key = VISUAL_TABLES[self.visual_section.get()]
        values = self.screen.document["intermission_visual"][key]
        self.visual_hex.set(" ".join(f"{value:02X}" for value in values))

    def apply_visual(self) -> None:
        key = VISUAL_TABLES[self.visual_section.get()]
        try:
            candidate = self._parse_hex(self.visual_hex.get())
            document = self.screen.document
            old = document["intermission_visual"][key]
            document["intermission_visual"][key] = candidate
            try:
                from screen_assets import validate_screen_collection
                validate_screen_collection(document)
            except ValueError:
                document["intermission_visual"][key] = old
                raise
        except ValueError as error:
            messagebox.showerror("Invalid visual table", str(error))
            return
        self.refresh_all()

    def refresh_all(self) -> None:
        self.status.set(f"{self.screen.path}{' *' if self.screen.dirty else ''}")
        self.draw_nametable(self.screen_canvas, self.title_nametable())
        self.draw_tile_bank()
        self.load_packet()
        self.load_message()
        self.load_raw()
        self.load_visual()

    def save(self) -> bool:
        try:
            path = self.screen.save()
        except (OSError, ValueError) as error:
            messagebox.showerror("Save failed", str(error))
            return False
        self.refresh_all()
        self.status.set(f"Saved validated screen project: {path}")
        return True

    def _make(self, target: str) -> None:
        if (self.screen.dirty or not self.screen.path.exists()) and not self.save():
            return
        variable = f"EXPANDED_SCREEN_JSON={self.screen.path.resolve().as_posix()}"
        if target == "run-expanded" and not self._run_make("verify-expanded", variable):
            return
        self._run_make(target, variable)

    def _run_make(self, target: str, variable: str) -> bool:
        try:
            completed = subprocess.run(["make", target, variable], cwd=self.project, check=False)
        except OSError as error:
            messagebox.showerror("Could not start make", str(error))
            return False
        if completed.returncode:
            messagebox.showerror("Build failed", f"make {target} exited with {completed.returncode}")
            return False
        self.status.set(f"make {target} completed")
        return True

    def build_rom(self) -> None:
        self._make("verify-expanded")

    def run_rom(self) -> None:
        self._make("run-expanded")

    def _close(self) -> None:
        if not self.screen.dirty or messagebox.askyesno("Unsaved screens", "Discard unsaved screen edits?"):
            self.destroy()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", required=True, type=Path)
    parser.add_argument("--chr", required=True, type=Path)
    parser.add_argument("--screens", required=True, type=Path)
    parser.add_argument("--palettes", required=True, type=Path)
    parser.add_argument("--project", type=Path, default=Path(__file__).resolve().parents[1])
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        app = ScreenStudio(args.rom.resolve(), args.chr.resolve(), args.screens.resolve(),
                           args.palettes.resolve(), args.project.resolve())
    except (OSError, ValueError) as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        return 1
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
