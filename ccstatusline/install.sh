#!/usr/bin/env bash
# Installs the ccstatusline config for Claude Code.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/ccstatusline"

mkdir -p "$DEST"
[ -f "$DEST/settings.json" ] && cp "$DEST/settings.json" "$DEST/settings.json.bak-$(date +%Y%m%d)"
cp "$SRC/settings.json" "$DEST/settings.json"
echo "==> installed to $DEST/settings.json"
echo "    make sure ~/.claude/settings.json points statusLine at the ccstatusline binary"
