# Platform roadmap

People will want more than the current Apple Silicon app. Shared pieces (`web/`, `vendor/ruffle/`, archives) stay common; only the shell changes per platform.

## 1. Apple Silicon Mac (done)

- Path: `apps/mac/`
- Shell: Swift + AppKit + WKWebView
- Arch: `arm64`
- Docs: [mac-app.md](mac-app.md)

## 2. Intel Mac

**Goal:** Same `.app` experience on `x86_64` (and ideally a universal binary).

Suggested approach:

```bash
# Intel-only
TARGET=x86_64-apple-macosx11.0 ./apps/mac/build.sh

# Universal (lipo arm64 + x86_64)
# 1) build each arch to a temp binary
# 2) lipo -create -output SnapmaticScreensaver arm64-bin x86_64-bin
```

Options:

| Option | Pros | Cons |
|--------|------|------|
| A. Extend `apps/mac/build.sh` with `ARCH=universal` | One folder | Slightly more complex script |
| B. `apps/mac-intel/` sibling | Clear separation | Duplicate plist/HTML |

**Recommendation:** Option A — same sources, multi-arch build flag. Ruffle WASM is already arch-agnostic inside the WebView.

**Test on:** Intel Mac or Rosetta (`arch -x86_64 …`) where available.

## 3. Windows (PC)

**Goal:** Double-clickable Windows build using the same SWF + feed.

Suggested approaches (pick one later):

| Approach | Notes |
|----------|-------|
| **Ruffle desktop** | Official desktop player + launcher script that starts a local HTTP server and opens `movie_local.swf` |
| **WebView2 + tiny host** | Mirror the Mac design: C#/Rust/Go tray or borderless window + embedded Edge WebView2 loading `app-index.html` |
| **Ship original EXE + injector** | Least authentic to *modern* Windows; Flash is dead — not recommended |

Shared assets to reuse as-is:

- `web/movie_local.swf`
- `web/photos/` + XML feed
- `vendor/ruffle/`
- Icon from `apps/mac/icon-src/` (already from the PC EXE)

Scaffold later as `apps/windows/` with a `build.ps1` / GitHub Actions Windows job.

## 4. Modern Mac `.saver` (true screensaver)

**Goal:** Appear in System Settings → Screen Saver, idle-activate like 2013.

This is a **different** product from the fullscreen app:

| App shell (today) | ScreenSaver.framework |
|-------------------|------------------------|
| Normal app, Esc to quit | Loaded by `ScreenSaverEngine` |
| Easy to debug | Sandboxed / preview vs full-screen quirks |
| Cmd-Tab friendly | Must implement `ScreenSaverView` |

Sketch:

1. New target `apps/mac-saver/` → `Snapmatic.saver` bundle.
2. `ScreenSaverView` hosts WKWebView (or draws via Ruffle if embeddable) pointing at bundled `web/`.
3. Local HTTP server must start inside the saver process (or use `file://` + Ruffle `base` URL carefully — HTTP is safer for the patched SWF).
4. Sign for local use; notarization if distributing.

Apple has tightened Screen Saver APIs over time; validate on the current macOS you target before promising a download.

## 5. Browser-only demo

Already half-there via `scripts/run-browser.sh`. Nice for GitHub Pages **only if** you accept that the XML URLs must be same-origin (relative paths) and the SWF may need a second patch for non-localhost hosts. Good for “try it” demos; not a screensaver.

## Suggested build matrix (future CI)

| Job | Output |
|-----|--------|
| `mac-arm64` | `Snapmatic Screensaver.app` (zip) |
| `mac-universal` | Universal `.app` |
| `windows-x64` | Installer or portable folder |
| `mac-saver` | `Snapmatic.saver` (optional, harder) |

## Working agreement

Until those land:

1. Keep **all photo/SWF/feed changes** in `web/` only.
2. Keep platform shells thin — no duplicated mosaic logic.
3. Document each new `apps/*` folder with a short README that links back here.
