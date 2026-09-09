# bhaat

**bhaat** (भात) means *cooked rice* in several Indian languages. So: my desktop rice.

macOS. Apple Terminal, of all things — no fancy emulator, the pretty part is all zsh and
starship. Configs land here whenever I get bored of how something looks, which is often.

```
starship/      the prompt
spicetify/     Spotify
ccstatusline/  Claude Code status line
git/           gitconfig
```

---

## starship

The `tazer ~ ♥ 07:54 PM` prompt. Hand-built powerline format — OS glyph, user, directory,
git branch + status, time — each segment its own hex background with `` dividers between.

Needs a Nerd Font for the powerline glyphs and icons. I use **MesloLG**:

```sh
brew install --cask font-meslo-lg-nerd-font
```

Then point the terminal profile at *MesloLGL Nerd Font Mono*. Without it you get tofu boxes
where every divider and icon should be.

Loaded from `.zshrc` with `eval "$(starship init zsh)"` — that one line is the whole hookup.

## spicetify

`TextMinimal` — spicetify's stock [`text`](https://github.com/spicetify/spicetify-themes/tree/master/text)
theme with `overrides.css` layered on top. Only the overrides live here, not a fork of the
upstream theme.

Stock `text` is a deliberately stark monospace wireframe, and I liked the font but not the
wireframe part. What the overrides undo:

- **Pane labels.** It draws `Pages` / `Library` / `Main` / `Playing` / `Sidebar` on each panel via
  `::before`, positioned with `margin: -10px`. Which means the top one renders *above* its own
  panel and gets clipped off the edge of the window. Gone.
- **The progress bar.** `--progress-bar-height: 16px` upstream. That's not a progress bar, that's
  a highlighter stripe across the bottom of the screen. Now 4px.
- **Filter chips.** Monospace is wide, so `Playlists / Podcasts / Albums / Artists` didn't fit on
  one row and `Albums` truncated to `Albur›`. They wrap now.
- **A stray `/`** that hung on its own line under the elapsed-time counter.

Colour scheme is **Nord**. Anything in the theme's `color.ini` works — `Kanagawa`, `TokyoNight`,
`Gruvbox`, `RosePine`, `CatppuccinMocha`:

```sh
spicetify config color_scheme Kanagawa && spicetify apply
```

Extensions kept thin on purpose: `fullAppDisplay` and `popupLyrics` (the only two that earn their
topbar buttons), plus `shuffle+` and `keyboardShortcut`, which draw no UI at all.

`config-xpui.ini` is here for reference — it hardcodes `spotify_path` and `prefs_path` and pins a
`[Backup]` version to my Spotify build, so it isn't portable as-is.

## ccstatusline

Two lines, because one line truncated:

```
⚡TAZER | model | git-branch | git-changes | session-cost | reset-timer
context-bar | session-usage | weekly-usage
```

The context meter is a `context-bar` in `slider-only` mode. It used to be `context-percentage`,
which renders as a bare unlabelled number — completely indistinguishable from the session and
weekly percentages sitting right next to it. As a bar you can actually read it at a glance.

Schema v4. Wants [ccstatusline](https://github.com/sirmalloc/ccstatusline) and a `statusLine`
entry in `~/.claude/settings.json`.

## the rest

Tools the setup leans on, all via brew: `eza` (ls with icons), `bat` (cat with highlighting),
`fzf`, `zoxide`, `starship`.

---

*Not an installer. Copy what looks good.*
