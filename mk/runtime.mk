# Emulator execution, capture, analysis, and relocation evidence.

REFERENCE_DIR ?= $(BUILD_DIR)/analysis/reference
DIFFS_DIR ?= $(BUILD_DIR)/analysis/diffs
WORKFLOW_DIR ?= $(BUILD_DIR)/analysis/workflow
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

SCORING_TRACE ?= $(BUILD_DIR)/runtime/scoring/scoring_trace.csv
SCORING_SCENARIOS ?= $(PROJECT_DIR)scenarios/scoring_trace.json
SCORING_MAX_FRAMES ?= $(MAX_FRAMES_LONGPLAY)
SCORING_TRACE_LUA ?= $(PROJECT_DIR)scripts/workflow/capture_scoring_trace.lua
RUNTIME_SCENARIOS ?= $(PROJECT_DIR)scenarios/runtime_trace.json
RUNTIME_TRACE_LUA ?= $(PROJECT_DIR)scripts/workflow/capture_runtime_trace.lua
RUNTIME_TRACE_DIR ?= $(BUILD_DIR)/runtime/traces
RECONSTRUCTION_EVIDENCE_SCENARIOS ?= $(PROJECT_DIR)scenarios/reconstruction_evidence.json
RECONSTRUCTION_EVIDENCE_LUA ?= $(PROJECT_DIR)scripts/workflow/capture_reconstruction_evidence.lua
RECONSTRUCTION_EVIDENCE_DIR ?= $(BUILD_DIR)/runtime/reconstruction_evidence

RELOCATION_DIR ?= $(BUILD_DIR)/relocation
RELOCATION_GENERATED_DIR ?= $(RELOCATION_DIR)/generated
RELOCATION_SOURCE ?= $(RELOCATION_GENERATED_DIR)/main.asm
RELOCATION_MANIFEST ?= $(RELOCATION_DIR)/layout.json
RELOCATION_PROBES ?= $(RELOCATION_DIR)/probe_addresses.txt
RELOCATION_OBJ ?= $(RELOCATION_DIR)/pacman.o
RELOCATION_PRG ?= $(RELOCATION_DIR)/pacman.prg
RELOCATION_ROM ?= $(RELOCATION_DIR)/pacman.nes
RELOCATION_LABELS ?= $(RELOCATION_DIR)/pacman.lbl
RELOCATION_MAP ?= $(RELOCATION_DIR)/pacman.map
RELOCATION_DEBUG ?= $(RELOCATION_DIR)/pacman.dbg
RELOCATION_DEBUG_SUMMARY ?= $(RELOCATION_DIR)/debug_symbols.json
RELOCATION_DEBUG_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_relocation_symbols.lua
RELOCATION_DEBUG_RESULT ?= $(RELOCATION_DIR)/runtime/debug_symbols.txt
RELOCATION_RUNTIME_SCENARIOS ?= $(RELOCATION_DIR)/runtime_trace.json
RELOCATION_RUNTIME_DIR ?= $(RELOCATION_DIR)/runtime/traces
RELOCATION_SCORING_TRACE ?= $(RELOCATION_DIR)/runtime/scoring_trace.csv
RELOCATION_EVIDENCE_SCENARIOS ?= $(RELOCATION_DIR)/reconstruction_evidence.json
RELOCATION_EVIDENCE_DIR ?= $(RELOCATION_DIR)/runtime/evidence
RELOCATION_MAX_FRAMES ?= 120000
RELOCATION_HEARTBEAT_INTERVAL ?= 5000

run: build build-dev
	"$(FCEUX_EXE)" "$(NATIVE_ROM)"

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
		--output "$(WORKFLOW_DIR)/procedure_manifest.csv"

_batch: _manifest
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/prepare_rts_batch.py" \
		--manifest "$(WORKFLOW_DIR)/procedure_manifest.csv" \
		--count "$(COUNT)" \
		--output "$(WORKFLOW_DIR)/rts_batch.txt"

analyze: build-dev _batch
	@$(PYTHON) -c "import pathlib; p=pathlib.Path(r'$(REFERENCE_DIR)/longplay'); p.is_dir() or (_ for _ in ()).throw(SystemExit('[ERROR] Missing reference capture; run make reference first.'))"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/analyze_subroutines.py" \
		--manifest "$(WORKFLOW_DIR)/procedure_manifest.csv" \
		--batch "$(WORKFLOW_DIR)/rts_batch.txt" \
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
	@$(PYTHON) -c "import pathlib; t=pathlib.Path(r'$(SCORING_TRACE)'); t.parent.mkdir(parents=True, exist_ok=True); t.unlink() if t.exists() else None"
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

trace-evidence: build-dev verify symbols
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/run_reconstruction_evidence.py" \
		--fceux "$(FCEUX_EXE)" \
		--rom "$(NATIVE_ROM)" \
		--movie "$(LONGPLAY_MOVIE_FILE)" \
		--lua "$(RECONSTRUCTION_EVIDENCE_LUA)" \
		--scenarios "$(RECONSTRUCTION_EVIDENCE_SCENARIOS)" \
		--output-dir "$(RECONSTRUCTION_EVIDENCE_DIR)"
	$(MAKE) validate-evidence

validate-evidence:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_reconstruction_evidence.py" \
		--scenarios "$(RECONSTRUCTION_EVIDENCE_SCENARIOS)" \
		--trace-dir "$(RECONSTRUCTION_EVIDENCE_DIR)" \
		--rom "$(NATIVE_ROM)" \
		--labels "$(NATIVE_LABELS)"

