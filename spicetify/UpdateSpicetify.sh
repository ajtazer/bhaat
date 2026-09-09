#!/bin/bash
# UpdateSpicetify.sh — keep the spicetify patch alive across Spotify auto-updates.
#
# Spotify updates itself silently. Every update restores xpui.spa and deletes the
# patched xpui/ folder, taking the theme and every extension with it. Nothing
# errors — Spotify just comes back stock, which is a confusing way to find out.
#
#   (no args)   full run: backup, upgrade spicetify, reapply, relaunch Spotify
#   --check     fast + silent unless the patch is missing; used from .zshrc
#   --repair    reapply without the network round-trip of `spicetify upgrade`

set -uo pipefail

SPICETIFY="$HOME/.spicetify/spicetify"
XPUI="/Applications/Spotify.app/Contents/Resources/Apps/xpui"
CONFIG="$HOME/.config/spicetify/config-xpui.ini"
export PATH="$PATH:$HOME/.spicetify"

# The patch lives as an extracted xpui/ folder. A Spotify update deletes it and
# puts xpui.spa back, so this single stat is the whole health check.
patched() { [[ -d "$XPUI" ]]; }

if [[ "${1:-}" == "--check" ]]; then
    patched && exit 0
    printf '\033[33mspicetify:\033[0m patch is gone — Spotify updated. Run \033[1mUpdateSpicetify.sh\033[0m\n' >&2
    exit 1
fi

[[ -x "$SPICETIFY" ]] || { echo "spicetify not found at $SPICETIFY" >&2; exit 1; }

# Version drift is informational; the reapply below is unconditional either way.
if [[ -f "$CONFIG" ]]; then
    backup_ver=$(awk '/^\[Backup\]/{f=1} f&&/^version/{print $3; exit}' "$CONFIG" | cut -d. -f1-4)
    spotify_ver=$(defaults read /Applications/Spotify.app/Contents/Info.plist CFBundleVersion 2>/dev/null)
    if [[ -n "$backup_ver" && -n "$spotify_ver" && "$backup_ver" != "$spotify_ver" ]]; then
        echo "Spotify $spotify_ver, backup pinned to $backup_ver — re-backing up."
    fi
fi

osascript -e 'quit app "Spotify"' >/dev/null 2>&1 || true
for _ in {1..10}; do pgrep -x Spotify >/dev/null || break; sleep 0.5; done
pkill -x Spotify >/dev/null 2>&1 || true

[[ "${1:-}" == "--repair" ]] || "$SPICETIFY" upgrade

# `backup apply`, not plain `apply`: after a Spotify update the stored backup
# still points at the old build, and plain apply will patch against it.
"$SPICETIFY" backup apply || { echo "spicetify backup apply failed" >&2; exit 1; }

if patched; then
    echo "spicetify patch restored."
else
    echo "warning: xpui/ still missing after apply" >&2
    exit 1
fi

# You run this to get Spotify working again, so always bring it back up.
open -a Spotify
