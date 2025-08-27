#!/usr/bin/env bash
set -euo pipefail

# Simple benchmark script
# Runs hyperfine comparing bash and /usr/local/bin/zash on 100-hello.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$DIR/100-hello.sh"
OUT_FILE="$DIR/benchmark.csv"
OUT_RUNS_FILE="$DIR/benchmark-runs.csv"
OUT_JSON="$DIR/benchmark.json"
SHELL_BASH="$(command -v bash || echo /bin/bash)"
SHELL_ZASH="/usr/local/bin/zash"

if ! command -v hyperfine >/dev/null 2>&1; then
    echo "hyperfine is not installed. Please install hyperfine to run this script." >&2
    exit 1
fi

if [ ! -f "$TARGET" ]; then
    echo "Target script '$TARGET' not found." >&2
    exit 1
fi

echo "Benchmarking:"
echo "  bash: $SHELL_BASH $TARGET"
echo "  zash: $SHELL_ZASH $TARGET"
echo "Output CSV: $OUT_FILE"

# Use --shell=none so hyperfine runs the exact commands
hyperfine --export-csv "$OUT_FILE" --export-json "$OUT_JSON" --show-output --shell=none \
    "$SHELL_BASH $TARGET" "$SHELL_ZASH $TARGET"

echo "Done. CSV saved to: $OUT_FILE"
echo "JSON saved to: $OUT_JSON"

# If jq is present, extract individual run times from the JSON and write a per-run CSV
if command -v jq >/dev/null 2>&1 && [ -f "$OUT_JSON" ]; then
    echo "command,run_index,time_seconds" >"$OUT_RUNS_FILE"
    # JSON structure: { "results": [ { "command": "...", "times": [ ... ] }, ... ] }
    # Produce CSV rows: command,run_index,time_seconds
    if jq -e . >/dev/null 2>&1 <"$OUT_JSON"; then
        jq -r '.results[] | .command as $cmd | .times | to_entries[] | [ $cmd, (.key+1), .value ] | @csv' "$OUT_JSON" | sed 's/^"//;s/"$//;s/","/,/g' >>"$OUT_RUNS_FILE" || true
    fi
    # If file ended up empty, remove it
    if [ ! -s "$OUT_RUNS_FILE" ] || [ "$(wc -c <"$OUT_RUNS_FILE")" -eq 0 ]; then
        rm -f "$OUT_RUNS_FILE"
    fi
    if [ -f "$OUT_RUNS_FILE" ]; then
        echo "Per-run CSV saved to: $OUT_RUNS_FILE"
    fi
else
    echo "jq not found or JSON missing; per-run CSV not generated. To enable, install jq." >&2
fi
