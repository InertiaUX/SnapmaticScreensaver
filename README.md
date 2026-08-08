# Snapmatic Screensaver Revival

Open-source preservation of Rockstar’s **Grand Theft Auto V Snapmatic Screensaver** (announced ~2013–2014) on modern machines.

Rockstar shipped free Mac/PC builds that showed a live mosaic of curated Snapmatic photos from Los Santos via Flash (`movie.swf`) and a Social Club XML feed. The installers vanished from `media.rockstargames.com`, Adobe Flash died, the feed went 404, and Social Club itself was later shut down — so the official screensaver is effectively abandoned. This repo recovers the originals from Wayback archives, runs the **original SWF** through [Ruffle](https://ruffle.rs/), replaces the dead feed with a local one, and wraps it in a native shell.

> **Status:** Apple Silicon Mac app works today. Intel Mac, Windows, and a true modern `.saver` are planned — see [docs/platforms.md](docs/platforms.md).  
> **Not affiliated** with Rockstar Games or Take-Two Interactive.

## Quick start (Apple Silicon Mac)

```bash
git clone https://github.com/InertiaUX/SnapmaticScreensaver.git
cd SnapmaticScreensaver
chmod +x apps/mac/build.sh scripts/*.sh
./apps/mac/build.sh
open -a ~/Applications/Snapmatic\ Screensaver.app
```

Or: `./scripts/run-mac.sh`

- **Esc** or **Q** — quit  
- **⌘Q** — quit via menu  
- **⌘Tab** / Dock — use other apps; mosaic drops behind them  

## What’s in this repo

```
SnapmaticScreensaver/
├── README.md                 ← you are here
├── LICENSE                   ← MIT for original revival code (see NOTICE)
├── NOTICE                    ← trademarks + Rockstar asset disclaimer
├── CONTRIBUTING.md
├── docs/                     ← how each piece works
│   ├── architecture.md
│   ├── original-flash.md
│   ├── photo-feed.md
│   ├── mac-app.md
│   ├── sourcing.md           ← where each asset came from
│   └── platforms.md          ← Intel / Windows / modern .saver roadmap
├── apps/
│   └── mac/                  ← current Apple Silicon Swift shell
├── web/                      ← shared runtime: SWF + photos + XML feed
├── vendor/ruffle/            ← vendored Flash emulator (JS + WASM)
├── archives/
│   ├── original/             ← Wayback installers + unpatched movie.swf
│   └── decompiled-source/    ← AS3 from movie.swf (research)
└── scripts/                  ← run-mac / run-browser helpers
```

## How it works (short version)

1. **`movie_local.swf`** — original Flash mosaic UI, binary-patched so its config URL points at `127.0.0.1:18765` instead of Rockstar’s dead Social Club host.
2. **`web/xxxx/.../snapmaticScreensaver.xml`** — fake feed matching the schema the SWF expects (`cloudStatus`, `numCols`, image URLs).
3. **`web/photos/`** — period-accurate GTA V / Snapmatic stills, cropped to 640×360.
4. **Ruffle** — plays the SWF in a WebView (no Adobe Flash).
5. **`apps/mac`** — small AppKit app: starts a local HTTP server, loads the player fullscreen, handles Esc / focus.

Longer explanations live in [`docs/`](docs/).

## Provenance (short)

| Asset | Source |
|-------|--------|
| Mac / PC installers | Wayback captures of dead `media.rockstargames.com` ZIPs |
| SWF + AS3 schema | Extracted from Mac `.saver`; decompiled with FFDec |
| Local XML feed | Rebuilt (original Social Club XML never archived) |
| Photos | Wayback Newswire JPEGs, cropped to 640×360 — not the lost live Snapmatic CDN pool |
| App icon | PC EXE PE icons (Mac `DLMIcon.icns` was a Dreamweaver placeholder) |
| Ruffle | npm `@ruffle-rs/ruffle`, vendored under `vendor/ruffle/` |

Full hunt notes, Wayback URLs, and methods: **[docs/sourcing.md](docs/sourcing.md)**

Original Newswire article:  
https://www.rockstargames.com/newswire/article/89k8a554595772/the-snapmatic-screensaver.html

## License / attribution

| Part | License |
|------|---------|
| Original revival code (Mac shell, scripts, docs, reconstructed feed) | [MIT](LICENSE) |
| Rockstar binaries, SWF, art, photos, decompiled AS3 | **Not** MIT — copyright holders retain rights; research/preservation only ([NOTICE](NOTICE)) |
| Ruffle | Apache-2.0 / MIT (`vendor/ruffle`) |

This is an unofficial fan preservation project — not affiliated with or endorsed by Rockstar or Take-Two. See [CONTRIBUTING.md](CONTRIBUTING.md) if you want to help with Intel Mac, Windows, or a modern `.saver`.

## Next

See [docs/platforms.md](docs/platforms.md) for Intel Mac, Windows, and modern ScreenSaver.framework targets.
