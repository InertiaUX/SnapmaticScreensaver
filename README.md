# Snapmatic Screensaver Revival

Revival of Rockstar's GTA V Snapmatic Screensaver (~2013-2014) for modern machines.

The original Mac/PC builds used Flash (`movie.swf`) plus a Social Club XML photo feed. Flash is gone, the feed is 404, Social Club is shut down, and the official downloads are dead. This repo runs the original SWF through [Ruffle](https://ruffle.rs/), serves a local feed, and wraps it in a native shell.

> **Status:** Apple Silicon Mac app works. Intel Mac, Windows, and a modern `.saver` are planned ([docs/platforms.md](docs/platforms.md)).  
> Unofficial fan project. Not affiliated with Rockstar or Take-Two.

## Quick start (Apple Silicon)

```bash
git clone https://github.com/InertiaUX/SnapmaticScreensaver.git
cd SnapmaticScreensaver
chmod +x apps/mac/build.sh scripts/*.sh
./apps/mac/build.sh
open -a ~/Applications/Snapmatic\ Screensaver.app
```

Or: `./scripts/run-mac.sh`

- Esc / Q: quit
- ⌘Q: quit via menu
- ⌘Tab / Dock: switch apps (mosaic drops behind them)

## Layout

```
apps/mac/          Apple Silicon Swift shell
web/               SWF, photos, XML feed
vendor/ruffle/     vendored Flash emulator
archives/          original installers + decompiled AS3
docs/              architecture, feed, sourcing, platforms
scripts/           run-mac / run-browser helpers
```

## How it works

1. `web/movie_local.swf`: original mosaic UI, binary-patched to load config from `127.0.0.1:18765`
2. Local XML feed under `web/xxxx/.../snapmaticScreensaver.xml` (`cloudStatus`, `numCols`, image URLs)
3. `web/photos/`: GTA V stills cropped to 640x360
4. Ruffle plays the SWF in a WebView
5. `apps/mac`: AppKit shell (local HTTP server, fullscreen player, Esc/focus)

Details: [`docs/`](docs/). Provenance and Wayback URLs: [docs/sourcing.md](docs/sourcing.md).

Original Newswire: https://www.rockstargames.com/newswire/article/89k8a554595772/the-snapmatic-screensaver.html

## License

| Part | Terms |
|------|-------|
| Revival code (shell, scripts, docs, reconstructed feed) | [MIT](LICENSE) |
| Rockstar binaries, SWF, art, photos, decompiled AS3 | Not MIT. Research/preservation only ([NOTICE](NOTICE)) |
| Ruffle | Apache-2.0 / MIT (`vendor/ruffle`) |

See [CONTRIBUTING.md](CONTRIBUTING.md) to help with other platforms.
