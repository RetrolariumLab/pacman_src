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
HACK_SOURCE ?= $(PROJECT_DIR)src/main_hack.asm
HACK_OBJ ?= $(BUILD_DIR)/hack/pacman.o
HACK_PRG ?= $(BUILD_DIR)/hack/pacman.prg
HACK_ROM ?= $(BUILD_DIR)/hack/pacman.nes
HACK_LABELS ?= $(BUILD_DIR)/hack/pacman.lbl
HACK_MAP ?= $(BUILD_DIR)/hack/pacman.map
HACK_DEBUG ?= $(BUILD_DIR)/hack/pacman.dbg
HACK_DEBUG_SUMMARY ?= $(BUILD_DIR)/hack/debug_symbols.json
HACK_CHR ?= $(GENERATED_CHR)
HACK_MANIFEST ?= $(PROJECT_DIR)config/hack_variants.json
HACK_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_hack_variant.lua
HACK_RUNTIME_RESULT ?= $(PROJECT_DIR)tmp/hack_variant_runtime.txt
EXPANDED_SOURCE ?= $(PROJECT_DIR)src/main_expanded.asm
EXPANDED_CFG ?= $(PROJECT_DIR)src/nrom256_expanded.cfg
EXPANDED_DIR ?= $(BUILD_DIR)/expanded
EXPANDED_OBJ ?= $(EXPANDED_DIR)/pacman.o
EXPANDED_PRG ?= $(EXPANDED_DIR)/pacman.prg
EXPANDED_ROM ?= $(EXPANDED_DIR)/pacman.nes
EXPANDED_LABELS ?= $(EXPANDED_DIR)/pacman.lbl
EXPANDED_MAP ?= $(EXPANDED_DIR)/pacman.map
EXPANDED_DEBUG ?= $(EXPANDED_DIR)/pacman.dbg
EXPANDED_DEBUG_SUMMARY ?= $(EXPANDED_DIR)/debug_symbols.json
EXPANDED_MAZE_JSON ?= $(PROJECT_DIR)hacks/local/maze.json
EXPANDED_MAZE_BIN ?= $(EXPANDED_DIR)/assets/maze.rle
EXPANDED_STAGE_JSON ?= $(PROJECT_DIR)hacks/local/stage_parameters.json
EXPANDED_STAGE_BIN ?= $(EXPANDED_DIR)/assets/stage_parameters.bin
EXPANDED_SOUND_JSON ?= $(PROJECT_DIR)hacks/local/sound_streams.json
EXPANDED_SOUND_BIN ?= $(EXPANDED_DIR)/assets/sound_streams.bin
EXPANDED_SOUND_POINTERS_BIN ?= $(EXPANDED_DIR)/assets/sound_pointers.bin
EXPANDED_ACTOR_JSON ?= $(PROJECT_DIR)hacks/local/actor_sprites.json
EXPANDED_ACTOR_BIN ?= $(EXPANDED_DIR)/assets/actor_sprites.bin
SOUND_SLOT ?= 4
SOUND_PREVIEW ?= $(PROJECT_DIR)tmp/sound_preview.wav
MIDI_FILE ?=
MIDI_TRACK ?= 0
MIDI_CHANNEL ?= 0
MIDI_OUTPUT ?= $(PROJECT_DIR)hacks/local/sound_streams.midi.json
EXPANDED_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_expanded_rom.lua
EXPANDED_RUNTIME_RESULT ?= $(PROJECT_DIR)tmp/expanded_rom_runtime.txt
DEBUG_SUMMARY ?= $(BUILD_DIR)/debug_symbols.json
FCEUX_SYMBOL_DIR ?= $(BUILD_DIR)
DEBUG_BREAKPOINTS ?= $(PROJECT_DIR)config/debugger_breakpoints.json
DEBUG_WATCHES ?= $(PROJECT_DIR)config/debugger_watches.json
DEBUG_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_debug_symbols.lua
DEBUG_RUNTIME_RESULT ?= $(PROJECT_DIR)tmp/debug_symbols_runtime.txt
ASSET_MANIFEST ?= $(PROJECT_DIR)assets/manifest.json
GENERATED_ASSET_DIR ?= $(PROJECT_DIR)assets/generated
GENERATED_CHR ?= $(GENERATED_ASSET_DIR)/chr/pacman.chr
EDITED_CHR ?= $(PROJECT_DIR)hacks/local/pacman.chr

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

