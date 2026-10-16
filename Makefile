# Pac-Man (Famicom): build the source back into the original ROMs and check it.
# `make help` lists the targets. The ROMs are yours: copy them next to this
# file under the names assets/manifest.json gives, then run `make split` once.

PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# The kit command; the build asks it for its assemblers.
RLTOOL ?= rltool
export RLTOOL
# MAME for `make test-full` and `make golden`.
MAME ?= $(RETROLARIUM_MAME)

# The private assets: assets/manifest.json names the ROMs and what `make split`
# cuts out of them; `rltool assets` (Retrolarium Kit) splits, checks and
# verifies.
ASSETS = $(RLTOOL) assets $(1) --manifest "$(PROJECT_DIR)assets/manifest.json" --root "$(PROJECT_DIR)."
BASE_IMAGE := japan-v10
ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
BUILD_DIR ?= $(PROJECT_DIR)build
NATIVE_SOURCE ?= $(PROJECT_DIR)src/main.asm
NATIVE_CFG ?= $(PROJECT_DIR)config/linker/nrom128_prg_only.cfg
TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/toolchain.json
GENERATED_ASSET_DIR ?= $(PROJECT_DIR)assets/generated
# The official revisions: the image id of assets/manifest.json and the
# PACMAN_REVISION value the source selects it with.
REVISION ?= japan-v10
PACMAN_REVISION_japan-v10 := 0
PACMAN_REVISION_japan-v11 := 1
PACMAN_REVISION_usa-tengen-unlicensed := 2
PACMAN_REVISION_usa-tengen := 3
PACMAN_REVISION_japan-revb := 4
PACMAN_REVISION_usa-namco := 5
PACMAN_REVISION_europe := 6
REVISION_DIR = $(BUILD_DIR)/revisions/$(REVISION)
# The movies test-full plays, in this order: a TAS first, then the longplay.
MOVIE_CHECKS ?= $(PROJECT_DIR)movies/pacman_j_longplay.check.json
RELOCATED_DIR ?= $(BUILD_DIR)/relocated
RELOCATED_ROM ?= $(RELOCATED_DIR)/pacman.nes

# One build of a main source:
# $(call native,<source>,<output folder>,<header>,<chr>,<flags>)
native = $(PYTHON) "$(PROJECT_DIR)scripts/build/build_native.py" \
		--source "$(1)" --include-dir "$(PROJECT_DIR)src" --config "$(NATIVE_CFG)" \
		--header "$(3)" --chr "$(4)" \
		--object "$(2)/pacman.o" --prg "$(2)/pacman.prg" --labels "$(2)/pacman.lbl" \
		--map "$(2)/pacman.map" --debug-info "$(2)/pacman.dbg" \
		--output-rom "$(2)/pacman.nes" --toolchain-manifest "$(TOOLCHAIN_MANIFEST)" $(5)
BASE_HEADER := $(GENERATED_ASSET_DIR)/header/pacman.hdr
BASE_CHR := $(GENERATED_ASSET_DIR)/chr/pacman.chr

.PHONY: all build verify build-revision verify-revision verify-revisions split \
	build-relocated studio-check test test-full golden lint format hooks clean help \
	_require-assets
.DEFAULT_GOAL := build

all: verify

build: _require-assets
	$(call native,$(NATIVE_SOURCE),$(BUILD_DIR),$(BASE_HEADER),$(BASE_CHR))

verify: build
	$(call ASSETS,verify) --image $(BASE_IMAGE) --built "$(BUILD_DIR)/pacman.nes"

# One official revision (REVISION=<image id>), from its own header and CHR.
build-revision:
	$(call ASSETS,check) --image $(REVISION)
	$(call native,$(NATIVE_SOURCE),$(REVISION_DIR),$(GENERATED_ASSET_DIR)/revisions/$(REVISION)/header.bin,$(GENERATED_ASSET_DIR)/revisions/$(REVISION)/chr.bin,--define PACMAN_REVISION=$(PACMAN_REVISION_$(REVISION)))

verify-revision: build-revision
	$(call ASSETS,verify) --image $(REVISION) --built "$(REVISION_DIR)/pacman.nes"

# Every revision whose ROM is here.
verify-revisions:
	$(foreach revision,$(shell $(call ASSETS,images) --present),$(MAKE) --no-print-directory verify-revision REVISION=$(revision)$(rom_revision_newline))

split:
	$(call ASSETS,split)

_require-assets:
	$(call ASSETS,check) --image $(BASE_IMAGE)

# Every module moved one byte further than the one before (scripts/build/relocate.py).
build-relocated: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/build/relocate.py" \
		--main "$(NATIVE_SOURCE)" --output "$(RELOCATED_DIR)/source/main.asm"
	$(call native,$(RELOCATED_DIR)/source/main.asm,$(RELOCATED_DIR),$(BASE_HEADER),$(BASE_CHR))

# Open every revision of pacman.rlj in a throwaway copy of the repository the
# way Retrolarium Studio does, and rebuild each without edits, byte for byte.
studio-check: _require-assets
	$(RLTOOL) studio check "$(PROJECT_DIR)pacman.rlj"

# The quick suite (about half a minute): the unit tests, every build byte for
# byte against the ROMs that are here, the relocated build and the studio check.
test: _require-assets
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -p "test_*.py"
	$(MAKE) --no-print-directory verify verify-revisions build-relocated studio-check

# The full suite: the quick one, then the movies in MAME on the relocated
# build in turn (the first that differs stops it), compared with what the
# original ROM gives (movies/*.check.json, written by `make golden`).
test-full: test
	$(RLTOOL) movie check $(MOVIE_CHECKS) --rom "$(RELOCATED_ROM)" --mame "$(MAME)"

# What the original ROM gives at the movies' checkpoints.
golden:
	$(RLTOOL) movie golden $(MOVIE_CHECKS) --rom "$(ORIGINAL_ROM)" --mame "$(MAME)"

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
	@echo "  make split             cut the assets out of the ROMs that are here (once)"
	@echo "  make build / verify    build the v1.0 ROM / and compare it byte for byte"
	@echo "  make build-revision REVISION=<id> / verify-revision / verify-revisions"
	@echo "                         the official revisions (image ids of assets/manifest.json)"
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

define rom_revision_newline


endef