test-relocation: lint test build-dev symbols
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/relocation_test.py" prepare \
		--main "$(NATIVE_SOURCE)" \
		--output "$(RELOCATION_SOURCE)" \
		--manifest "$(RELOCATION_MANIFEST)"
	$(PYTHON) "$(PROJECT_DIR)scripts/build_native.py" \
		--source "$(RELOCATION_SOURCE)" \
		--include-dir "$(PROJECT_DIR)src" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(RELOCATION_OBJ)" \
		--prg "$(RELOCATION_PRG)" \
		--labels "$(RELOCATION_LABELS)" \
		--map "$(RELOCATION_MAP)" \
		--debug-info "$(RELOCATION_DEBUG)" \
		--output-rom "$(RELOCATION_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/relocation_test.py" verify-layout \
		--manifest "$(RELOCATION_MANIFEST)" \
		--provenance "$(PROJECT_DIR)docs/provenance/label_renames.json" \
		--base-labels "$(NATIVE_LABELS)" \
		--candidate-labels "$(RELOCATION_LABELS)" \
		--base-rom "$(NATIVE_ROM)" \
		--candidate-rom "$(RELOCATION_ROM)" \
		--probe-addresses-output "$(RELOCATION_PROBES)"
	$(PYTHON) "$(PROJECT_DIR)scripts/debug_symbols.py" \
		--debug "$(RELOCATION_DEBUG)" \
		--map "$(RELOCATION_MAP)" \
		--labels "$(RELOCATION_LABELS)" \
		--rom "$(RELOCATION_ROM)" \
		--fceux-output-dir "$(RELOCATION_DIR)" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(RELOCATION_DEBUG_SUMMARY)"
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(RELOCATION_DEBUG_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_DEBUG_SYMBOL_RESULT=$(RELOCATION_DEBUG_RESULT)" && "$(FCEUX_EXE)" \
		-lua "$(subst /,\,$(RELOCATION_DEBUG_LUA))" \
		-max-frames "120" \
		-turbo 1 \
		-nothrottle 1 \
		"$(RELOCATION_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_debug_runtime.py" \
		--result "$(RELOCATION_DEBUG_RESULT)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/relocation_test.py" prepare-scenario \
		--base "$(RUNTIME_SCENARIOS)" \
		--candidate-rom "$(RELOCATION_ROM)" \
		--output "$(RELOCATION_RUNTIME_SCENARIOS)" \
		--max-frames "$(RELOCATION_MAX_FRAMES)" \
		--heartbeat-interval "$(RELOCATION_HEARTBEAT_INTERVAL)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/run_runtime_traces.py" \
		--fceux "$(FCEUX_EXE)" \
		--rom "$(RELOCATION_ROM)" \
		--movie "$(LONGPLAY_MOVIE_FILE)" \
		--lua "$(RUNTIME_TRACE_LUA)" \
		--scenarios "$(RELOCATION_RUNTIME_SCENARIOS)" \
		--output-dir "$(RELOCATION_RUNTIME_DIR)" \
		--probe-addresses "$(RELOCATION_PROBES)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_runtime_traces.py" \
		--scenarios "$(RELOCATION_RUNTIME_SCENARIOS)" \
		--trace-dir "$(RELOCATION_RUNTIME_DIR)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/relocation_test.py" validate-runtime \
		--trace "$(RELOCATION_RUNTIME_DIR)/natural-longplay.csv" \
		--max-frames "$(RELOCATION_MAX_FRAMES)" \
		--heartbeat-interval "$(RELOCATION_HEARTBEAT_INTERVAL)" \
		--trace-dir "$(RELOCATION_RUNTIME_DIR)"
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(RELOCATION_SCORING_TRACE)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/check_scoring_trace_setup.py" \
		--fceux "$(FCEUX_EXE)" \
		--labels "$(RELOCATION_LABELS)" \
		--lua "$(SCORING_TRACE_LUA)"
	set "PACMAN_SCORING_TRACE=$(RELOCATION_SCORING_TRACE)" && set "PACMAN_SCORING_MAX_FRAMES=$(SCORING_MAX_FRAMES)" && "$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-lua "$(subst /,\,$(SCORING_TRACE_LUA))" \
		-max-frames "$(SCORING_MAX_FRAMES)" \
		-turbo 1 \
		-nothrottle 1 \
		"$(RELOCATION_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/check_scoring_trace_setup.py" \
		--fceux "$(FCEUX_EXE)" \
		--labels "$(RELOCATION_LABELS)" \
		--lua "$(SCORING_TRACE_LUA)" \
		--trace "$(RELOCATION_SCORING_TRACE)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_scoring_trace.py" \
		--scenarios "$(SCORING_SCENARIOS)" \
		--trace "$(RELOCATION_SCORING_TRACE)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/relocation_test.py" rehash-manifest \
		--base "$(RECONSTRUCTION_EVIDENCE_SCENARIOS)" \
		--candidate-rom "$(RELOCATION_ROM)" \
		--output "$(RELOCATION_EVIDENCE_SCENARIOS)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/run_reconstruction_evidence.py" \
		--fceux "$(FCEUX_EXE)" \
		--rom "$(RELOCATION_ROM)" \
		--movie "$(LONGPLAY_MOVIE_FILE)" \
		--lua "$(RECONSTRUCTION_EVIDENCE_LUA)" \
		--scenarios "$(RELOCATION_EVIDENCE_SCENARIOS)" \
		--output-dir "$(RELOCATION_EVIDENCE_DIR)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_reconstruction_evidence.py" \
		--scenarios "$(RELOCATION_EVIDENCE_SCENARIOS)" \
		--trace-dir "$(RELOCATION_EVIDENCE_DIR)" \
		--rom "$(RELOCATION_ROM)" \
		--labels "$(RELOCATION_LABELS)"
