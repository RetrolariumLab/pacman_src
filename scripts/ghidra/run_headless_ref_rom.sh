#!/usr/bin/env bash
set -euo pipefail

# Build and analyze reference NES ROM from bank_FF.asm listing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -n "${GHIDRA_HOME:-}" ]]; then
  ANALYZE="${GHIDRA_HOME}/support/analyzeHeadless"
else
  ANALYZE="$(command -v analyzeHeadless || true)"
fi
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/tmp}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp}"

LISTING_PATH="${1:-$REPO_DIR/bank_FF.asm}"
ROM_PATH="${2:-$REPO_DIR/pacman_bank_ff_ref.nes}"
OUT_C_PATH="${3:-$REPO_DIR/decomp_bank_ff.c}"
PROJECT_DIR="${4:-/tmp}"
PROJECT_NAME="${5:-ghidra_pacman_ff_rom}"
CHR_PATH="${6:-$REPO_DIR/pacman.chr}"

if [[ ! -x "$ANALYZE" ]]; then
  echo "ERROR: analyzeHeadless not found. Set GHIDRA_HOME or add analyzeHeadless to PATH." >&2
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  echo "ERROR: java is not available in PATH" >&2
  exit 2
fi

if [[ -z "${JAVA_HOME:-}" ]]; then
  JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  export JAVA_HOME
fi

ROM_BUILD_ARGS=("$SCRIPT_DIR/build_reference_rom.py" "$LISTING_PATH" -o "$ROM_PATH")
if [[ -f "$CHR_PATH" ]]; then
  ROM_BUILD_ARGS+=(--chr "$CHR_PATH")
fi
python3 "${ROM_BUILD_ARGS[@]}"

"$ANALYZE" "$PROJECT_DIR" "$PROJECT_NAME" \
  -import "$ROM_PATH" \
  -overwrite \
  -processor 6502:LE:16:default \
  -loader BinaryLoader \
  -loader-fileOffset 0x10 \
  -loader-length 0x4000 \
  -loader-baseAddr 0xC000 \
  -scriptPath "$SCRIPT_DIR" \
  -postScript ImportBankFfListing.java "$LISTING_PATH" \
  -postScript ExportDecompC.java "$OUT_C_PATH"

echo "Done. Reference ROM: $ROM_PATH"
echo "Done. Decompiled C: $OUT_C_PATH"