.PHONY: build verify build-hack verify-hack symbols-hack validate-hack run-hack init-expanded-assets expanded-assets build-expanded verify-expanded symbols-expanded validate-expanded run-expanded sound-studio maze-studio graphics-studio describe-sound preview-sound import-midi symbols test test-debug-symbols test-runtime-traces validate-symbols lint roundtrip-formats preservation-audit run clean split build-dev reference analyze trace-scoring validate-scoring-trace trace-runtime validate-runtime-traces chunk help _require-assets _manifest _batch

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

build-hack: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(HACK_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(HACK_CHR)" \
		--object "$(HACK_OBJ)" \
		--prg "$(HACK_PRG)" \
		--labels "$(HACK_LABELS)" \
		--map "$(HACK_MAP)" \
		--debug-info "$(HACK_DEBUG)" \
		--output-rom "$(HACK_ROM)"

verify-hack: build-hack
	$(PYTHON) "$(PROJECT_DIR)scripts/verify_hack.py" \
		--original "$(ORIGINAL_ROM)" \
		--candidate "$(HACK_ROM)" \
		--manifest "$(HACK_MANIFEST)" \
		--variant default

symbols-hack: verify-hack
	$(PYTHON) "$(PROJECT_DIR)scripts/debug_symbols.py" \
		--debug "$(HACK_DEBUG)" \
		--map "$(HACK_MAP)" \
		--labels "$(HACK_LABELS)" \
		--rom "$(HACK_ROM)" \
		--fceux-output-dir "$(dir $(HACK_ROM))" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(HACK_DEBUG_SUMMARY)"

validate-hack: build-dev symbols-hack
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(PROJECT_DIR)tmp'); p.mkdir(parents=True, exist_ok=True); r=pathlib.Path(r'$(HACK_RUNTIME_RESULT)'); r.unlink() if r.exists() else None"
	set "PACMAN_HACK_RUNTIME_RESULT=$(HACK_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-lua "$(subst /,\,$(HACK_RUNTIME_LUA))" \
		-max-frames "10000" \
		-turbo 1 \
		-nothrottle 1 \
		"$(HACK_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_hack_runtime.py" \
		--result "$(HACK_RUNTIME_RESULT)" \
		--expected-stage 5

init-expanded-assets: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/prepare_expanded_assets.py" init \
		--maze-source "$(PROJECT_DIR)assets/generated/maze/maze.rle" \
		--maze-json "$(EXPANDED_MAZE_JSON)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--stage-json "$(EXPANDED_STAGE_JSON)" \
		--asset-manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)" \
		--sound-json "$(EXPANDED_SOUND_JSON)" \
		--actor-json "$(EXPANDED_ACTOR_JSON)" \
		--demo-frightened-duration 14

expanded-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/prepare_expanded_assets.py" encode \
		--maze-source "$(PROJECT_DIR)assets/generated/maze/maze.rle" \
		--maze-json "$(EXPANDED_MAZE_JSON)" \
		--maze-output "$(EXPANDED_MAZE_BIN)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--stage-json "$(EXPANDED_STAGE_JSON)" \
		--stage-output "$(EXPANDED_STAGE_BIN)" \
		--asset-manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)" \
		--sound-json "$(EXPANDED_SOUND_JSON)" \
		--sound-output "$(EXPANDED_SOUND_BIN)" \
		--sound-pointers-output "$(EXPANDED_SOUND_POINTERS_BIN)" \
		--actor-json "$(EXPANDED_ACTOR_JSON)" \
		--actor-output "$(EXPANDED_ACTOR_BIN)"

