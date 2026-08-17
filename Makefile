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
NATIVE_MAP ?= $(BUILD_DIR)/pacman.map
NATIVE_DEBUG ?= $(BUILD_DIR)/pacman.dbg
DEBUG_SUMMARY ?= $(BUILD_DIR)/debug_symbols.json
FCEUX_SYMBOL_DIR ?= $(BUILD_DIR)
DEBUG_BREAKPOINTS ?= $(PROJECT_DIR)config/debugger_breakpoints.json
DEBUG_WATCHES ?= $(PROJECT_DIR)config/debugger_watches.json
DEBUG_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_debug_symbols.lua
DEBUG_RUNTIME_RESULT ?= $(PROJECT_DIR)tmp/debug_symbols_runtime.txt
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
RUNTIME_SCENARIOS ?= $(PROJECT_DIR)scenarios/runtime_trace.json
RUNTIME_TRACE_LUA ?= $(PROJECT_DIR)scripts/workflow/capture_runtime_trace.lua
RUNTIME_TRACE_DIR ?= $(PROJECT_DIR)tmp/runtime_traces
DATA_FORMAT_CONFIG ?= $(PROJECT_DIR)config/data_formats.json
DATA_FORMAT_OUTPUT_DIR ?= $(PROJECT_DIR)tmp/data_formats

.DEFAULT_GOAL := build

.PHONY: build verify symbols test test-debug-symbols test-runtime-traces validate-symbols lint roundtrip-formats preservation-audit run clean split build-dev reference analyze trace-scoring validate-scoring-trace trace-runtime validate-runtime-traces chunk help _require-assets _manifest _batch

build: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--map "$(NATIVE_MAP)" \
		--debug-info "$(NATIVE_DEBUG)" \
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
		--map "$(NATIVE_MAP)" \
		--debug-info "$(NATIVE_DEBUG)" \
		--output-rom "$(NATIVE_ROM)" \
		--verify

symbols: build
	$(PYTHON) "$(PROJECT_DIR)scripts/debug_symbols.py" \
		--debug "$(NATIVE_DEBUG)" \
		--map "$(NATIVE_MAP)" \
		--labels "$(NATIVE_LABELS)" \
		--rom "$(NATIVE_ROM)" \
		--fceux-output-dir "$(FCEUX_SYMBOL_DIR)" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(DEBUG_SUMMARY)"

test-debug-symbols:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)scripts/tests" -p "test_debug_symbols.py" -v

test-runtime-traces:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)scripts/tests" -p "test_runtime_traces.py" -v

test:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)scripts/tests" -p "test_*.py" -v

validate-symbols: build-dev symbols
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(PROJECT_DIR)tmp'); p.mkdir(parents=True, exist_ok=True); r=pathlib.Path(r'$(DEBUG_RUNTIME_RESULT)'); r.unlink() if r.exists() else None"
	set "PACMAN_DEBUG_SYMBOL_RESULT=$(DEBUG_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-lua "$(subst /,\,$(DEBUG_RUNTIME_LUA))" \
		-max-frames "120" \
		-turbo 1 \
		-nothrottle 1 \
		"$(NATIVE_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_debug_runtime.py" \
		--result "$(DEBUG_RUNTIME_RESULT)"

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

trace-runtime: build-dev symbols
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/run_runtime_traces.py" \
		--fceux "$(FCEUX_EXE)" \
		--rom "$(NATIVE_ROM)" \
		--movie "$(LONGPLAY_MOVIE_FILE)" \
		--lua "$(RUNTIME_TRACE_LUA)" \
		--scenarios "$(RUNTIME_SCENARIOS)" \
		--output-dir "$(RUNTIME_TRACE_DIR)"
	$(MAKE) validate-runtime-traces

validate-runtime-traces:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_runtime_traces.py" \
		--scenarios "$(RUNTIME_SCENARIOS)" \
		--trace-dir "$(RUNTIME_TRACE_DIR)"

roundtrip-formats: verify
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/roundtrip_data_formats.py" \
		--rom "$(NATIVE_ROM)" \
		--asset-dir "$(GENERATED_ASSET_DIR)" \
		--asset-manifest "$(ASSET_MANIFEST)" \
		--config "$(DATA_FORMAT_CONFIG)" \
		--output-dir "$(DATA_FORMAT_OUTPUT_DIR)"

# Release-candidate gate. Recursive calls keep emulator capture and validation
# ordered even when the parent make is invoked with parallel jobs.
preservation-audit:
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) roundtrip-formats
	$(MAKE) validate-symbols
	$(MAKE) trace-runtime
	$(MAKE) trace-scoring
	$(MAKE) validate-scoring-trace

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
	@echo   make symbols               Build Mesen debug/map and FCEUX label artifacts
	@echo   make test-debug-symbols    Run focused symbol conversion unit tests
	@echo   make test-runtime-traces   Run focused runtime validator unit tests
	@echo   make test                  Run all fast Python workflow unit tests
	@echo   make validate-symbols      Prove FCEUX symbol lookup and semantic breakpoint
	@echo   make lint                  Run fast source and documentation checks
	@echo   make run                   Build and run the ROM in FCEUX
	@echo   make clean                 Remove build/analysis output; preserve assets
	@echo   make split                 Extract CHR, maze, and audio assets from the original ROM
	@echo   make build-dev             Check tools and clone/build FCEUX if needed
	@echo   make reference             Capture the longplay reference set
	@echo   make analyze COUNT=32      Run the reverse-engineering analysis
	@echo   make trace-scoring         Capture compact scoring events during longplay
	@echo   make validate-scoring-trace Validate expected scoring event sequences
	@echo   make trace-runtime          Capture and validate focused runtime scenarios
	@echo   make validate-runtime-traces Validate existing focused runtime traces
	@echo   make roundtrip-formats      Decode and byte-round-trip documented data formats
	@echo   make preservation-audit     Run the complete Preservation Source 1.0 gate
	@echo   make chunk START=260 LINES=60  Prepare a rename/analysis chunk
	@echo   make help                  Show these public targets

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
