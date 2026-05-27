#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROM="${1:-$ROOT/roms/dmg-demo.gb}"
MGBA_ROOT="$ROOT/tools/mgba-root"

export LD_LIBRARY_PATH="$MGBA_ROOT/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SDL_VIDEODRIVER=dummy
export SDL_AUDIODRIVER=dummy
cd "$ROOT"

set +e
timeout 2 "$MGBA_ROOT/usr/bin/mgba" "$ROM" >/dev/null
status=$?
set -e

if [[ "$status" -ne 0 && "$status" -ne 124 ]]; then
    exit "$status"
fi
