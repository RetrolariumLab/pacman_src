PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
NATIVE_SOURCE ?= $(PROJECT_DIR)src/main.asm
NATIVE_CFG ?= $(PROJECT_DIR)config/linker/nrom128_prg_only.cfg
BUILD_DIR ?= $(PROJECT_DIR)build
NATIVE_OBJ ?= $(BUILD_DIR)/pacman.o
NATIVE_PRG ?= $(BUILD_DIR)/pacman.prg
NATIVE_ROM ?= $(BUILD_DIR)/pacman.nes
NATIVE_LABELS ?= $(BUILD_DIR)/pacman.lbl
NATIVE_MAP ?= $(BUILD_DIR)/pacman.map
NATIVE_DEBUG ?= $(BUILD_DIR)/pacman.dbg

ASSET_MANIFEST ?= $(PROJECT_DIR)assets/manifest.json
GENERATED_ASSET_DIR ?= $(PROJECT_DIR)assets/generated
GENERATED_CHR ?= $(GENERATED_ASSET_DIR)/chr/pacman.chr
REVISION_MANIFEST ?= $(PROJECT_DIR)config/revisions.json
REVISION ?= $(shell $(PYTHON) "$(PROJECT_DIR)scripts/revision_profiles.py" --manifest "$(REVISION_MANIFEST)" --print-default)
REVISION_BUILD_DIR ?= $(PROJECT_DIR)$(shell $(PYTHON) "$(PROJECT_DIR)scripts/revision_profiles.py" --manifest "$(REVISION_MANIFEST)" --profile "$(REVISION)" --print-output-dir)
REVISION_REFERENCE_DIR ?= $(PROJECT_DIR)
REVISION_DEBUG_SUMMARY ?= $(REVISION_BUILD_DIR)/debug_symbols.json
REVISION_SMOKE_SCENARIOS ?= $(PROJECT_DIR)scenarios/revision_smoke.json
REVISION_SMOKE_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_revision_smoke.lua
REVISION_SMOKE_DIR ?= $(BUILD_DIR)/runtime/revision_smokes
REVISION_REQUIRE_ALL ?=

SOURCE_2_1_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_1.json
SOURCE_2_2_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_2.json
TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/toolchain.json

# Instrumented FCEUX checkout used by runtime validation and analysis.
FCEUX_DIR ?= ../fceux_automation
FCEUX_CONFIG ?= Release
FCEUX_PLATFORM ?= x64
FCEUX_TOOLSET ?= v143
FCEUX_EXE ?= $(FCEUX_DIR)/vc/$(FCEUX_PLATFORM)/$(FCEUX_CONFIG)/fceux64.exe
MSBUILD ?=

include $(PROJECT_DIR)mk/authoring.mk
include $(PROJECT_DIR)mk/runtime.mk
include $(PROJECT_DIR)mk/validation.mk

.DEFAULT_GOAL := build

.PHONY: build verify build-revision verify-revision verify-revisions symbols-revision smoke-revisions smoke-regional-revisions build-hack verify-hack symbols-hack validate-hack run-hack init-expanded-assets expanded-assets build-expanded verify-expanded symbols-expanded validate-expanded run-expanded sound-studio maze-studio graphics-studio screen-studio describe-sound preview-sound import-midi symbols test test-debug-symbols test-runtime-traces validate-symbols test-relocation format lint roundtrip-formats reconstruction-audit reconstruction-audit-2 source-2-1-audit source-2-1-release-audit source-2-1-post-tag-audit source-2-1-baseline-check source-2-1-check source-2-2-audit source-2-2-release-audit source-2-2-post-tag-audit source-2-2-check run clean split build-dev reference analyze trace-scoring validate-scoring-trace trace-runtime validate-runtime-traces trace-evidence validate-evidence chunk help _require-assets _manifest _batch

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

build-revision: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_revision.py" \
		--manifest "$(REVISION_MANIFEST)" \
		--profile "$(REVISION)" \
		--reference-dir "$(REVISION_REFERENCE_DIR)" \
		--project-dir "$(PROJECT_DIR)"

verify-revision: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build_revision.py" \
		--manifest "$(REVISION_MANIFEST)" \
		--profile "$(REVISION)" \
		--reference-dir "$(REVISION_REFERENCE_DIR)" \
		--project-dir "$(PROJECT_DIR)" \
		--verify

verify-revisions:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/verify_revision_matrix.py" \
		--manifest "$(REVISION_MANIFEST)" \
		--reference-dir "$(REVISION_REFERENCE_DIR)" \
		--project-dir "$(PROJECT_DIR)" \
		--make "$(MAKE)" $(REVISION_REQUIRE_ALL)

symbols-revision: build-revision
	$(PYTHON) "$(PROJECT_DIR)scripts/debug_symbols.py" \
		--debug "$(REVISION_BUILD_DIR)/pacman.dbg" \
		--map "$(REVISION_BUILD_DIR)/pacman.map" \
		--labels "$(REVISION_BUILD_DIR)/pacman.lbl" \
		--rom "$(REVISION_BUILD_DIR)/pacman.nes" \
		--fceux-output-dir "$(REVISION_BUILD_DIR)" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(REVISION_DEBUG_SUMMARY)"

