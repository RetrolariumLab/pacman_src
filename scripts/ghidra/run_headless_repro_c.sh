#!/usr/bin/env bash
set -euo pipefail

# Export decompiled C from existing Ghidra project/program used for repro layout.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -n "${GHIDRA_HOME:-}" ]]; then
  ANALYZE="${GHIDRA_HOME}/support/analyzeHeadless"
else
  ANALYZE="$(command -v analyzeHeadless || true)"
fi

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/tmp}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp}"

PROJECT_DIR="${1:-/tmp}"
PROJECT_NAME="${2:-ghidra_pacman_original}"
PROGRAM_NAME="${3:-Pac-Man (J) (V1.0) [!].nes}"
OUT_C_PATH="${4:-$REPO_DIR/pacman_repro_layout_decomp.c}"
LISTING_PATH="${5:-$REPO_DIR/bank_FF.asm}"

if [[ ! -x "$ANALYZE" ]]; then
  echo "ERROR: analyzeHeadless not found. Set GHIDRA_HOME or add analyzeHeadless to PATH." >&2
  exit 1
fi

"$ANALYZE" "$PROJECT_DIR" "$PROJECT_NAME" \
  -process "$PROGRAM_NAME" \
  -scriptPath "$SCRIPT_DIR" \
  -postScript ApplyBankCodeDataMap.java "$LISTING_PATH" \
  -postScript ImportBankFfListing.java "$LISTING_PATH" \
  -postScript ExportDecompC.java "$OUT_C_PATH" "$LISTING_PATH"

echo "Done. Repro-layout C decomp: $OUT_C_PATH"
