<p align="center">
  <img src="apps/mac/icon-src/snapmatic-256.png" width="128" alt="Snapmatic Screensaver">
</p>

<h1 align="center">Snapmatic Screensaver</h1>

<p align="center">
  <strong>v1.0</strong><br>
  Open source by <a href="https://github.com/InertiaUX">Inertia</a>
</p>

<p align="center">
  Unofficial revival of Rockstar's GTA V Snapmatic Screensaver (~2013-2014).<br>
  Not affiliated with Rockstar Games or Take-Two Interactive.
</p>

## Why this exists

Rockstar's Snapmatic Screensaver showed a live mosaic of curated GTA V photos on your desktop. The official Mac and PC downloads are gone, Flash is dead, and the Social Club feed is 404.

This project brings it back for nostalgia, and so anyone can run a more modern version today: original mosaic SWF via [Ruffle](https://ruffle.rs/), local photo feed, native shell where we have one.

## Support

| Platform | Status |
|----------|--------|
| **macOS** (Apple Silicon) | Ready (`apps/mac`) |
| **Windows (PC)** | Planned (`apps/windows`) |
| **macOS** (Intel / universal) | Planned |
| **macOS** Screen Saver (`.saver`) | Planned |
| **Browser** | Works for local tryouts (`scripts/run-browser.sh`) |

Roadmap: [docs/platforms.md](docs/platforms.md).

## Quick start (macOS)

```bash
git clone https://github.com/InertiaUX/SnapmaticScreensaver.git
cd SnapmaticScreensaver
chmod +x apps/mac/build.sh scripts/*.sh
./apps/mac/build.sh
open -a ~/Applications/Snapmatic\ Screensaver.app
```

Or: `./scripts/run-mac.sh`

**Controls:** Esc / Q quit · ⌘Q quit · ⌘Tab / Dock to switch apps

### Windows / PC

No native Windows build yet. Until `apps/windows` lands, you can try the shared player in a browser (Chrome kiosk helper on macOS; on Windows, serve `web/` locally the same way and open `index.html` with Ruffle). Details in [docs/platforms.md](docs/platforms.md).

## How it works

1. `web/movie_local.swf`: original mosaic UI, patched to load config from `127.0.0.1:18765`
2. Local XML feed under `web/xxxx/.../snapmaticScreensaver.xml`
3. `web/photos/`: GTA V stills cropped to 640x360
4. Ruffle plays the SWF in a WebView
5. `apps/mac`: AppKit shell (local HTTP server, fullscreen player, Esc/focus)

## Layout

```
apps/mac/          macOS Apple Silicon shell
apps/windows/      Windows / PC shell (planned)
web/               SWF, photos, XML feed
vendor/ruffle/     vendored Flash emulator
archives/          original installers + decompiled AS3
docs/              architecture, feed, sourcing, platforms
scripts/           run-mac / run-browser helpers
```

More: [`docs/`](docs/) · provenance: [docs/sourcing.md](docs/sourcing.md) · original Newswire: [rockstargames.com](https://www.rockstargames.com/newswire/article/89k8a554595772/the-snapmatic-screensaver.html)

## License

| Part | Terms |
|------|-------|
| Revival code (shell, scripts, docs, reconstructed feed) | [MIT](LICENSE) |
| Rockstar binaries, SWF, art, photos, decompiled AS3 | Not MIT. Research/preservation only ([NOTICE](NOTICE)) |
| Ruffle | Apache-2.0 / MIT (`vendor/ruffle`) |

Contributions welcome: [CONTRIBUTING.md](CONTRIBUTING.md).
