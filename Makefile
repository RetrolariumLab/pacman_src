PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
CHR_OUT ?= $(PROJECT_DIR)pacman.chr
NATIVE_SOURCE ?= $(PROJECT_DIR)src/main.asm
NATIVE_CFG ?= $(PROJECT_DIR)src/nrom128_prg_only.cfg
BUILD_DIR ?= $(PROJECT_DIR)build
NATIVE_OBJ ?= $(BUILD_DIR)/pacman.o
NATIVE_PRG ?= $(BUILD_DIR)/pacman.prg
NATIVE_ROM ?= $(BUILD_DIR)/pacman.nes

# Instrumented FCEUX checkout used by reference capture and RTS analysis.
FCEUX_DIR ?= ../fceux_automation
FCEUX_REPO ?= https://github.com/oranguthang/fceux_automation.git
FCEUX_CONFIG ?= Release
FCEUX_PLATFORM ?= x64
FCEUX_TOOLSET ?= v143
FCEUX_EXE ?= $(FCEUX_DIR)/vc/$(FCEUX_PLATFORM)/$(FCEUX_CONFIG)/fceux64.exe
MSBUILD ?=

REFERENCE_DIR ?= reference
DIFFS_DIR ?= diffs
WORKFLOW_DIR ?= workflow
LONGPLAY_MOVIE_FILE ?= movies/pacman_j_longplay.fm2
MAX_FRAMES_LONGPLAY ?= 120000
ANALYSIS_INTERVAL ?= 20
CAPTURE_START_FRAME ?= 0
ANALYSIS_MAX_DIFFS ?= 20
ANALYSIS_WORKERS ?= 24
ANALYSIS_GRID_COLS ?= 6
ANALYSIS_WINDOW_W ?= 320
ANALYSIS_WINDOW_H ?= 260
ANALYSIS_REPORT_CSV ?= $(WORKFLOW_DIR)/analysis_report_longplay.csv
TILE_ASCII_MAP ?= $(PROJECT_DIR)config/tile_ascii_map.txt
COUNT ?= 32
START ?= 1
LINES ?= 250

.DEFAULT_GOAL := build

.PHONY: build verify run clean split build-dev reference analyze chunk help _manifest _batch

build:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--output-rom "$(NATIVE_ROM)"

verify:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--output-rom "$(NATIVE_ROM)" \
		--verify

run: build build-dev
	"$(FCEUX_EXE)" "$(NATIVE_ROM)"

clean:
	$(PYTHON) "$(PROJECT_DIR)scripts/clean_artifacts.py"

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/split_chr.py" "$(ORIGINAL_ROM)" "$(CHR_OUT)"

build-dev:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_dev.py" \
		--fceux-dir "$(FCEUX_DIR)" \
		--repo "$(FCEUX_REPO)" \
		--configuration "$(FCEUX_CONFIG)" \
		--platform "$(FCEUX_PLATFORM)" \
		--toolset "$(FCEUX_TOOLSET)" \
		--msbuild "$(MSBUILD)"

reference: build-dev
	@$(PYTHON) -c "import pathlib; pathlib.Path(r'$(REFERENCE_DIR)/longplay').mkdir(parents=True, exist_ok=True)"
	"$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-screenshot-interval $(ANALYSIS_INTERVAL) \
		-screenshot-start-frame $(CAPTURE_START_FRAME) \
		-screenshot-dir "$(REFERENCE_DIR)/longplay" \
		-max-frames $(MAX_FRAMES_LONGPLAY) \
		-save-state-dumps \
		-save-tile-ascii \
		-tile-ascii-map "$(TILE_ASCII_MAP)" \
		-turbo 1 \
		-nothrottle 1 \
		-pixel-perfect-window \
		"$(ORIGINAL_ROM)"
	@echo Reference saved to $(REFERENCE_DIR)/longplay

_manifest:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/build_procedure_manifest.py" \
		--listing "$(NATIVE_SOURCE)" \
		--output "$(PROJECT_DIR)$(WORKFLOW_DIR)/procedure_manifest.csv"

_batch: _manifest
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/prepare_rts_batch.py" \
		--manifest "$(PROJECT_DIR)$(WORKFLOW_DIR)/procedure_manifest.csv" \
		--count "$(COUNT)" \
		--output "$(PROJECT_DIR)$(WORKFLOW_DIR)/rts_batch.txt"

analyze: verify build-dev _batch
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(REFERENCE_DIR)/longplay'); p.is_dir() or (_ for _ in ()).throw(SystemExit('[ERROR] Missing reference capture; run make reference first.'))"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/analyze_subroutines.py" \
		--listing "$(NATIVE_SOURCE)" \
		--manifest "$(PROJECT_DIR)$(WORKFLOW_DIR)/procedure_manifest.csv" \
		--batch "$(PROJECT_DIR)$(WORKFLOW_DIR)/rts_batch.txt" \
		--original-rom "$(ORIGINAL_ROM)" \
		--movie "$(LONGPLAY_MOVIE_FILE)" \
		--fceux "$(FCEUX_EXE)" \
		--reference-dir "$(REFERENCE_DIR)/longplay" \
		--diff-root "$(DIFFS_DIR)/longplay/subroutines" \
		--output-report "$(ANALYSIS_REPORT_CSV)" \
		--interval "$(ANALYSIS_INTERVAL)" \
		--max-diffs "$(ANALYSIS_MAX_DIFFS)" \
		--max-frames "$(MAX_FRAMES_LONGPLAY)" \
		--workers "$(ANALYSIS_WORKERS)" \
		--grid-cols "$(ANALYSIS_GRID_COLS)" \
		--window-width "$(ANALYSIS_WINDOW_W)" \
		--window-height "$(ANALYSIS_WINDOW_H)" \
		--pixel-perfect \
		--turbo \
		--nothrottle
	@echo Analysis complete: $(ANALYSIS_REPORT_CSV)

chunk:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/extract_rename_chunk.py" \
		--source "$(NATIVE_SOURCE)" \
		--start-line "$(START)" \
		--line-count "$(LINES)" \
		--output-csv "$(PROJECT_DIR)$(WORKFLOW_DIR)/rename_chunk.csv" \
		--output-snippet "$(PROJECT_DIR)$(WORKFLOW_DIR)/chunk_$(START)_$(LINES).asm"
	@echo Chunk snippet: $(WORKFLOW_DIR)/chunk_$(START)_$(LINES).asm
	@echo Rename template: $(WORKFLOW_DIR)/rename_chunk.csv

help:
	@echo Pac-Man disassembly targets:
	@echo   make build                 Build the native ca65 ROM
	@echo   make verify                Build and verify byte-identity
	@echo   make run                   Build and run the ROM in FCEUX
	@echo   make clean                 Remove local build and analysis artifacts
	@echo   make split                 Extract CHR from the original ROM
	@echo   make build-dev             Check tools and clone/build FCEUX if needed
	@echo   make reference             Capture the longplay reference set
	@echo   make analyze COUNT=32      Run the reverse-engineering analysis
	@echo   make chunk START=260 LINES=60  Prepare a rename/analysis chunk
	@echo   make help                  Show these public targets

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
