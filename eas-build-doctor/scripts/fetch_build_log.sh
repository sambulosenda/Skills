#!/usr/bin/env bash
set -euo pipefail

# Fetch and extract the tail of an EAS build log.
# Usage: fetch_build_log.sh <BUILD_ID> [TAIL_LINES]

build_id="${1:?Usage: fetch_build_log.sh <BUILD_ID> [TAIL_LINES]}"
tail_lines="${2:-200}"

echo "== Build Info =="
eas build:view "${build_id}" --json 2>/dev/null | head -80

echo ""
echo "== Build Log (last ${tail_lines} lines) =="

# EAS CLI can show logs directly
eas build:view "${build_id}" --logs 2>/dev/null | tail -n "${tail_lines}"
