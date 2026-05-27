#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROM="${1:-$ROOT/roms/dmg-demo.gb}"
MGBA_ROOT="$ROOT/tools/mgba-root"
MGBA_SCALE="${MGBA_SCALE:-5}"

export LD_LIBRARY_PATH="$MGBA_ROOT/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
cd "$ROOT"
exec "$MGBA_ROOT/usr/bin/mgba" --scale "$MGBA_SCALE" --debug "$ROM"
