# Architecture

```
Snapmatic Screensaver.app (AppKit + WKWebView)
  main.swift
    - python3 http.server on 127.0.0.1:18765 → Contents/Resources/web/
    - borderless window at screensaver level when focused
    - drops to normal / orderBack on Cmd-Tab
    - Esc / Q via NSEvent local monitor
  WKWebView → index.html → Ruffle → movie_local.swf
      → GET /xxxx/.../snapmaticScreensaver.xml
      → GET /photos/*.jpg
```

## Data flow

1. App spawns a local HTTP server from the bundled `web/` tree.
2. WebView loads `index.html` (from `apps/mac/app-index.html`).
3. Ruffle loads `movie_local.swf`.
4. SWF fetches `http://127.0.0.1:18765/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`.
5. XML has `cloudStatus=1` and image URLs under `/photos/`.
6. Mosaic fills a 5-column grid like the 2013 original.

## Why a local server?

The SWF expects HTTP URLs. Serving from `127.0.0.1` keeps that behavior without Rockstar's servers.

Port **18765** is hard-coded in:

- `apps/mac/main.swift`
- `web/xxxx/.../snapmaticScreensaver.xml`
- the string patch inside `web/movie_local.swf`

Change the port in all three (or regen the SWF).

## Shared vs per-platform

| Path | Role |
|------|------|
| `web/` | Shared runtime (all targets) |
| `vendor/ruffle/` | Shared Flash runtime |
| `apps/mac/` | Apple Silicon shell |
| `apps/mac-intel/`, `apps/windows/`, `apps/mac-saver/` | Planned ([platforms.md](platforms.md)) |

Mosaic UI stays in Rockstar's ActionScript. A HTML remake was tried and dropped; the goal is the original SWF.
