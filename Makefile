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
TILE_ASCII_MAP ?= $(PROJECT_DIR)tile_ascii_map.txt

.PHONY: all build export-ghidra-repro-layout build-ghidra-repro-rom gen-repro-disasm split clean wf-init wf-batch build-fceux reference debug report analyze verify-bank-ff build-bank-ff-ca65 verify-bank-ff-ca65 chunk progress-report stop help-workflow

all: build

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

build-ghidra-repro-rom:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_repro_layout_rom.py" --strict

build:
	$(PYTHON) "$(PROJECT_DIR)scripts/build_disasm_repro.py" --strict

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/split_chr.py" "$(ORIGINAL_ROM)" "$(CHR_OUT)"

# Python rather than `del`/`rm`: the recipe shell is cmd or sh depending on how
# make was invoked, and the two disagree on both path separators and `2>nul`.
clean:
	@$(PYTHON) -c "import glob, pathlib; root=pathlib.Path(r'$(PROJECT_DIR)'); pats=['*.o','*.s.*.o','pacman_disasm_repro.nes','pacman.chr','src/pacman_disasm_repro.asm','pacman_repro_layout_disasm.asm','$(WORKFLOW_DIR)/bank_ff_ca65_generated.*','$(WORKFLOW_DIR)/bank_ff_ca65.nes','$(WORKFLOW_DIR)/bank_ff_verify.nes']; [pathlib.Path(f).unlink() for p in pats for f in glob.glob(str(root/p))]"
	@echo Cleaned build artifacts.

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

debug: verify-bank-ff build-fceux
	@$(PYTHON) -c "import os; os.makedirs('$(DIFFS_DIR)/longplay', exist_ok=True); os.makedirs('$(REPORTS_DIR)', exist_ok=True)"
	@echo Running debug comparison for longplay on ROM rebuilt from bank_FF.asm...
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
		"$(VERIFY_BANK_ROM)"
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
	@echo "  make build                       - Build ROM from generated ca65 disassembly (strict byte-identity)"
	@echo "  make build-fceux                 - Build fceux_automation"
	@echo "  make reference                   - Generate reference (original ROM, longplay)"
	@echo "  make debug                       - Run ROM rebuilt from bank_FF.asm vs reference capture"
	@echo "  make report                      - Generate report from latest longplay run"
	@echo "  make wf-init                     - Build procedure manifest"
	@echo "  make wf-batch COUNT=40           - Prepare RTS batch"
	@echo "  make analyze                     - RTS analyze subroutines from bank_FF.asm"
	@echo "  make chunk CHUNK_START=1 CHUNK_LINES=250 - Extract chunk + rename template"
	@echo "  make verify-bank-ff              - Build ROM from bank_FF.asm and compare with original"
	@echo "  make build-bank-ff-ca65          - Build bank_FF ROM via ca65/ld65"
	@echo "  make verify-bank-ff-ca65         - Build via ca65/ld65 and compare with original"
	@echo "  make progress-report             - Compare an existing capture dir against the reference"
	@echo "  make stop                        - Stop running fceux/python"

# Frame/memory comparison of an already captured run against the reference set.
# RUN_DIR is produced by an fceux_automation capture (see the debug target).
RUN_DIR ?= $(DIFFS_DIR)/longplay
PROGRESS_REPORT_DIR ?= $(REPORTS_DIR)/progress
PROGRESS_LABEL ?= longplay
PROGRESS_FRAME_OFFSET ?= 0
PROGRESS_ASCII_SAMPLE_COUNT ?= 100
PROGRESS_ASCII_SAMPLE_STEP ?= 5

progress-report:
	@$(PYTHON) -c "import pathlib; pathlib.Path(r'$(PROGRESS_REPORT_DIR)').mkdir(parents=True, exist_ok=True)"
	$(PYTHON) "$(PROJECT_DIR)scripts/workflow/compare_progress_capture.py" \
		--run-dir "$(RUN_DIR)" \
		--reference-dir "$(REFERENCE_DIR)/longplay" \
		--output-dir "$(PROGRESS_REPORT_DIR)" \
		--run-frame-offset "$(PROGRESS_FRAME_OFFSET)" \
		--ascii-sample-count "$(PROGRESS_ASCII_SAMPLE_COUNT)" \
		--ascii-sample-step "$(PROGRESS_ASCII_SAMPLE_STEP)" \
		--label "$(PROGRESS_LABEL)"
	@echo "Done: $(PROGRESS_REPORT_DIR)"

# Extract local ROM payloads before tools inspect or assemble the source.
.PHONY: _rom_assets
_rom_assets:
	$(PYTHON) scripts/rom_assets.py ensure
build lint split init build-profile build-revision build-fixed-layout init-content build-content check-content-zero-edit check-studios: _rom_assets
