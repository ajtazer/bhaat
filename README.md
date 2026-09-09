# bhaat

**bhaat** (भात) means *cooked rice* in several Indian languages — so, my desktop rice.

Configs for things I stare at all day. Updated whenever I get bored of how something looks.

## What's in here

| | |
|---|---|
| [`spicetify/`](spicetify/) | Spotify — **TextMinimal** theme (Nord), monospace, decluttered |
| [`ccstatusline/`](ccstatusline/) | Claude Code status line — two-line layout with a context bar |

## spicetify

`TextMinimal` is spicetify's stock [`text`](https://github.com/spicetify/spicetify-themes/tree/master/text)
theme with [`overrides.css`](spicetify/themes/TextMinimal/overrides.css) layered on top. Only the
overrides are vendored here, not the upstream theme, so it stays a readable diff rather than a fork.

What the overrides fix:

- **Pane labels removed** — stock `text` draws `Pages` / `Library` / `Main` / `Playing` / `Sidebar`
  wireframe labels via `::before`, positioned with `margin: -10px`, which clips the top one off the
  window edge.
- **Progress bar slimmed** — `--progress-bar-height` is `16px` upstream, a solid slab across the
  bottom of the screen. Now `4px`.
- **Filter chips wrap** — the monospace font is too wide for `Playlists / Podcasts / Albums / Artists`
  on one row, so `Albums` truncated to `Albur›`. They wrap now instead of scrolling under a mask.
- **Orphan `/` removed** from under the elapsed-time counter.

Colour scheme is **Nord**. Any scheme in the theme's `color.ini` works —
`Kanagawa`, `TokyoNight`, `Gruvbox`, `RosePine`, `CatppuccinMocha`, …

```sh
spicetify config color_scheme Kanagawa && spicetify apply
```

Extensions kept deliberately thin: `fullAppDisplay`, `popupLyrics` (these two add topbar buttons),
plus `shuffle+` and `keyboardShortcut`, which render no UI at all.

```sh
./spicetify/install.sh
```

`config-xpui.ini` is committed for reference, but the installer sets individual keys instead of
copying it — it contains machine-specific `spotify_path` and `prefs_path`.

## ccstatusline

Two lines, so nothing truncates:

```
⚡TAZER | model | git-branch | git-changes | session-cost | reset-timer
context-bar | session-usage | weekly-usage
```

The context meter is a `context-bar` in `slider-only` mode rather than `context-percentage` — as a
bare number it was indistinguishable from the session and weekly percentages sitting next to it.

```sh
./ccstatusline/install.sh
```

Needs [ccstatusline](https://github.com/sirmalloc/ccstatusline) and a `statusLine` entry in
`~/.claude/settings.json`. Config schema is v4.
