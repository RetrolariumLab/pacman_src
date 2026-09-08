# Static, debugger, codec, and release validation gates.

DEBUG_SUMMARY ?= $(BUILD_DIR)/debug_symbols.json
FCEUX_SYMBOL_DIR ?= $(BUILD_DIR)
DEBUG_BREAKPOINTS ?= $(PROJECT_DIR)config/debugger_breakpoints.json
DEBUG_WATCHES ?= $(PROJECT_DIR)config/debugger_watches.json
DEBUG_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_debug_symbols.lua
DEBUG_RUNTIME_RESULT ?= $(BUILD_DIR)/runtime/debug_symbols.txt
DATA_FORMAT_CONFIG ?= $(PROJECT_DIR)config/data_formats.json
DATA_FORMAT_OUTPUT_DIR ?= $(BUILD_DIR)/roundtrip/data_formats

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
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -p "test_debug_symbols.py" -v

test-runtime-traces:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -p "test_runtime_traces.py" -v

test:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -p "test_*.py" -v

validate-symbols: build-dev symbols
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(DEBUG_RUNTIME_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_DEBUG_SYMBOL_RESULT=$(DEBUG_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-lua "$(subst /,\,$(DEBUG_RUNTIME_LUA))" \
		-max-frames "120" \
		-turbo 1 \
		-nothrottle 1 \
		"$(NATIVE_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_debug_runtime.py" \
		--result "$(DEBUG_RUNTIME_RESULT)"

format:
	$(PYTHON) "$(PROJECT_DIR)scripts/asm_style.py" --fix "$(PROJECT_DIR)src"
	$(MAKE) lint

lint:
	$(PYTHON) "$(PROJECT_DIR)scripts/asm_style.py" "$(PROJECT_DIR)src"
	$(PYTHON) "$(PROJECT_DIR)scripts/lint_source.py"

roundtrip-formats: verify
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/roundtrip_data_formats.py" \
		--rom "$(NATIVE_ROM)" \
		--asset-dir "$(GENERATED_ASSET_DIR)" \
		--asset-manifest "$(ASSET_MANIFEST)" \
		--config "$(DATA_FORMAT_CONFIG)" \
		--output-dir "$(DATA_FORMAT_OUTPUT_DIR)"

# Stable reconstruction gate. Recursive calls keep emulator capture and
# validation ordered even when the parent make is invoked with parallel jobs.
reconstruction-audit:
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) roundtrip-formats
	$(MAKE) validate-symbols
	$(MAKE) trace-runtime
	$(MAKE) trace-scoring
	$(MAKE) validate-scoring-trace

reconstruction-audit-2: reconstruction-audit
	$(MAKE) verify-revisions REVISION_REQUIRE_ALL=--require-all
	$(MAKE) smoke-revisions REVISION_REQUIRE_ALL=--require-all

source-2-1-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/source_2_1_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_MANIFEST)"

source-2-1-release-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/source_2_1_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_MANIFEST)" \
		--require-ready

source-2-1-post-tag-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/source_2_1_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_MANIFEST)" \
		--require-ready \
		--verify-tag

source-2-1-check:
	$(MAKE) reconstruction-audit-2
	$(MAKE) validate-hack
	$(MAKE) validate-expanded
	$(MAKE) test-relocation
	$(MAKE) source-2-1-release-audit

# Reusable functional predecessor gate. Unlike the historical pre-tag command,
# this target remains runnable after the Source 2.1 tag has been published.
source-2-1-baseline-check:
	$(MAKE) reconstruction-audit-2
	$(MAKE) validate-hack
	$(MAKE) validate-expanded
	$(MAKE) test-relocation
	$(MAKE) source-2-1-audit

source-2-2-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/source_2_2_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_MANIFEST)"

source-2-2-release-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/source_2_2_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_MANIFEST)" \
		--require-ready

source-2-2-post-tag-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/source_2_2_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_MANIFEST)" \
		--require-ready \
		--verify-tag

source-2-2-check:
	$(MAKE) clean
	$(MAKE) source-2-1-baseline-check
	$(MAKE) source-2-2-release-audit
