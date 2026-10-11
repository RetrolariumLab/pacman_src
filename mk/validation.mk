# Static, debugger, codec, and release validation gates.

DEBUG_SUMMARY ?= $(BUILD_DIR)/debug_symbols.json
FCEUX_SYMBOL_DIR ?= $(BUILD_DIR)
DEBUG_BREAKPOINTS ?= $(PROJECT_DIR)config/debugger_breakpoints.json
DEBUG_WATCHES ?= $(PROJECT_DIR)config/debugger_watches.json
DEBUG_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/runtime/validate_debug_symbols.lua
DEBUG_RUNTIME_RESULT ?= $(BUILD_DIR)/runtime/debug_symbols.txt
DATA_FORMAT_CONFIG ?= $(PROJECT_DIR)config/data_formats.json
DATA_FORMAT_OUTPUT_DIR ?= $(BUILD_DIR)/roundtrip/data_formats

symbols: build
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/debug_symbols.py" \
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

help-check:
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/make_help.py" \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(PROJECT_DIR)config/make_help.json" \
		--check

scaffold-check:
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/scaffold_check.py" \
		--project-root "$(PROJECT_DIR)" \
		--python "$(PYTHON)" \
		--make "$(MAKE)"

validate-symbols: build-dev symbols
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(DEBUG_RUNTIME_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_DEBUG_SYMBOL_RESULT=$(DEBUG_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-lua "$(subst /,\,$(DEBUG_RUNTIME_LUA))" \
		-max-frames "120" \
		-turbo 1 \
		-nothrottle 1 \
		"$(NATIVE_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/runtime/validate_debug_runtime.py" \
		--result "$(DEBUG_RUNTIME_RESULT)"

format:
	$(RLTOOL) lint --project "$(PROJECT_DIR)." --fix
	$(MAKE) lint

# House style (config/lint.json) from Retrolarium Kit, then the game's own
# source and documentation checks.
lint:
	$(RLTOOL) lint --project "$(PROJECT_DIR)."
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/lint_source.py"
	$(MAKE) docs-audit

docs-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/documentation_audit.py" \
		--project-root "$(PROJECT_DIR)" \
		--layout "$(PROJECT_DIR)config/documentation_layout.json"

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

# The Source 2.1 manifest describes the tree tagged source-reconstruction-2.1
# (its toolchain contract names the assemblers the repository carried then),
# so its audits run there, by the tag's own script, in a disposable clone.
SOURCE_2_1_TAG ?= source-reconstruction-2.1
SOURCE_2_1_AT_TAG = $(PYTHON) "$(PROJECT_DIR)scripts/validation/tag_audit.py" --tag "$(SOURCE_2_1_TAG)" -- \
	scripts/source_2_1_audit.py --project-root "{root}" --manifest "{root}/config/source_reconstruction_2_1.json"

source-2-1-audit:
	$(SOURCE_2_1_AT_TAG)

source-2-1-release-audit:
	$(SOURCE_2_1_AT_TAG) --require-ready

source-2-1-post-tag-audit:
	$(SOURCE_2_1_AT_TAG) --require-ready --verify-tag

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

# The Source 2.2 manifest describes the tree tagged source-reconstruction-2.2
# (with the editors 3.0 retired), so its audits run there, by the tag's own
# script, in a disposable clone.
SOURCE_2_2_TAG ?= source-reconstruction-2.2
SOURCE_2_2_AT_TAG = $(PYTHON) "$(PROJECT_DIR)scripts/validation/tag_audit.py" --tag "$(SOURCE_2_2_TAG)" -- \
	scripts/validation/source_2_2_audit.py --project-root "{root}" --manifest "{root}/config/source_reconstruction_2_2.json"

source-2-2-audit:
	$(SOURCE_2_2_AT_TAG)

source-2-2-release-audit:
	$(SOURCE_2_2_AT_TAG) --require-ready

source-2-2-post-tag-audit:
	$(SOURCE_2_2_AT_TAG) --require-ready --verify-tag

source-2-2-functional-check:
	$(MAKE) source-2-1-baseline-check
	$(MAKE) format
	$(MAKE) scaffold-check
	$(MAKE) source-2-2-audit

source-2-2-check:
	$(MAKE) clean
	$(MAKE) source-2-2-functional-check
	$(MAKE) clean
	$(MAKE) source-2-2-release-audit
