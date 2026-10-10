# The stage-5 hack, the expanded NROM-256 variant and the Retrolarium check.

HACK_SOURCE ?= $(PROJECT_DIR)src/variants/stage5.asm
HACK_OBJ ?= $(BUILD_DIR)/hack/pacman.o
HACK_PRG ?= $(BUILD_DIR)/hack/pacman.prg
HACK_ROM ?= $(BUILD_DIR)/hack/pacman.nes
HACK_LABELS ?= $(BUILD_DIR)/hack/pacman.lbl
HACK_MAP ?= $(BUILD_DIR)/hack/pacman.map
HACK_DEBUG ?= $(BUILD_DIR)/hack/pacman.dbg
HACK_DEBUG_SUMMARY ?= $(BUILD_DIR)/hack/debug_symbols.json
HACK_CHR ?= $(GENERATED_CHR)
HACK_MANIFEST ?= $(PROJECT_DIR)config/hack_variants.json
HACK_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/runtime/validate_hack_variant.lua
HACK_RUNTIME_RESULT ?= $(BUILD_DIR)/runtime/hack_variant.txt

EXPANDED_SOURCE ?= $(PROJECT_DIR)src/expanded/nrom256.asm
EXPANDED_CFG ?= $(PROJECT_DIR)config/linker/nrom256_expanded.cfg
EXPANDED_DIR ?= $(BUILD_DIR)/expanded
EXPANDED_OBJ ?= $(EXPANDED_DIR)/pacman.o
EXPANDED_PRG ?= $(EXPANDED_DIR)/pacman.prg
EXPANDED_ROM ?= $(EXPANDED_DIR)/pacman.nes
EXPANDED_LABELS ?= $(EXPANDED_DIR)/pacman.lbl
EXPANDED_MAP ?= $(EXPANDED_DIR)/pacman.map
EXPANDED_DEBUG ?= $(EXPANDED_DIR)/pacman.dbg
EXPANDED_DEBUG_SUMMARY ?= $(EXPANDED_DIR)/debug_symbols.json
# src/expanded/nrom256.asm includes the assets from here.
EXPANDED_ASSET_DIR ?= $(BUILD_DIR)/expanded/assets
EXPANDED_ASSET_FLAGS ?=
EXPANDED_PROBE_DIR ?= $(BUILD_DIR)/expanded-probe
EXPANDED_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/runtime/validate_expanded_rom.lua
EXPANDED_RUNTIME_RESULT ?= $(BUILD_DIR)/runtime/expanded_rom.txt

RLTOOL ?= rltool

