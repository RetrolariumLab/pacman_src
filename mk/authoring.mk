# Fixed-layout and expanded authoring variants.

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
HACK_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_hack_variant.lua
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
EXPANDED_MAZE_JSON ?= $(PROJECT_DIR)content/workspace/maze.json
EXPANDED_MAZE_BIN ?= $(EXPANDED_DIR)/assets/maze.rle
EXPANDED_STAGE_JSON ?= $(PROJECT_DIR)content/workspace/stage_parameters.json
EXPANDED_STAGE_BIN ?= $(EXPANDED_DIR)/assets/stage_parameters.bin
EXPANDED_SOUND_JSON ?= $(PROJECT_DIR)content/workspace/sound_streams.json
EXPANDED_SOUND_BIN ?= $(EXPANDED_DIR)/assets/sound_streams.bin
EXPANDED_SOUND_POINTERS_BIN ?= $(EXPANDED_DIR)/assets/sound_pointers.bin
EXPANDED_ACTOR_JSON ?= $(PROJECT_DIR)content/workspace/actor_sprites.json
EXPANDED_ACTOR_BIN ?= $(EXPANDED_DIR)/assets/actor_sprites.bin
EXPANDED_PALETTE_JSON ?= $(PROJECT_DIR)content/workspace/palettes.json
EXPANDED_PALETTE_BIN ?= $(EXPANDED_DIR)/assets/palettes.bin
EXPANDED_SCREEN_JSON ?= $(PROJECT_DIR)content/workspace/screens.json
EXPANDED_SCREEN_BIN ?= $(EXPANDED_DIR)/assets/screens.bin
EXPANDED_RUNTIME_LUA ?= $(PROJECT_DIR)scripts/workflow/validate_expanded_rom.lua
EXPANDED_RUNTIME_RESULT ?= $(BUILD_DIR)/runtime/expanded_rom.txt

EDITED_CHR ?= $(PROJECT_DIR)content/workspace/pacman.chr
SOUND_SLOT ?= 4
SOUND_PREVIEW ?= $(BUILD_DIR)/previews/sound_preview.wav
MIDI_FILE ?=
MIDI_TRACK ?= 0
MIDI_CHANNEL ?= 0
MIDI_OUTPUT ?= $(PROJECT_DIR)content/workspace/sound_streams.midi.json

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
		--output-rom "$(HACK_ROM)" \
		--toolchain-manifest "$(TOOLCHAIN_MANIFEST)"

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

validate-hack: build-dev symbols-hack _canonical-movie
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(HACK_RUNTIME_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_HACK_RUNTIME_RESULT=$(HACK_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-playmovie "$(CANONICAL_LONGPLAY_MOVIE)" \
		-lua "$(subst /,\,$(HACK_RUNTIME_LUA))" \
		-max-frames "10000" \
		-turbo 1 \
		-nothrottle 1 \
		"$(HACK_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_hack_runtime.py" \
		--result "$(HACK_RUNTIME_RESULT)" \
		--expected-stage 5

run-hack: build-hack build-dev
	"$(FCEUX_EXE)" "$(HACK_ROM)"

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
		--palette-json "$(EXPANDED_PALETTE_JSON)" \
		--screen-json "$(EXPANDED_SCREEN_JSON)" \
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
		--actor-output "$(EXPANDED_ACTOR_BIN)" \
		--palette-json "$(EXPANDED_PALETTE_JSON)" \
		--palette-output "$(EXPANDED_PALETTE_BIN)" \
		--screen-json "$(EXPANDED_SCREEN_JSON)" \
		--screen-output "$(EXPANDED_SCREEN_BIN)"

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
		--output-rom "$(EXPANDED_ROM)" \
		--toolchain-manifest "$(TOOLCHAIN_MANIFEST)"

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
		--palettes "$(EXPANDED_PALETTE_BIN)" \
		--screens "$(EXPANDED_SCREEN_BIN)" \
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

validate-expanded: build-dev symbols-expanded _canonical-movie
	@$(PYTHON) -c "import pathlib; r=pathlib.Path(r'$(EXPANDED_RUNTIME_RESULT)'); r.parent.mkdir(parents=True, exist_ok=True); r.unlink() if r.exists() else None"
	set "PACMAN_EXPANDED_RUNTIME_RESULT=$(EXPANDED_RUNTIME_RESULT)" && "$(FCEUX_EXE)" \
		-playmovie "$(CANONICAL_LONGPLAY_MOVIE)" \
		-lua "$(subst /,\,$(EXPANDED_RUNTIME_LUA))" \
		-max-frames "10000" \
		-turbo 1 \
		-nothrottle 1 \
		"$(EXPANDED_ROM)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/validate_expanded_runtime.py" \
		--result "$(EXPANDED_RUNTIME_RESULT)" \
		--stage-json "$(EXPANDED_STAGE_JSON)" \
		--sound-json "$(EXPANDED_SOUND_JSON)" \
		--palette-json "$(EXPANDED_PALETTE_JSON)" \
		--screen-json "$(EXPANDED_SCREEN_JSON)"

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
		--palettes "$(EXPANDED_PALETTE_JSON)" \
		--rom "$(ORIGINAL_ROM)" \
		--project "$(PROJECT_DIR)"

screen-studio:
	$(PYTHON) "$(PROJECT_DIR)scripts/screen_studio.py" \
		--rom "$(ORIGINAL_ROM)" \
		--chr "$(GENERATED_CHR)" \
		--screens "$(EXPANDED_SCREEN_JSON)" \
		--palettes "$(EXPANDED_PALETTE_JSON)" \
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
