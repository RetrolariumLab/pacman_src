#!/usr/bin/env bash
set -euo pipefail

# End-to-end headless pipeline for Pac-Man bank_FF.

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
OUT_C_PATH="${2:-$REPO_DIR/decomp_bank_ff.c}"
PROJECT_DIR="${3:-/tmp}"
PROJECT_NAME="${4:-ghidra_pacman_ff}"
BIN_PATH="${5:-/tmp/bank_FF.bin}"

if [[ ! -x "$ANALYZE" ]]; then
  echo "ERROR: analyzeHeadless not found. Set GHIDRA_HOME or add analyzeHeadless to PATH." >&2
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  cat >&2 <<'EOF'
ERROR: java is not available in PATH.
Install JDK 21+ (or set JAVA_HOME and PATH), then rerun.
Example (Arch): sudo pacman -S jdk21-openjdk
EOF
  exit 2
fi

if [[ -z "${JAVA_HOME:-}" ]]; then
  JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  export JAVA_HOME
fi

python3 "$SCRIPT_DIR/build_bank_ff_bin.py" "$LISTING_PATH" -o "$BIN_PATH"

"$ANALYZE" "$PROJECT_DIR" "$PROJECT_NAME" \
  -import "$BIN_PATH" \
  -overwrite \
  -processor 6502:LE:16:default \
  -loader BinaryLoader \
  -loader-baseAddr 0xC000 \
  -scriptPath "$SCRIPT_DIR" \
  -postScript ImportBankFfListing.java "$LISTING_PATH" \
  -postScript ExportDecompC.java "$OUT_C_PATH"

echo "Done. Decompiled C: $OUT_C_PATH"
