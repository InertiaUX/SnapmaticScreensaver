# Platform roadmap

Shared pieces (`web/`, `vendor/ruffle/`, archives) stay common. Only the shell changes per platform.

## 1. Apple Silicon Mac (done)

`apps/mac/` · Swift + AppKit + WKWebView · `arm64` · [mac-app.md](mac-app.md)

```bash
./apps/mac/build.sh
```

## 2. Intel / universal Mac (done)

Same `.app`, built from `apps/mac/`:

```bash
ARCH=x86_64 ./apps/mac/build.sh
ARCH=universal ./apps/mac/build.sh
```

Ruffle WASM is arch-agnostic inside the WebView.

## 3. Windows (done)

Portable launcher: `apps/desktop/` (Go HTTP server + Edge/Chrome app mode).

```bash
./apps/desktop/build.sh
# → dist/desktop/*-windows-amd64.zip
```

## 4. Linux (done)

Same `apps/desktop/` launcher (Chromium/Chrome kiosk).

```bash
./apps/desktop/build.sh
# → dist/desktop/*-linux-amd64.zip
```

## 5. Modern Mac `.saver` (planned)

System Settings screensaver (not the fullscreen app).

1. `apps/mac-saver/` → `Snapmatic.saver`
2. `ScreenSaverView` hosts WKWebView against bundled `web/`
3. Start localhost HTTP inside the saver (safer than `file://` for the patched SWF)
4. Sign for local use; notarize if distributing

## 6. Browser demo

`scripts/run-browser.sh` for local tryouts without packaging.

## Packaging

| Artifact | How |
|----------|-----|
| macOS arm64 `.app` zip | `ARCH=arm64 DIST_DIR=… ./apps/mac/build.sh` then `ditto -c -k --keepParent` |
| macOS Intel `.app` zip | `ARCH=x86_64 …` |
| macOS universal `.app` zip | `ARCH=universal …` |
| Windows / Linux zips | `./apps/desktop/build.sh` |

Keep photo/SWF/feed changes in `web/` only. Keep shells thin.
