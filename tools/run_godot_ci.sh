#!/usr/bin/env bash
set -euo pipefail

TIMEOUT_SECONDS="$1"
shift

LOG_FILE="$(mktemp)"

set +e
timeout "${TIMEOUT_SECONDS}s" godot "$@" 2>&1 | tee "$LOG_FILE"
STATUS=${PIPESTATUS[0]}
set -e

if grep -Eq "SCRIPT ERROR|Parse Error|Compile Error|Invalid call|ERROR: Failed to load script" "$LOG_FILE"; then
  echo "Detected Godot script error in output."
  exit 1
fi

exit "$STATUS"
