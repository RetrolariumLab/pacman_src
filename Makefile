PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
NATIVE_SOURCE ?= $(PROJECT_DIR)src/main.asm
NATIVE_CFG ?= $(PROJECT_DIR)src/nrom128_prg_only.cfg
BUILD_DIR ?= $(PROJECT_DIR)build
NATIVE_OBJ ?= $(BUILD_DIR)/pacman.o
NATIVE_PRG ?= $(BUILD_DIR)/pacman.prg
NATIVE_ROM ?= $(BUILD_DIR)/pacman.nes
NATIVE_LABELS ?= $(BUILD_DIR)/pacman.lbl
ASSET_MANIFEST ?= $(PROJECT_DIR)assets/manifest.json
GENERATED_ASSET_DIR ?= $(PROJECT_DIR)assets/generated
GENERATED_CHR ?= $(GENERATED_ASSET_DIR)/chr/pacman.chr

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
SCORING_TRACE ?= $(PROJECT_DIR)tmp/scoring_trace.csv
SCORING_SCENARIOS ?= $(PROJECT_DIR)scenarios/scoring_trace.json
SCORING_MAX_FRAMES ?= $(MAX_FRAMES_LONGPLAY)
SCORING_TRACE_LUA ?= $(PROJECT_DIR)scripts/workflow/capture_scoring_trace.lua

.DEFAULT_GOAL := build

.PHONY: build verify lint run clean split build-dev reference analyze trace-scoring validate-scoring-trace chunk help _require-assets _manifest _batch

build: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--output-rom "$(NATIVE_ROM)"

verify: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--output-rom "$(NATIVE_ROM)" \
		--verify

lint:
	$(PYTHON) "$(PROJECT_DIR)scripts/lint_source.py"

run: build build-dev
	"$(FCEUX_EXE)" "$(NATIVE_ROM)"

clean:
	$(PYTHON) "$(PROJECT_DIR)scripts/clean_artifacts.py"

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/split_assets.py" \
		--rom "$(ORIGINAL_ROM)" \
		--manifest "$(ASSET_MANIFEST)" \
		--output-dir "$(GENERATED_ASSET_DIR)"

_require-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/check_assets.py" \
		--manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)"

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

_manifest: verify
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/build_procedure_manifest.py" \
		--labels "$(NATIVE_LABELS)" \
		--output "$(PROJECT_DIR)$(WORKFLOW_DIR)/procedure_manifest.csv"

_batch: _manifest
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/prepare_rts_batch.py" \
		--manifest "$(PROJECT_DIR)$(WORKFLOW_DIR)/procedure_manifest.csv" \
		--count "$(COUNT)" \
		--output "$(PROJECT_DIR)$(WORKFLOW_DIR)/rts_batch.txt"

analyze: build-dev _batch
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(REFERENCE_DIR)/longplay'); p.is_dir() or (_ for _ in ()).throw(SystemExit('[ERROR] Missing reference capture; run make reference first.'))"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/analyze_subroutines.py" \
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

trace-scoring: build-dev verify
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(PROJECT_DIR)tmp'); p.mkdir(parents=True, exist_ok=True); t=pathlib.Path(r'$(SCORING_TRACE)'); t.unlink() if t.exists() else None"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/check_scoring_trace_setup.py" \
		--fceux "$(FCEUX_EXE)" \
		--labels "$(NATIVE_LABELS)" \
		--lua "$(SCORING_TRACE_LUA)"
	set "PACMAN_SCORING_TRACE=$(SCORING_TRACE)" && set "PACMAN_SCORING_MAX_FRAMES=$(SCORING_MAX_FRAMES)" && "$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-lua "$(subst /,\,$(SCORING_TRACE_LUA))" \
		-max-frames "$(SCORING_MAX_FRAMES)" \
		-turbo 1 \
		-nothrottle 1 \
		"$(NATIVE_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/check_scoring_trace_setup.py" \
		--fceux "$(FCEUX_EXE)" \
		--labels "$(NATIVE_LABELS)" \
		--lua "$(SCORING_TRACE_LUA)" \
		--trace "$(SCORING_TRACE)"
	@echo Scoring trace saved to $(SCORING_TRACE)

validate-scoring-trace:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_scoring_trace.py" \
		--scenarios "$(SCORING_SCENARIOS)" \
		--trace "$(SCORING_TRACE)"

chunk: build
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/extract_rename_chunk.py" \
		--source "$(NATIVE_SOURCE)" \
		--labels "$(NATIVE_LABELS)" \
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
	@echo   make lint                  Run fast source and documentation checks
	@echo   make run                   Build and run the ROM in FCEUX
	@echo   make clean                 Remove build/analysis output; preserve assets
	@echo   make split                 Extract CHR, maze, and audio assets from the original ROM
	@echo   make build-dev             Check tools and clone/build FCEUX if needed
	@echo   make reference             Capture the longplay reference set
	@echo   make analyze COUNT=32      Run the reverse-engineering analysis
	@echo   make trace-scoring         Capture compact scoring events during longplay
	@echo   make validate-scoring-trace Validate expected scoring event sequences
	@echo   make chunk START=260 LINES=60  Prepare a rename/analysis chunk
	@echo   make help                  Show these public targets

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
