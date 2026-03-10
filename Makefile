PYTHON ?= python
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ORIGINAL_ROM ?= $(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes
CHR_OUT ?= $(PROJECT_DIR)pacman.chr

# FCEUX automation (Windows VC build)
FCEUX_DIR ?= ../fceux_automation
FCEUX_REPO ?= https://github.com/oranguthang/fceux_automation.git
FCEUX_SOLUTION ?= $(FCEUX_DIR)/vc/vc14_fceux.sln
FCEUX_CONFIG ?= Release
FCEUX_PLATFORM ?= x64
FCEUX_TOOLSET ?= v143
FCEUX_EXE ?= $(FCEUX_DIR)/vc/$(FCEUX_PLATFORM)/$(FCEUX_CONFIG)/fceux64.exe
MSBUILD ?= C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe

WORKFLOW_DIR ?= workflow
REFERENCE_DIR ?= reference
DIFFS_DIR ?= diffs
REPORTS_DIR ?= reports
LONGPLAY_MOVIE_FILE ?= movies/pacman_j_longplay.fm2
MAX_FRAMES_LONGPLAY ?= 120000
ANALYSIS_INTERVAL ?= 20
CAPTURE_START_FRAME ?= 0
ANALYSIS_MAX_DIFFS ?= 20
ANALYSIS_WORKERS ?= 24
ANALYSIS_GRID_COLS ?= 6
ANALYSIS_WINDOW_W ?= 320
ANALYSIS_WINDOW_H ?= 260
PROCEDURES_FILE ?= $(WORKFLOW_DIR)/unanalyzed_procedures.txt
ANALYSIS_REPORT_CSV ?= $(WORKFLOW_DIR)/analysis_report_longplay.csv
EMU_SPEED_FLAGS ?= -turbo 1 -nothrottle 1
EMU_WINDOW_FLAGS ?= -pixel-perfect-window
VERIFY_BANK_ROM ?= $(WORKFLOW_DIR)/bank_ff_verify.nes
CHUNK_START ?= 1
CHUNK_LINES ?= 250
CHUNK_SNIPPET ?= $(WORKFLOW_DIR)/chunk_$(CHUNK_START)_$(CHUNK_LINES).asm
CHUNK_RENAME_CSV ?= $(WORKFLOW_DIR)/rename_chunk.csv

.PHONY: all build export-ghidra-repro-layout export-ghidra-repro-c build-ghidra-repro-c-cc65 build-ghidra-repro-c-cc65-min build-ghidra-repro-c-cc65-rom check-ghidra-decomp-coverage analyze-ghidra-decomp-gaps build-ghidra-repro-rom gen-repro-disasm build-disasm split clean wf-init wf-batch build-fceux reference debug report analyze verify-bank-ff build-bank-ff-ca65 verify-bank-ff-ca65 chunk stop help-workflow build-c0 run-c0 clean-c0 test-c0

all: build

build:
	$(PYTHON) "$(PROJECT_DIR)scripts/build.py"

gen-repro-disasm:
	$(PYTHON) "$(PROJECT_DIR)scripts/generate_repro_disasm.py" \
		--listing "$(PROJECT_DIR)bank_FF.asm" \
		--rom "$(PROJECT_DIR)Pac-Man (J) (V1.0) [!].nes" \
		--output "$(PROJECT_DIR)src/pacman_disasm_repro.asm"

export-ghidra-repro-layout:
	"$(PROJECT_DIR)scripts/ghidra/run_headless_repro_layout.sh" \
		/tmp ghidra_pacman_original "Pac-Man (J) (V1.0) [!].nes" \
		"$(PROJECT_DIR)pacman_repro_layout_disasm.asm" \
		"$(PROJECT_DIR)bank_FF.asm"

export-ghidra-repro-c:
	"$(PROJECT_DIR)scripts/ghidra/run_headless_repro_c.sh" \
		/tmp ghidra_pacman_original "Pac-Man (J) (V1.0) [!].nes" \
		"$(PROJECT_DIR)pacman_repro_layout_decomp.c" \
		"$(PROJECT_DIR)bank_FF.asm"

build-ghidra-repro-c-cc65:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_repro_c_cc65.py"

build-ghidra-repro-c-cc65-min:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_repro_c_cc65.py" \
		--drop-data \
		--output "$(PROJECT_DIR)pacman_repro_layout_decomp_cc65_min.c" \
		--obj "$(PROJECT_DIR)pacman_repro_layout_decomp_cc65_min.o"

build-ghidra-repro-c-cc65-rom: build-ghidra-repro-c-cc65-min
	$(PYTHON) "$(PROJECT_DIR)scripts/build_repro_c_cc65_rom.py"

check-ghidra-decomp-coverage:
	"$(PROJECT_DIR)scripts/ghidra/run_headless_check_decomp_coverage.sh" \
		/tmp ghidra_pacman_original "Pac-Man (J) (V1.0) [!].nes" \
		"$(PROJECT_DIR)bank_FF.asm" \
		"$(PROJECT_DIR)decomp_coverage_report.txt" \
		0

analyze-ghidra-decomp-gaps:
	"$(PROJECT_DIR)scripts/ghidra/run_headless_analyze_decomp_gaps.sh" \
		/tmp ghidra_pacman_original "Pac-Man (J) (V1.0) [!].nes" \
		"$(PROJECT_DIR)decomp_coverage_report.txt" \
		"$(PROJECT_DIR)decomp_coverage_diagnostics.txt"

build-ghidra-repro-rom:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_repro_layout_rom.py" --strict

build-disasm:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_disasm_repro.py" --strict

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/split_chr.py" "$(ORIGINAL_ROM)" "$(CHR_OUT)"

clean:
	cmd /c del /f /q "$(PROJECT_DIR)pacman_c.nes" "$(PROJECT_DIR)pacman_c_tmp.nes" 2>nul || exit 0
	cmd /c del /f /q "$(PROJECT_DIR)*.o" "$(PROJECT_DIR)*.s.*.o" 2>nul || exit 0

wf-init:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/build_procedure_manifest.py" \
		--listing "$(PROJECT_DIR)bank_FF.asm" \
		--output "$(PROJECT_DIR)workflow/procedure_manifest.csv"

COUNT ?= 32
wf-batch:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/prepare_rts_batch.py" \
		--manifest "$(PROJECT_DIR)workflow/procedure_manifest.csv" \
		--count "$(COUNT)" \
		--output "$(PROJECT_DIR)workflow/rts_batch.txt"

build-fceux:
	@$(PYTHON) -c "import os, subprocess; os.path.isdir(r'$(FCEUX_DIR)') or (print('Cloning fceux_automation...'), subprocess.run(['git', 'clone', '$(FCEUX_REPO)', r'$(FCEUX_DIR)'], check=True))"
	@echo Building fceux_automation...
	"$(MSBUILD)" "$(FCEUX_SOLUTION)" /m /p:Configuration=$(FCEUX_CONFIG) /p:Platform=$(FCEUX_PLATFORM) /p:PlatformToolset=$(FCEUX_TOOLSET)
	@if not exist "$(FCEUX_EXE)" ( \
		echo ERROR: Build finished but executable not found: "$(FCEUX_EXE)" & \
		echo Contents of "$(FCEUX_DIR)/vc/$(FCEUX_PLATFORM)/$(FCEUX_CONFIG)": & \
		dir /b "$(FCEUX_DIR)\\vc\\$(FCEUX_PLATFORM)\\$(FCEUX_CONFIG)" & \
		exit /b 1 \
	)
	@echo Build complete: $(FCEUX_EXE)

reference: build-fceux
	@$(PYTHON) -c "import os; os.makedirs('$(REFERENCE_DIR)/longplay', exist_ok=True)"
	@echo Generating reference from original ROM (longplay)...
	"$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-screenshot-interval $(ANALYSIS_INTERVAL) \
		-screenshot-start-frame $(CAPTURE_START_FRAME) \
		-screenshot-dir "$(REFERENCE_DIR)/longplay" \
		-max-frames $(MAX_FRAMES_LONGPLAY) \
		-save-state-dumps \
		-save-tile-ascii \
		-tile-ascii-map "$(TILE_ASCII_MAP)" \
		$(EMU_SPEED_FLAGS) \
		$(EMU_WINDOW_FLAGS) \
		"$(ORIGINAL_ROM)"
	@echo Reference saved to $(REFERENCE_DIR)/longplay

debug: build build-fceux
	@$(PYTHON) -c "import os; os.makedirs('$(DIFFS_DIR)/longplay', exist_ok=True); os.makedirs('$(REPORTS_DIR)', exist_ok=True)"
	@echo Running debug comparison for longplay on built ROM...
	"$(FCEUX_EXE)" \
		-playmovie "$(LONGPLAY_MOVIE_FILE)" \
		-screenshot-interval $(ANALYSIS_INTERVAL) \
		-screenshot-start-frame $(CAPTURE_START_FRAME) \
		-screenshot-dir "$(DIFFS_DIR)/longplay" \
		-reference-dir "$(REFERENCE_DIR)/longplay" \
		-max-frames $(MAX_FRAMES_LONGPLAY) \
		-save-state-dumps \
		-save-tile-ascii \
		-tile-ascii-map "$(TILE_ASCII_MAP)" \
		$(EMU_SPEED_FLAGS) \
		$(EMU_WINDOW_FLAGS) \
		"$(PROJECT_DIR)pacman_c.nes"
	@$(PYTHON) "$(PROJECT_DIR)scripts/workflow/generate_capture_report.py" \
		--run-dir "$(DIFFS_DIR)/longplay" \
		--reference-dir "$(REFERENCE_DIR)/longplay" \
		--output-dir "$(REPORTS_DIR)" \
		--movie "longplay"
	@echo Debug artifacts: $(DIFFS_DIR)/longplay

report:
	@$(PYTHON) "$(PROJECT_DIR)scripts/workflow/generate_capture_report.py" \
		--run-dir "$(DIFFS_DIR)/longplay" \
		--reference-dir "$(REFERENCE_DIR)/longplay" \
		--output-dir "$(REPORTS_DIR)" \
		--movie "longplay"

analyze: wf-init wf-batch build-fceux
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/analyze_subroutines.py" \
		--listing "$(PROJECT_DIR)bank_FF.asm" \
		--manifest "$(PROJECT_DIR)workflow/procedure_manifest.csv" \
		--batch "$(PROJECT_DIR)workflow/rts_batch.txt" \
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
	@echo "Analyze complete: $(ANALYSIS_REPORT_CSV)"

verify-bank-ff:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/verify_bank_ff_rom.py" \
		--listing "$(PROJECT_DIR)bank_FF.asm" \
		--original-rom "$(ORIGINAL_ROM)" \
		--output-rom "$(VERIFY_BANK_ROM)"

build-bank-ff-ca65:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/build_bank_ff_ca65.py" \
		--listing "$(PROJECT_DIR)bank_FF.asm" \
		--original-rom "$(ORIGINAL_ROM)" \
		--cfg "$(PROJECT_DIR)src/nrom128_prg_only.cfg" \
		--generated-asm "$(WORKFLOW_DIR)/bank_ff_ca65_generated.asm" \
		--obj "$(WORKFLOW_DIR)/bank_ff_ca65_generated.o" \
		--prg "$(WORKFLOW_DIR)/bank_ff_ca65_generated.bin" \
		--output-rom "$(WORKFLOW_DIR)/bank_ff_ca65.nes"

verify-bank-ff-ca65:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/build_bank_ff_ca65.py" \
		--listing "$(PROJECT_DIR)bank_FF.asm" \
		--original-rom "$(ORIGINAL_ROM)" \
		--cfg "$(PROJECT_DIR)src/nrom128_prg_only.cfg" \
		--generated-asm "$(WORKFLOW_DIR)/bank_ff_ca65_generated.asm" \
		--obj "$(WORKFLOW_DIR)/bank_ff_ca65_generated.o" \
		--prg "$(WORKFLOW_DIR)/bank_ff_ca65_generated.bin" \
		--output-rom "$(WORKFLOW_DIR)/bank_ff_ca65.nes" \
		--verify

chunk:
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/extract_rename_chunk.py" \
		--source "$(PROJECT_DIR)bank_FF.asm" \
		--start-line "$(CHUNK_START)" \
		--line-count "$(CHUNK_LINES)" \
		--output-csv "$(CHUNK_RENAME_CSV)" \
		--output-snippet "$(CHUNK_SNIPPET)"
	@echo "Chunk snippet: $(CHUNK_SNIPPET)"
	@echo "Rename template: $(CHUNK_RENAME_CSV)"

stop:
	-taskkill /F /IM fceux64.exe 2>nul
	-taskkill /F /IM fceux.exe 2>nul
	-taskkill /F /IM python.exe 2>nul
	@echo Stopped emulator/analysis processes.

help-workflow:
	@echo "Workflow commands:"
	@echo "  make build-fceux                 - Build fceux_automation"
	@echo "  make reference                   - Generate reference (original ROM, longplay)"
	@echo "  make debug                       - Run built C-ROM vs reference capture"
	@echo "  make report                      - Generate report from latest longplay run"
	@echo "  make wf-init                     - Build procedure manifest"
	@echo "  make wf-batch COUNT=40           - Prepare RTS batch"
	@echo "  make analyze                     - RTS analyze subroutines from bank_FF.asm"
	@echo "  make chunk CHUNK_START=1 CHUNK_LINES=250 - Extract chunk + rename template"
	@echo "  make verify-bank-ff              - Build ROM from bank_FF.asm and compare with original"
	@echo "  make build-bank-ff-ca65          - Build bank_FF ROM via ca65/ld65"
	@echo "  make verify-bank-ff-ca65         - Build via ca65/ld65 and compare with original"
	@echo "  make stop                        - Stop running fceux/python"
	@echo "  make build-c0                    - Build new C baseline (NROM-128)"
	@echo "  make run-c0                      - Run C baseline ROM in fceux"
	@echo "  make test-c0                     - Run C0 ROM vs reference and generate frame+memory report"
	@echo "  make clean-c0                    - Remove C baseline build artifacts"

CC65_BIN ?= $(PROJECT_DIR)cc65-snapshot-win64/bin
CL65 ?= $(CC65_BIN)/cl65
C0_ROM ?= $(PROJECT_DIR)build_c/pacman_c0.nes
C0_CFG ?= $(PROJECT_DIR)src/nrom128_horz.cfg
C0_CHR ?= $(PROJECT_DIR)src/assets/pacman.chr
C0_SRCS := src/main.c src/core/actors.c src/core/game.c src/core/neslib.c src/core/ppu_queue.c src/core/render.c src/core/title.c src/game/maze.c src/game/player.c src/game/ghosts.c src/game/pellets.c src/game/demo.c
C0_ASM :=
C0_TEST_DIR ?= $(PROJECT_DIR)workflow/progress
C0_TEST_REPORT_DIR ?= $(PROJECT_DIR)workflow/progress/report
C0_TEST_REFERENCE_DIR ?= $(PROJECT_DIR)reference/longplay
C0_TEST_MOVIE ?= $(LONGPLAY_MOVIE_FILE)
C0_TEST_INTERVAL ?= 1
C0_TEST_START_FRAME ?= $(CAPTURE_START_FRAME)
C0_TEST_MAX_FRAMES ?= 2000
C0_TEST_MAX_DIFFS ?= 0
C0_TEST_MAX_MEMORY_DIFFS ?= 0
C0_TEST_LABEL ?= c0_longplay
C0_TEST_FRAME_OFFSET ?= 0
C0_TEST_ASCII_SAMPLE_COUNT ?= 100
C0_TEST_ASCII_SAMPLE_STEP ?= 5
C0_TEST_SKIP_BLACK_FRAMES ?= 1
C0_TEST_TILE_ASCII_MAP ?= $(PROJECT_DIR)tile_ascii_map.txt
TILE_ASCII_MAP ?= $(PROJECT_DIR)tile_ascii_map.txt

$(C0_CHR):
	$(PYTHON) "$(PROJECT_DIR)scripts/split_chr.py" "$(ORIGINAL_ROM)" "$(C0_CHR)"

build-c0:
	@$(PYTHON) -c "import os; os.makedirs('$(PROJECT_DIR)build_c', exist_ok=True)"
	"$(CL65)" -t nes -Oisr -I src/include -C "$(C0_CFG)" -o "$(C0_ROM)" $(C0_SRCS) $(C0_ASM)
	@$(PYTHON) -c "from pathlib import Path; rom=Path(r'$(C0_ROM)'); orig=Path(r'$(ORIGINAL_ROM)'); d=bytearray(rom.read_bytes()); o=orig.read_bytes(); d[4]=1; d[5]=1; d[6]=0x00; d[7]=(d[7]&0xF0); chr_o=o[16+16384:16+16384+8192]; d[16+16384:16+16384+8192]=chr_o; rom.write_bytes(d)"
	@echo Built: $(C0_ROM)

run-c0: build-c0 build-fceux
	"$(FCEUX_EXE)" "$(C0_ROM)"

clean-c0:
	cmd /c del /f /q "$(PROJECT_DIR)build_c\\pacman_c0.nes" 2>nul || exit 0

test-c0: build-c0 build-fceux
	@$(PYTHON) -c "import shutil, pathlib; p=pathlib.Path(r'$(C0_TEST_DIR)'); shutil.rmtree(p, ignore_errors=True); p.mkdir(parents=True, exist_ok=True)"
	@$(PYTHON) -c "import pathlib, sys; p=pathlib.Path(r'$(C0_TEST_DIR)'); leftovers=[x.name for x in p.iterdir()]; print('ERROR: progress dir is not empty:', leftovers) if leftovers else None; sys.exit(1 if leftovers else 0)"
	@$(PYTHON) -c "import pathlib; pathlib.Path(r'$(C0_TEST_REPORT_DIR)').mkdir(parents=True, exist_ok=True)"
	@echo Running C0 ROM in compare mode against reference...
	"$(FCEUX_EXE)" \
		-playmovie "$(C0_TEST_MOVIE)" \
		-screenshot-interval $(C0_TEST_INTERVAL) \
		-screenshot-start-frame $(C0_TEST_START_FRAME) \
		-screenshot-dir "$(C0_TEST_DIR)" \
		-reference-dir "$(C0_TEST_REFERENCE_DIR)" \
		-save-state-dumps \
		-max-diffs $(C0_TEST_MAX_DIFFS) \
		-max-memory-diffs $(C0_TEST_MAX_MEMORY_DIFFS) \
		-max-frames $(C0_TEST_MAX_FRAMES) \
		-save-tile-ascii \
		-tile-ascii-map "$(C0_TEST_TILE_ASCII_MAP)" \
		$(if $(filter 1,$(C0_TEST_SKIP_BLACK_FRAMES)),-skip-black-frames,) \
		$(EMU_SPEED_FLAGS) \
		$(EMU_WINDOW_FLAGS) \
		"$(C0_ROM)"
	@echo Building progress report from screenshots and memory dumps...
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/compare_progress_capture.py" \
		--run-dir "$(C0_TEST_DIR)" \
		--reference-dir "$(C0_TEST_REFERENCE_DIR)" \
		--output-dir "$(C0_TEST_REPORT_DIR)" \
		--run-frame-offset "$(C0_TEST_FRAME_OFFSET)" \
		--ascii-sample-count "$(C0_TEST_ASCII_SAMPLE_COUNT)" \
		--ascii-sample-step "$(C0_TEST_ASCII_SAMPLE_STEP)" \
		--label "$(C0_TEST_LABEL)"
	@echo "Done: $(C0_TEST_REPORT_DIR)"

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
