#!/bin/bash
# UpdateSpicetify.sh — keep the spicetify patch alive across Spotify auto-updates.
#
# Spotify updates itself silently. Every update restores xpui.spa and deletes the
# patched xpui/ folder, taking the theme and every extension with it. Nothing
# errors — Spotify just comes back stock.
#
#   (no args)   figure out what's actually wrong, fix only that, else do nothing
#   --check     report only, change nothing, stay silent when healthy (.zshrc)
#   --force     reapply even when nothing looks wrong (after a config change)
#   --upgrade   upgrade the spicetify binary too, then repair if needed

set -uo pipefail

SPICETIFY="$HOME/.spicetify/spicetify"
XPUI="/Applications/Spotify.app/Contents/Resources/Apps/xpui"
CONFIG="$HOME/.config/spicetify/config-xpui.ini"
export PATH="$PATH:$HOME/.spicetify"

MODE="${1:-}"

# The patch lives as an extracted xpui/ folder; a Spotify update deletes it.
patched()     { [[ -d "$XPUI" ]]; }
backup_ver()  { awk '/^\[Backup\]/{f=1} f&&/^version/{print $3; exit}' "$CONFIG" 2>/dev/null | cut -d. -f1-4; }
spotify_ver() { defaults read /Applications/Spotify.app/Contents/Info.plist CFBundleVersion 2>/dev/null; }

BV=$(backup_ver)
SV=$(spotify_ver)
outdated() { [[ -n "$BV" && -n "$SV" && "$BV" != "$SV" ]]; }

if [[ "$MODE" == "--check" ]]; then
    if ! patched; then
        printf '\033[33mspicetify:\033[0m patch is gone — Spotify updated. Run \033[1mUpdateSpicetify.sh\033[0m\n' >&2
        exit 1
    fi
    if outdated; then
        printf '\033[33mspicetify:\033[0m Spotify is %s, patch built for %s. Run \033[1mUpdateSpicetify.sh\033[0m\n' "$SV" "$BV" >&2
        exit 1
    fi
    exit 0
fi

[[ -x "$SPICETIFY" ]] || { echo "spicetify not found at $SPICETIFY" >&2; exit 1; }

[[ "$MODE" == "--upgrade" ]] && "$SPICETIFY" upgrade

# Work out what is actually needed before touching anything.
#   rebackup — Spotify is on a new build, or the patch is missing entirely
#   apply    — patch is fine, caller just wants the config reapplied
ACTION=""
if outdated || ! patched; then
    ACTION="rebackup"
elif [[ "$MODE" == "--force" || "$MODE" == "--upgrade" ]]; then
    ACTION="apply"
fi

if [[ -z "$ACTION" ]]; then
    echo "spicetify: nothing to do — Spotify $SV, patch intact. (--force to reapply anyway)"
    exit 0
fi

# Only now is Spotify worth closing.
was_running=false
pgrep -x Spotify >/dev/null && was_running=true
osascript -e 'quit app "Spotify"' >/dev/null 2>&1 || true
for _ in {1..10}; do pgrep -x Spotify >/dev/null || break; sleep 0.5; done
pkill -x Spotify >/dev/null 2>&1 || true

if [[ "$ACTION" == "rebackup" ]]; then
    echo "Spotify $SV, patch built for ${BV:-none} — rebuilding backup."
    # spicetify refuses to back up over an already-patched install, so if
    # anything survived, put it back to stock before taking a fresh backup.
    patched && "$SPICETIFY" restore
    "$SPICETIFY" backup apply || { echo "spicetify backup apply failed" >&2; exit 1; }
else
    "$SPICETIFY" apply || { echo "spicetify apply failed" >&2; exit 1; }
fi

patched || { echo "warning: xpui/ still missing after apply" >&2; exit 1; }
echo "spicetify patch OK."

$was_running && open -a Spotify
exit 0
