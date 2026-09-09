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

**Hazy** — a translucent theme ([Astromations/Hazy](https://github.com/Astromations/Hazy)): frosted
panels floating over the album art. Replaced `TextMinimal`, which is still in `themes/` for when the
monospace-wireframe mood comes back.

Worth being precise about what "translucent" buys you on macOS, because the word oversells it. It's
`backdrop-filter: blur(25px)` on panels sitting over an *in-app* background. Not see-through to the
desktop. Spotify's macOS window is an opaque Chromium `NSWindow` and spicetify can't set native
vibrancy on it, so frosted-glass-over-album-art is the ceiling.

### hazy is vendored, not installed the way upstream says

Stock, Hazy's `user.css` is 70 bytes — an `@import` from jsDelivr — and its `theme.js` is 268 bytes
of remote `<script>` loader. The normal install pulls ~105KB of CSS *and JS* off a third-party CDN
into the Spotify client on every launch, with full Spicetify API access, updating silently whenever
upstream pushes. Pinned to `1926d9d` instead:

```sh
T=~/.config/spicetify/Themes/Hazy && mkdir -p "$T"
B=https://raw.githubusercontent.com/Astromations/Hazy/1926d9db3e0313b68ca6e2193c2b278e733ac3c4
curl -fsSL -o "$T/user.css"  $B/app.css   # inlined, replaces the @import
curl -fsSL -o "$T/theme.js"  $B/hazy.js   # inlined, replaces the loader
curl -fsSL -o "$T/color.ini" $B/color.ini
```

`hazy.js` self-guards on `Spicetify.Platform`, so inlining it as `theme.js` works fine. Costs you
auto-updates — re-run to bump. One remote asset survives: the default background is an imgur link,
which goes away the moment you set a custom one. Wants `overwrite_assets 1`, unlike TextMinimal.

The 104KB of vendored CSS/JS isn't committed here — same rule as TextMinimal, no upstream theme
forks in this repo. The pinned commit above is the reproducible part.

### adblock

`adblockify.js` ([rxri](https://github.com/rxri/spicetify-extensions)) — the one genuinely maintained
spicetify ad blocker, and effectively the only first-tier option. It disables the audio, billboard,
leaderboard, sponsored-playlist, in-stream and VTO ad managers, repoints ad-slot endpoints at
`localhost/no/thanks`, forces `product: premium` overrides, and hides the upgrade CTA. The
`CharlieS1103` fork is the same idea, older and smaller. The bundled `autoSkipVideo.js` looks like a
candidate and isn't — its source explicitly *excludes* ads.

```sh
curl -fsSL -o ~/.config/spicetify/Extensions/adblockify.js \
  https://raw.githubusercontent.com/rxri/spicetify-extensions/main/adblock/adblock.js
spicetify config extensions adblockify.js && spicetify apply
```

Against Spotify's ToS, and accounts do occasionally get flagged for it. Known tradeoff.

### the update tax

Spotify auto-updates itself, and every update replaces `xpui.spa` and deletes the patched folder —
theme, extensions, all of it. Nothing errors. It's just silently stock again, which is a genuinely
confusing way to find out. The fix, after every Spotify update:

```sh
spicetify backup apply
```

Plain `apply` is not enough — the backup still points at the old build.

`UpdateSpicetify.sh` wraps that, and decides *first* whether there is anything to do. Run bare, it
compares the installed Spotify build against the `[Backup]` version in `config-xpui.ini` and checks
the `xpui/` folder still exists. If both are fine it prints one line and exits without touching
Spotify. `--force` reapplies anyway, for after a config change.

That ordering matters. `spicetify backup apply` fails outright on a healthy install — you cannot
back up over an already-patched Spotify, and it will tell you to restore first. So `backup apply`
is only correct when Spotify has actually moved to a new build; the rest of the time the right
command is plain `apply`. Picking between them is the whole job:

| state | command |
|---|---|
| new Spotify build, or `xpui/` gone | `restore` if needed, then `backup apply` |
| patch intact, versions match | `apply` — and only when asked |

The useful part is `--check`, wired into `.zshrc`:

```sh
[[ -x "$HOME/UpdateSpicetify.sh" ]] && "$HOME/UpdateSpicetify.sh" --check
```

It is one `stat`. The patch lives as an extracted `xpui/` folder and a Spotify update deletes it,
so testing that one directory *is* the health check — no version parsing, no `defaults read`, no
fork of spicetify itself. Silent when things are fine, one yellow line when they aren't.

Deliberately does **not** self-repair on startup. Reapplying takes ~20s and kills Spotify, and
having a random new terminal tab do that mid-song is worse than the problem it solves. The warning
tells you; fixing it stays a decision you make.

### extensions

Kept thin on purpose: `adblockify` and `fullAppDisplay` (the only two that earn a topbar button),
plus `shuffle+` and `keyboardShortcut`, which draw no UI at all. `popupLyrics` is out — the
`lyrics-plus` custom app puts a second lyrics button in the same corner, and two lyrics buttons is
one lyrics button too many.

### TextMinimal, the fallback

Spicetify's stock [`text`](https://github.com/spicetify/spicetify-themes/tree/master/text) theme
with `overrides.css` layered on top. Only the overrides live here, not a fork of the upstream theme.

Stock `text` is a deliberately stark monospace wireframe, and I liked the font but not the wireframe
part. What the overrides undo:

- **Pane labels.** It draws `Pages` / `Library` / `Main` / `Playing` / `Sidebar` on each panel via
  `::before`, positioned with `margin: -10px`. Which means the top one renders *above* its own
  panel and gets clipped off the edge of the window. Gone.
- **The progress bar.** `--progress-bar-height: 16px` upstream. That's not a progress bar, that's
  a highlighter stripe across the bottom of the screen. Now 4px.
- **Filter chips.** Monospace is wide, so `Playlists / Podcasts / Albums / Artists` didn't fit on
  one row and `Albums` truncated to `Albur›`. They wrap now.
- **A stray `/`** that hung on its own line under the elapsed-time counter.

Its `color.ini` carries the good schemes — `Kanagawa`, `TokyoNight`, `Gruvbox`, `RosePine`,
`CatppuccinMocha`. Switching back is one line:

```sh
spicetify config current_theme TextMinimal color_scheme Kanagawa && spicetify apply
```

Hazy ships exactly one scheme, `Base`.

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