build-hack: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/build_native.py" \
		--source "$(HACK_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(HACK_CHR)" \
		--object "$(HACK_OBJ)" \
		--prg "$(HACK_PRG)" \
		--labels "$(HACK_LABELS)" \
		--map "$(HACK_MAP)" \
		--debug-info "$(HACK_DEBUG)" \
		--output-rom "$(HACK_ROM)" \
		--toolchain-manifest "$(TOOLCHAIN_MANIFEST)"

verify-hack: build-hack
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/verify_hack.py" \
		--original "$(ORIGINAL_ROM)" \
		--candidate "$(HACK_ROM)" \
		--manifest "$(HACK_MANIFEST)" \
		--variant default

symbols-hack: verify-hack
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/debug_symbols.py" \
		--debug "$(HACK_DEBUG)" \
		--map "$(HACK_MAP)" \
		--labels "$(HACK_LABELS)" \
		--rom "$(HACK_ROM)" \
		--fceux-output-dir "$(dir $(HACK_ROM))" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(HACK_DEBUG_SUMMARY)"

validate-hack: build-dev symbols-hack _canonical-movie
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(HACK_RUNTIME_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_HACK_RUNTIME_RESULT=$(HACK_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-playmovie "$(CANONICAL_LONGPLAY_MOVIE)" \
		-lua "$(subst /,\,$(HACK_RUNTIME_LUA))" \
		-max-frames "10000" \
		-turbo 1 \
		-nothrottle 1 \
		"$(HACK_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/runtime/validate_hack_runtime.py" \
		--result "$(HACK_RUNTIME_RESULT)" \
		--expected-stage 5

run-hack: build-hack build-dev
	"$(FCEUX_EXE)" "$(HACK_ROM)"

# The expanded variant's data, as the v1.0 ROM holds it; Retrolarium edits
# the built variant (the japan-v10-nrom256 revision of pacman.rlj).
expanded-assets: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/expanded_assets.py" \
		--original-rom "$(ORIGINAL_ROM)" \
		--maze-source "$(GENERATED_ASSET_DIR)/maze/maze.rle" \
		--asset-manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)" \
		--output-dir "$(EXPANDED_ASSET_DIR)" \
		$(EXPANDED_ASSET_FLAGS)

build-expanded: _require-assets expanded-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/build_expanded.py" \
		--source "$(EXPANDED_SOURCE)" \
		--config "$(EXPANDED_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(EXPANDED_OBJ)" \
		--prg "$(EXPANDED_PRG)" \
		--labels "$(EXPANDED_LABELS)" \
		--map "$(EXPANDED_MAP)" \
		--debug-info "$(EXPANDED_DEBUG)" \
		--output-rom "$(EXPANDED_ROM)" \
		--toolchain-manifest "$(TOOLCHAIN_MANIFEST)"

verify-expanded: build-expanded
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/verify_expanded.py" \
		--original "$(ORIGINAL_ROM)" \
		--candidate "$(EXPANDED_ROM)" \
		--maze-original "$(GENERATED_ASSET_DIR)/maze/maze.rle" \
		--maze-stage2 "$(EXPANDED_ASSET_DIR)/maze.rle" \
		--stage "$(EXPANDED_ASSET_DIR)/stage_parameters.bin" \
		--sound-pointers "$(EXPANDED_ASSET_DIR)/sound_pointers.bin" \
		--sound-streams "$(EXPANDED_ASSET_DIR)/sound_streams.bin" \
		--actors "$(EXPANDED_ASSET_DIR)/actor_sprites.bin" \
		--palettes "$(EXPANDED_ASSET_DIR)/palettes.bin" \
		--screens "$(EXPANDED_ASSET_DIR)/screens.bin" \
		--expected-chr "$(GENERATED_CHR)" \
		--layout "$(PROJECT_DIR)config/expanded_layout.json"

symbols-expanded: verify-expanded
	$(PYTHON) "$(PROJECT_DIR)scripts/validation/debug_symbols.py" \
		--debug "$(EXPANDED_DEBUG)" \
		--map "$(EXPANDED_MAP)" \
		--labels "$(EXPANDED_LABELS)" \
		--rom "$(EXPANDED_ROM)" \
		--fceux-output-dir "$(EXPANDED_DIR)" \
		--breakpoints "$(DEBUG_BREAKPOINTS)" \
		--watches "$(DEBUG_WATCHES)" \
		--summary "$(EXPANDED_DEBUG_SUMMARY)"

# The runtime check plays a build with two probed values, so it sees the
# relocated data being read. The probe build and its debugger labels have their
# own directory, and the plain assets are written back afterwards.
validate-expanded: build-dev symbols-expanded _canonical-movie
	$(MAKE) symbols-expanded EXPANDED_DIR="$(EXPANDED_PROBE_DIR)" EXPANDED_ASSET_FLAGS=--probe
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(EXPANDED_RUNTIME_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_EXPANDED_RUNTIME_RESULT=$(EXPANDED_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-playmovie "$(CANONICAL_LONGPLAY_MOVIE)" \
		-lua "$(subst /,\,$(EXPANDED_RUNTIME_LUA))" \
		-max-frames "10000" \
		-turbo 1 \
		-nothrottle 1 \
		"$(EXPANDED_PROBE_DIR)/pacman.nes"
	$(PYTHON) "$(PROJECT_DIR)scripts/runtime/validate_expanded_runtime.py" \
		--result "$(EXPANDED_RUNTIME_RESULT)" \
		--assets "$(EXPANDED_ASSET_DIR)"
	$(MAKE) expanded-assets

run-expanded: build-expanded build-dev
	"$(FCEUX_EXE)" "$(EXPANDED_ROM)"

# Every revision of pacman.rlj opens in the kit and builds back to its ROM,
# in a throwaway copy of the repository.
studio-check: _require-assets
	$(RLTOOL) studio check "$(PROJECT_DIR)pacman.rlj"

# Source Reconstruction 3.0, in development until Retrolarium is tagged: the
# source-2-2-functional-check gate, then studio-check with the manifest's
# Retrolarium section checked against the descriptor and the running kit.
SOURCE_3_MANIFEST ?= config/source_reconstruction_3_0.json

source-3-audit: _require-assets
	$(RLTOOL) studio check "$(PROJECT_DIR)pacman.rlj" --release "$(PROJECT_DIR)$(SOURCE_3_MANIFEST)"

source-3-check:
	$(MAKE) source-2-2-functional-check
	$(MAKE) source-3-audit