build-expanded: _require-assets expanded-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_expanded.py" \
		--source "$(EXPANDED_SOURCE)" \
		--config "$(EXPANDED_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(EXPANDED_OBJ)" \
		--prg "$(EXPANDED_PRG)" \
		--labels "$(EXPANDED_LABELS)" \
		--map "$(EXPANDED_MAP)" \
		--debug-info "$(EXPANDED_DEBUG)" \
		--output-rom "$(EXPANDED_ROM)"

verify-expanded: build-expanded
	$(PYTHON) "$(PROJECT_DIR)scripts/verify_expanded.py" \
		--original "$(ORIGINAL_ROM)" \
		--candidate "$(EXPANDED_ROM)" \
		--maze-original "$(PROJECT_DIR)assets/generated/maze/maze.rle" \
		--maze-stage2 "$(EXPANDED_MAZE_BIN)" \
		--stage "$(EXPANDED_STAGE_BIN)" \
		--sound-pointers "$(EXPANDED_SOUND_POINTERS_BIN)" \
		--sound-streams "$(EXPANDED_SOUND_BIN)" \
		--actors "$(EXPANDED_ACTOR_BIN)" \
		--expected-chr "$(GENERATED_CHR)" \
		--layout "$(PROJECT_DIR)config/expanded_layout.json"

symbols-expanded: verify-expanded
	$(PYTHON) "$(PROJECT_DIR)scripts/debug_symbols.py" \
		--debug "$(EXPANDED_DEBUG)" \
		--map "$(EXPANDED_MAP)" \
		--labels "$(EXPANDED_LABELS)" \
		--rom "$(EXPANDED_ROM)" \
		--fceux-output-dir "$(EXPANDED_DIR)" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(EXPANDED_DEBUG_SUMMARY)"

validate-expanded: build-dev symbols-expanded
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(PROJECT_DIR)tmp'); p.mkdir(parents=True, exist_ok=True); r=pathlib.Path(r'$(EXPANDED_RUNTIME_RESULT)'); r.unlink() if r.exists() else None"
	set "PACMAN_EXPANDED_RUNTIME_RESULT=$(EXPANDED_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-lua "$(subst /,\,$(EXPANDED_RUNTIME_LUA))" \
		-max-frames "10000" \
		-turbo 1 \
		-nothrottle 1 \
		"$(EXPANDED_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_expanded_runtime.py" \
		--result "$(EXPANDED_RUNTIME_RESULT)" \
		--stage-json "$(EXPANDED_STAGE_JSON)" \
		--sound-json "$(EXPANDED_SOUND_JSON)"

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

run-hack: build-hack build-dev
	"$(FCEUX_EXE)" "$(HACK_ROM)"

run-expanded: build-expanded build-dev
	"$(FCEUX_EXE)" "$(EXPANDED_ROM)"

sound-studio:
	$(PYTHON) "$(PROJECT_DIR)scripts/sound_studio.py" \
		--sound-json "$(EXPANDED_SOUND_JSON)" \
		--asset-manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)"

maze-studio:
	$(PYTHON) "$(PROJECT_DIR)scripts/maze_studio.py" \
		--maze-json "$(EXPANDED_MAZE_JSON)" \
		--original-rle "$(GENERATED_ASSET_DIR)/maze/maze.rle" \
		--chr "$(GENERATED_CHR)"

graphics-studio:
	$(PYTHON) "$(PROJECT_DIR)scripts/graphics_studio.py" \
		--chr "$(GENERATED_ASSET_DIR)/chr/pacman.chr" \
		--output "$(EDITED_CHR)" \
		--actors "$(EXPANDED_ACTOR_JSON)" \
		--rom "$(ORIGINAL_ROM)" \
		--project "$(PROJECT_DIR)"

describe-sound:
	$(PYTHON) "$(PROJECT_DIR)scripts/sound_authoring.py" \
		--input "$(EXPANDED_SOUND_JSON)" \
		--slot "$(SOUND_SLOT)"

preview-sound:
	$(PYTHON) "$(PROJECT_DIR)scripts/render_sound_preview.py" \
		--sound-json "$(EXPANDED_SOUND_JSON)" \
		--slot "$(SOUND_SLOT)" \
		--output "$(SOUND_PREVIEW)"

import-midi:
	@$(PYTHON) -c "import sys; sys.exit(0 if r'$(MIDI_FILE)' else 'Set MIDI_FILE=path/to/file.mid')"
	$(PYTHON) "$(PROJECT_DIR)scripts/midi_to_sound.py" \
		--midi "$(MIDI_FILE)" \
		--sound-json "$(EXPANDED_SOUND_JSON)" \
		--output "$(MIDI_OUTPUT)" \
		--slot "$(SOUND_SLOT)" \
		--track "$(MIDI_TRACK)" \
		--channel "$(MIDI_CHANNEL)"

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
	@echo   make build-hack            Build the isolated default ROM-hack variant
	@echo   make verify-hack           Require only the documented default hack diff
	@echo   make validate-hack         Prove the default hack starts on stage 5 in FCEUX
	@echo   make run-hack              Build and run the default hack in FCEUX
	@echo   make init-expanded-assets  Create editable local maze JSON once
	@echo   make build-expanded        Build the JSON-backed NROM-256 variant
	@echo   make verify-expanded       Verify expanded layout, fixed bank, and maze
	@echo   make validate-expanded     Prove expanded maze access in FCEUX
	@echo   make run-expanded          Build and run the expanded variant in FCEUX
	@echo   make graphics-studio       Open the local CHR and metasprite editor
	@echo   make sound-studio          Open the local sound editor and piano roll
	@echo   make maze-studio           Open the local CHR-backed maze editor
	@echo   make describe-sound        Show musical notes for SOUND_SLOT, default 4
	@echo   make preview-sound         Render SOUND_SLOT to tmp/sound_preview.wav
	@echo   make import-midi MIDI_FILE=x.mid  Import mono MIDI to an ignored JSON copy
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
