# Platform roadmap

Shared pieces (`web/`, `vendor/ruffle/`, archives) stay common. Only the shell changes per platform.

## 1. Apple Silicon Mac (done)

`apps/mac/` · Swift + AppKit + WKWebView · `arm64` · [mac-app.md](mac-app.md)

## 2. Intel Mac

Same `.app` on `x86_64`, ideally universal.

```bash
TARGET=x86_64-apple-macosx11.0 ./apps/mac/build.sh
# Universal: build each arch, then lipo
```

Prefer extending `apps/mac/build.sh` (`ARCH=universal`) over duplicating sources in `apps/mac-intel/`. Ruffle WASM is arch-agnostic inside the WebView.

## 3. Windows

Same SWF + feed, double-clickable.

| Approach | Notes |
|----------|-------|
| Ruffle desktop | Local HTTP server + open `movie_local.swf` |
| WebView2 + small host | Mirror Mac: borderless window loads `app-index.html` |
| Original EXE + injector | Flash is dead; skip |

Reuse `web/`, `vendor/ruffle/`, and icons from `apps/mac/icon-src/`. Scaffold under `apps/windows/`.

## 4. Modern Mac `.saver`

System Settings screensaver (not the fullscreen app).

1. `apps/mac-saver/` → `Snapmatic.saver`
2. `ScreenSaverView` hosts WKWebView against bundled `web/`
3. Start localhost HTTP inside the saver (safer than `file://` for the patched SWF)
4. Sign for local use; notarize if distributing

Validate on the macOS version you target; Screen Saver APIs keep changing.

## 5. Browser demo

`scripts/run-browser.sh` already works for local tryouts. GitHub Pages would need same-origin relative URLs and likely a second SWF patch.

## Future CI (sketch)

| Job | Output |
|-----|--------|
| `mac-arm64` | `.app` zip |
| `mac-universal` | Universal `.app` |
| `windows-x64` | Portable folder or installer |
| `mac-saver` | `.saver` (optional) |

Until then: keep photo/SWF/feed changes in `web/` only, keep shells thin, and give each new `apps/*` folder a short README linking here.
