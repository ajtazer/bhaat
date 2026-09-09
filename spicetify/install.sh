#!/usr/bin/env bash
# Builds the TextMinimal theme and applies this spicetify config.
# TextMinimal = spicetify's stock "text" theme + overrides.css layered on top,
# so upstream stays untouched and the override set stays readable.
set -euo pipefail

export PATH="$PATH:$HOME/.spicetify"
command -v spicetify >/dev/null || { echo "spicetify not on PATH"; exit 1; }

CFG="$(dirname "$(spicetify -c)")"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -d "$CFG/Themes/text" ] || {
  echo "Stock 'text' theme missing. Install the theme pack first:"
  echo "  https://github.com/spicetify/spicetify-themes"
  exit 1
}

echo "==> building TextMinimal"
rm -rf "$CFG/Themes/TextMinimal"
mkdir -p "$CFG/Themes/TextMinimal"
cp "$CFG/Themes/text/user.css" "$CFG/Themes/text/color.ini" "$CFG/Themes/TextMinimal/"
cat "$SRC/themes/TextMinimal/overrides.css" >> "$CFG/Themes/TextMinimal/user.css"

echo "==> applying config"
# config-xpui.ini holds machine-specific spotify_path/prefs_path, so set the
# interesting keys rather than clobbering the whole file.
spicetify config current_theme TextMinimal color_scheme Nord
spicetify config extensions "fullAppDisplay.js|shuffle+.js|keyboardShortcut.js|popupLyrics.js"
spicetify config custom_apps "marketplace|lyrics-plus"
spicetify config sidebar_config 0 home_config 0
spicetify backup apply

echo "==> done"
