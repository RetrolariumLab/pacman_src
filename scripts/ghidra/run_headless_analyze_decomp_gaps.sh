#!/usr/bin/env bash
set -euo pipefail

# Analyze missing instruction coverage from decomp_coverage_report.txt
# and group gaps by function/range.

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
IN_REPORT_PATH="${4:-$REPO_DIR/decomp_coverage_report.txt}"
OUT_DIAG_PATH="${5:-$REPO_DIR/decomp_coverage_diagnostics.txt}"

if [[ ! -x "$ANALYZE" ]]; then
  echo "ERROR: analyzeHeadless not found. Set GHIDRA_HOME or add analyzeHeadless to PATH." >&2
  exit 1
fi

"$ANALYZE" "$PROJECT_DIR" "$PROJECT_NAME" \
  -process "$PROGRAM_NAME" \
  -scriptPath "$SCRIPT_DIR" \
  -postScript AnalyzeDecompCoverageGaps.java "$IN_REPORT_PATH" "$OUT_DIAG_PATH"

echo "Done. Coverage diagnostics: $OUT_DIAG_PATH"
