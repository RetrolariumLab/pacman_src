PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
CHR_OUT ?= $(PROJECT_DIR)pacman.chr

.PHONY: all build split clean

all: build

build:
	$(PYTHON) "$(PROJECT_DIR)scripts/build.py"

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/split_chr.py" "$(ORIGINAL_ROM)" "$(CHR_OUT)"

clean:
	cmd /c del /f /q "$(PROJECT_DIR)pacman_c.nes" "$(PROJECT_DIR)pacman_c_tmp.nes" 2>nul || exit 0
	cmd /c del /f /q "$(PROJECT_DIR)*.o" "$(PROJECT_DIR)*.s.*.o" 2>nul || exit 0

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
