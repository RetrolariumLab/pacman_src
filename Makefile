# Pac-Man (Famicom): build the source back into the original ROMs and check it.
# `make help` lists the targets. The ROMs are yours: copy them next to this
# file under the names config/revisions.json gives, then run `make split` once.

PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# The kit command; the build asks it for its assemblers.
RLTOOL ?= rltool
export RLTOOL
# MAME for `make test-full` and `make golden`.
MAME ?= $(RETROLARIUM_MAME)

ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
BUILD_DIR ?= $(PROJECT_DIR)build
NATIVE_SOURCE ?= $(PROJECT_DIR)src/main.asm
NATIVE_CFG ?= $(PROJECT_DIR)config/linker/nrom128_prg_only.cfg
TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/toolchain.json
ASSET_MANIFEST ?= $(PROJECT_DIR)assets/manifest.json
GENERATED_ASSET_DIR ?= $(PROJECT_DIR)assets/generated
GENERATED_CHR ?= $(GENERATED_ASSET_DIR)/chr/pacman.chr
REVISION_MANIFEST ?= $(PROJECT_DIR)config/revisions.json
REVISION ?= $(shell $(PYTHON) "$(PROJECT_DIR)scripts/build/revision_profiles.py" --manifest "$(REVISION_MANIFEST)" --print-default)
REVISION_REQUIRE_ALL ?=
LONGPLAY_CHECK ?= $(PROJECT_DIR)movies/pacman_j_longplay.check.json
RELOCATED_DIR ?= $(BUILD_DIR)/relocated

# One build of a main source: $(call native,<source>,<output folder>,<flags>)
native = $(PYTHON) "$(PROJECT_DIR)scripts/build/build_native.py" \
		--source "$(1)" --include-dir "$(PROJECT_DIR)src" --config "$(NATIVE_CFG)" \
		--original-rom "$(ORIGINAL_ROM)" --chr "$(GENERATED_CHR)" \
		--object "$(2)/pacman.o" --prg "$(2)/pacman.prg" --labels "$(2)/pacman.lbl" \
		--map "$(2)/pacman.map" --debug-info "$(2)/pacman.dbg" \
		--output-rom "$(2)/pacman.nes" --toolchain-manifest "$(TOOLCHAIN_MANIFEST)" $(3)

.PHONY: all build verify build-revision verify-revision verify-revisions split \
	build-relocated studio-check test test-full golden lint format hooks clean help \
	_require-assets
.DEFAULT_GOAL := build

all: verify

build: _require-assets
	$(call native,$(NATIVE_SOURCE),$(BUILD_DIR))

verify: _require-assets
	$(call native,$(NATIVE_SOURCE),$(BUILD_DIR),--verify)

build-revision: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/build_revision.py" \
		--manifest "$(REVISION_MANIFEST)" --profile "$(REVISION)" \
		--reference-dir "$(PROJECT_DIR)" --project-dir "$(PROJECT_DIR)" \
		--toolchain-manifest "$(TOOLCHAIN_MANIFEST)"

verify-revision: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/build_revision.py" \
		--manifest "$(REVISION_MANIFEST)" --profile "$(REVISION)" \
		--reference-dir "$(PROJECT_DIR)" --project-dir "$(PROJECT_DIR)" \
		--toolchain-manifest "$(TOOLCHAIN_MANIFEST)" --verify

# Every revision whose ROM is here (REVISION_REQUIRE_ALL=--require-all: all).
verify-revisions:
	$(PYTHON) "$(PROJECT_DIR)scripts/build/verify_revisions.py" \
		--manifest "$(REVISION_MANIFEST)" --reference-dir "$(PROJECT_DIR)" \
		--project-dir "$(PROJECT_DIR)" --make "$(MAKE)" $(REVISION_REQUIRE_ALL)

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/build/split_assets.py" \
		--rom "$(ORIGINAL_ROM)" --manifest "$(ASSET_MANIFEST)" \
		--output-dir "$(GENERATED_ASSET_DIR)"

_require-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/build/check_assets.py" \
		--manifest "$(ASSET_MANIFEST)" --asset-dir "$(GENERATED_ASSET_DIR)"

# Every module moved one byte further than the one before (scripts/build/relocate.py).
build-relocated: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/relocate.py" \
		--main "$(NATIVE_SOURCE)" --output "$(RELOCATED_DIR)/source/main.asm"
	$(call native,$(RELOCATED_DIR)/source/main.asm,$(RELOCATED_DIR))

# Open every revision of pacman.rlj in a throwaway copy of the repository the
# way Retrolarium Studio does, and rebuild each without edits, byte for byte.
studio-check: _require-assets
	$(RLTOOL) studio check "$(PROJECT_DIR)pacman.rlj"

# The quick suite (about half a minute): the unit tests, every build byte for
# byte against the ROMs that are here, the relocated build and the studio check.
test: _require-assets
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -p "test_*.py"
	$(MAKE) --no-print-directory verify verify-revisions build-relocated studio-check

# The full suite: the quick one, then the longplay in MAME on the relocated
# build, compared with what the original ROM gives
# (movies/pacman_j_longplay.check.json, written by `make golden`).
test-full: test
	$(RLTOOL) movie check "$(LONGPLAY_CHECK)" --rom "$(RELOCATED_DIR)/pacman.nes" --mame "$(MAME)"

# What the original ROM gives at the longplay's checkpoints.
golden:
	$(RLTOOL) movie golden "$(LONGPLAY_CHECK)" --rom "$(ORIGINAL_ROM)" --mame "$(MAME)"

lint:
	$(RLTOOL) lint --only assembly --only text --project "$(PROJECT_DIR)."

format:
	$(RLTOOL) lint --project "$(PROJECT_DIR)." --fix

# `make hooks`, once per clone, makes Git check every commit and push for stop
# words and run `make lint` first (Retrolarium Kit's rltool hooks; the
# stop-word list lives outside the repositories).
hooks:
	$(RLTOOL) hooks install --project "$(PROJECT_DIR)."

clean:
	$(PYTHON) "$(PROJECT_DIR)scripts/build/clean_artifacts.py"

help:
	@echo "Pac-Man source reconstruction"
	@echo "  make split             unpack the assets from your v1.0 ROM (once)"
	@echo "  make build / verify    build the v1.0 ROM / and compare it byte for byte"
	@echo "  make build-revision REVISION=<id> / verify-revision / verify-revisions"
	@echo "                         the other revisions of config/revisions.json"
	@echo "  make build-relocated   every module moved by a few bytes"
	@echo "  make studio-check      open and rebuild every pacman.rlj revision"
	@echo "  make test              unit tests and every build (about half a minute)"
	@echo "  make test-full         test, then the longplay in MAME (MAME=<path>)"
	@echo "  make golden            record the longplay's checkpoints from the original"
	@echo "  make lint / format     the house style (Retrolarium Kit)"
	@echo "  make hooks             install the Git hooks (stop words, lint before commits)"
	@echo "  make clean             remove build/"

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
