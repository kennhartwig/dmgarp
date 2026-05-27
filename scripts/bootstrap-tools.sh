#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOWNLOADS="$ROOT/downloads"
TOOLS="$ROOT/tools"
MGBA_ROOT="$TOOLS/mgba-root"
RGBDS_VERSION="v1.0.1"
MGBA_VERSION="0.10.5"
RGBDS_ARCHIVE="rgbds-linux-x86_64.tar.xz"
MGBA_ARCHIVE="mGBA-${MGBA_VERSION}-ubuntu64-focal.tar.xz"
RGBDS_URL="https://github.com/gbdev/rgbds/releases/download/${RGBDS_VERSION}/${RGBDS_ARCHIVE}"
MGBA_URL="https://github.com/mgba-emu/mgba/releases/download/${MGBA_VERSION}/${MGBA_ARCHIVE}"

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1" >&2
        exit 1
    }
}

need_cmd curl
need_cmd tar
need_cmd dpkg-deb

mkdir -p "$DOWNLOADS" "$TOOLS"

if [[ ! -x "$TOOLS/rgbasm" ]]; then
    archive="$DOWNLOADS/$RGBDS_ARCHIVE"
    if [[ ! -f "$archive" ]]; then
        curl -fL --retry 3 -o "$archive" "$RGBDS_URL"
    fi
    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' EXIT
    tar -xf "$archive" -C "$temp_dir"
    cp "$temp_dir"/rgbasm "$temp_dir"/rgblink "$temp_dir"/rgbfix "$temp_dir"/rgbgfx "$TOOLS"/
    chmod +x "$TOOLS"/rgbasm "$TOOLS"/rgblink "$TOOLS"/rgbfix "$TOOLS"/rgbgfx
    rm -rf "$temp_dir"
    trap - EXIT
fi

if [[ ! -x "$MGBA_ROOT/usr/bin/mgba" ]]; then
    archive="$DOWNLOADS/$MGBA_ARCHIVE"
    if [[ ! -f "$archive" ]]; then
        curl -fL --retry 3 -o "$archive" "$MGBA_URL"
    fi
    mkdir -p "$TOOLS/mGBA-${MGBA_VERSION}-ubuntu64-focal" "$MGBA_ROOT"
    tar -xf "$archive" -C "$TOOLS"
    dpkg-deb -x "$TOOLS/mGBA-${MGBA_VERSION}-ubuntu64-focal/libmgba.deb" "$MGBA_ROOT"
    dpkg-deb -x "$TOOLS/mGBA-${MGBA_VERSION}-ubuntu64-focal/mgba-sdl.deb" "$MGBA_ROOT"
fi