smoke-revisions: build-dev
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/run_revision_smokes.py" \
		--manifest "$(REVISION_MANIFEST)" \
		--scenarios "$(REVISION_SMOKE_SCENARIOS)" \
		--reference-dir "$(REVISION_REFERENCE_DIR)" \
		--project-dir "$(PROJECT_DIR)" \
		--fceux "$(FCEUX_EXE)" \
		--lua "$(REVISION_SMOKE_LUA)" \
		--output-dir "$(REVISION_SMOKE_DIR)" \
		--make "$(MAKE)" $(REVISION_REQUIRE_ALL)

# Compatibility alias retained for existing documentation and automation.
smoke-regional-revisions: smoke-revisions

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
		--manifest "$(TOOLCHAIN_MANIFEST)" \
		--configuration "$(FCEUX_CONFIG)" \
		--platform "$(FCEUX_PLATFORM)" \
		--toolset "$(FCEUX_TOOLSET)" \
		--msbuild "$(MSBUILD)"

chunk: build
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/extract_rename_chunk.py" \
		--source "$(NATIVE_SOURCE)" \
		--labels "$(NATIVE_LABELS)" \
		--start-line "$(START)" \
		--line-count "$(LINES)" \
		--output-csv "$(WORKFLOW_DIR)/rename_chunk.csv" \
		--output-snippet "$(WORKFLOW_DIR)/chunk_$(START)_$(LINES).asm"
	@echo Chunk snippet: $(WORKFLOW_DIR)/chunk_$(START)_$(LINES).asm
	@echo Rename template: $(WORKFLOW_DIR)/rename_chunk.csv

help:
	@echo Pac-Man NES Source Reconstruction targets:
	@echo Build and revisions:
	@echo   make build                         Build the native ca65 ROM
	@echo   make verify                        Verify the Japan V1.0 ROM byte for byte
	@echo   make build-revision REVISION=name  Build one official revision
	@echo   make verify-revision REVISION=name Verify one official revision
	@echo   make verify-revisions              Verify every locally available revision
	@echo   make smoke-revisions               Boot all revision profiles and check OAM
	@echo   Revision names: japan_v10, japan_v11, japan_revb, usa_tengen_unlicensed,
	@echo                   usa_tengen, usa_namco, europe
	@echo Optional variants:
	@echo   make build-hack                    Build the isolated fixed-size hack
	@echo   make verify-hack                   Verify the documented hack diff
	@echo   make validate-hack                 Validate the hack in FCEUX
	@echo   make run-hack                      Build and run the hack
	@echo   make init-expanded-assets          Create six editable local JSON assets
	@echo   make build-expanded                Build the JSON-backed NROM-256 variant
	@echo   make verify-expanded               Verify its assets and fixed-bank operands
	@echo   make validate-expanded             Validate asset consumption in FCEUX
	@echo   make run-expanded                  Build and run the expanded variant
	@echo Authoring tools:
	@echo   make sound-studio                  Open the sound editor and piano roll
	@echo   make maze-studio                   Open the CHR-backed maze editor
	@echo   make graphics-studio               Open the CHR and metasprite editor
	@echo   make screen-studio                 Open the screen, text, and HUD editor
	@echo   make describe-sound                Show notes for SOUND_SLOT, default 4
	@echo   make preview-sound                 Render SOUND_SLOT to a WAV file
	@echo   make import-midi MIDI_FILE=x.mid   Import monophonic MIDI to local JSON
	@echo Validation and evidence:
	@echo   make format                        Normalize ca65 assembly style
	@echo   make lint                          Check assembly, source, and documentation
	@echo   make test                          Run all fast Python unit tests
	@echo   make symbols                       Build debugger symbols and FCEUX labels
	@echo   make validate-symbols              Validate symbols live in FCEUX
	@echo   make trace-scoring                 Capture scoring evidence
	@echo   make validate-scoring-trace        Revalidate scoring evidence
	@echo   make trace-runtime                 Capture focused runtime evidence
	@echo   make validate-runtime-traces       Revalidate runtime evidence
	@echo   make trace-evidence                Recapture resolved research evidence
	@echo   make validate-evidence             Revalidate existing research evidence
	@echo   make test-relocation               Test a progressively shifted ROM in FCEUX
	@echo   make roundtrip-formats             Round-trip documented binary formats
	@echo   make reconstruction-audit          Run the Source Reconstruction 1.0 gate
	@echo   make reconstruction-audit-2        Run the Source Reconstruction 2.0 gate
	@echo   make source-2-1-audit              Check the Source 2.1 repository contract
	@echo   make source-2-1-check              Run the tag-ready Source 2.1 gate
	@echo   make source-2-1-post-tag-audit     Verify the clean, annotated Source 2.1 tag
	@echo   make source-2-1-baseline-check     Re-run the accepted Source 2.1 guarantees
	@echo   make source-2-2-audit              Check the developing Source 2.2 contract
	@echo   make source-2-2-check              Run the tag-ready Source 2.2 gate
	@echo   make source-2-2-post-tag-audit     Verify the clean, annotated Source 2.2 tag
	@echo Workflow:
	@echo   make run                           Build and run the ROM in FCEUX
	@echo   make build-dev                     Prepare the FCEUX development tools
	@echo   make split                         Extract original ROM assets
	@echo   make reference                     Capture the longplay reference set
	@echo   make analyze COUNT=32              Run reverse-engineering analysis
	@echo   make chunk START=260 LINES=60      Prepare an analysis chunk
	@echo   make clean                         Remove generated output, keep assets
	@echo   make help                          Show these public targets
