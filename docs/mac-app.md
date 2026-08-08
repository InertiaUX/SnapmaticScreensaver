# Mac app (Apple Silicon)

Current working target: a native **AppKit** app that hosts the shared `web/` player.

## Location

```
apps/mac/
├── main.swift          # App shell
├── Info.plist          # Bundle id, ATS for localhost HTTP, icon
├── app-index.html      # Ruffle page loaded in WKWebView
├── AppIcon.icns        # Real Snapmatic camera icon
├── icon-src/           # .ico / PNG extracted from the PC EXE
└── build.sh            # Compile + assemble ~/Applications/…
```

Bundle id: `com.rockstargames.screensavers.vsnapmatic.revival`  
Output: `~/Applications/Snapmatic Screensaver.app` (override with `DIST_DIR=…`)

## What `main.swift` does

| Concern | Behavior |
|---------|----------|
| Feed server | Spawns `python3 -m http.server` on port 18765 if nothing is listening |
| Window | Borderless, sized to the main display |
| Focused | `window.level = .screenSaver` — covers menu bar/Dock in place (no separate Space) |
| Unfocused | Level drops to `.normal` + `orderBack` so Cmd-Tab / Dock apps are usable |
| Quit | Esc or bare `Q` via `NSEvent.addLocalMonitorForEvents` (WebKit would otherwise swallow keys); also ⌘Q via the app menu |
| Cursor | Hidden while active; unhidden on resign / quit (balanced hide/unhide) |

## Build

Requires Xcode CLT / `swiftc` on Apple Silicon.

```bash
./apps/mac/build.sh
# optional:
TARGET=arm64-apple-macosx11.0 DIST_DIR=./dist ./apps/mac/build.sh
```

The script:

1. Ensures `vendor/ruffle/` exists (downloads from npm if missing).
2. Compiles `main.swift` for `arm64-apple-macosx11.0`.
3. Copies binary, plist, icon, HTML, `web/` tree, and Ruffle into an `.app` bundle.
4. Ad-hoc codesigns (`codesign -s -`) and refreshes Launch Services.

## Icon

Do **not** use `DLMIcon.icns` from the Mac installer — it contains Adobe Dreamweaver’s icon (build-toolchain leftover).

Use `AppIcon.icns`, built from the PC EXE’s icon group (`apps/mac/icon-src/6.ico` = 256×256 Snapmatic camera).

## Controls (end user)

- Esc / Q — quit  
- ⌘Q — quit  
- ⌘H — hide  
- ⌘Tab — switch apps  

A short on-screen hint fades in once at launch (`app-index.html`).
