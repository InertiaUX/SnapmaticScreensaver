# Mac app (Apple Silicon)

AppKit shell for the shared `web/` player.

```
apps/mac/
├── main.swift       App shell
├── Info.plist       Bundle id, ATS for localhost HTTP, icon
├── app-index.html   Ruffle page for WKWebView
├── AppIcon.icns
├── icon-src/        Icons from the PC EXE
└── build.sh         Builds ~/Applications/Snapmatic Screensaver.app
```

Bundle id: `com.rockstargames.screensavers.vsnapmatic.revival`  
Override output with `DIST_DIR=…`.

## Behavior

| Concern | Behavior |
|---------|----------|
| Feed server | `python3 -m http.server` on 18765 if nothing is listening |
| Window | Borderless, main display |
| Focused | `window.level = .screenSaver` (covers menu bar/Dock, no separate Space) |
| Unfocused | `.normal` + `orderBack` so Cmd-Tab/Dock work |
| Quit | Esc or bare Q (local key monitor; WebKit would swallow keys); ⌘Q via menu |
| Cursor | Hidden while active; balanced hide/unhide |

## Build

Needs Xcode CLT / `swiftc`.

```bash
./apps/mac/build.sh
# optional:
TARGET=arm64-apple-macosx11.0 DIST_DIR=./dist ./apps/mac/build.sh
```

`build.sh` ensures Ruffle is present, compiles `main.swift`, assembles the `.app`, ad-hoc codesigns, and refreshes Launch Services.

## Icon

Don't use `DLMIcon.icns` from the Mac installer (Dreamweaver placeholder). `AppIcon.icns` comes from the PC EXE icon group (`apps/mac/icon-src/`).

## Controls

- Esc / Q: quit
- ⌘Q: quit
- ⌘H: hide
- ⌘Tab: switch apps

Launch hint is in `app-index.html`.
