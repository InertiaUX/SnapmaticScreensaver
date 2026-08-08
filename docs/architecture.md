# Architecture

How the pieces fit together when you launch the Mac app today.

```
┌─────────────────────────────────────────────────────────────┐
│  Snapmatic Screensaver.app  (AppKit + WKWebView)            │
│                                                             │
│  main.swift                                                 │
│    ├─ starts python3 http.server on 127.0.0.1:18765         │
│    │    serving Contents/Resources/web/                     │
│    ├─ borderless window at screensaver level when focused   │
│    ├─ drops to normal / orderBack on Cmd-Tab                │
│    └─ Esc / Q via NSEvent local monitor                     │
│                                                             │
│  WKWebView → app-index.html                                 │
│                 └─ loads vendored Ruffle                    │
│                        └─ plays movie_local.swf             │
│                               │                             │
│                               ▼                             │
│                   GET /xxxx/.../snapmaticScreensaver.xml    │
│                   GET /photos/*.jpg                         │
└─────────────────────────────────────────────────────────────┘
```

## Data flow

1. App launches → spawn local HTTP server rooted at the bundled `web/` tree.
2. WebView loads `index.html` (from `apps/mac/app-index.html`).
3. Ruffle boots and loads `movie_local.swf`.
4. The SWF requests its XML config from the patched URL  
   `http://127.0.0.1:18765/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`.
5. XML says `cloudStatus=1` and lists image URLs under `/photos/…`.
6. Mosaic controller fills a 5-column grid and animates like the 2013 original.

## Why a local server?

The SWF was written for HTTP URLs (Social Club CDN). Ruffle still does network loads for those URLs. Serving from `127.0.0.1` keeps behavior close to the original without needing Rockstar’s servers.

Port **18765** is fixed in three places today:

- `apps/mac/main.swift` (`let port = 18765`)
- `web/xxxx/.../snapmaticScreensaver.xml` (every `<url>`)
- The binary string patch inside `web/movie_local.swf`

If you change the port, update all three (or write a small regen script).

## Shared vs per-platform

| Path | Role |
|------|------|
| `web/` | Shared by every future target (Mac Intel, Windows, browser demo) |
| `vendor/ruffle/` | Shared Flash runtime |
| `apps/mac/` | Apple Silicon shell only |
| `apps/mac-intel/`, `apps/windows/`, `apps/mac-saver/` | Planned — see [platforms.md](platforms.md) |

## What we deliberately did *not* rewrite

The mosaic UI, column math, and load/error states still come from Rockstar’s ActionScript. A pure HTML remake (`mosaic.html`) was prototyped during revival and discarded for authenticity — the goal is the original SWF, not a clone.
