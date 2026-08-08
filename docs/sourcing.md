# Sourcing & provenance

How each piece of this revival was found. Useful if you need to re-download, cite, or extend the archive.

## Starting point

Live Newswire article (download buttons broken as of 2026):

https://www.rockstargames.com/newswire/article/89k8a554595772/the-snapmatic-screensaver.html

Archived HTML of that page does **not** embed the installer URLs — Rockstar’s front-end injected them via JS. We recovered the real download paths from period references / Rockstar’s old `media.rockstargames.com` layout, then confirmed them in the Wayback CDX index.

Original CDN paths (both now **404** live):

```
http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_mac.zip
http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_pc.zip
```

---

## Installers (Mac + PC)

| Asset in repo | Wayback capture used | Notes |
|---------------|----------------------|--------|
| `archives/original/v_snapmatic_mac.zip` | `20141112213215` | Mac installer app → embeds `.saver` + `movie.swf` |
| `archives/original/v_snapmatic_pc.zip` | `20150915134808` | Contains `snapmatic-screensaver.exe` |

**Direct Wayback “id_” links** (raw bytes, no Wayback toolbar):

```
https://web.archive.org/web/20141112213215id_/http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_mac.zip

https://web.archive.org/web/20150915134808id_/http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_pc.zip
```

**Method:** Wayback CDX API (`web.archive.org/cdx/search/cdx`) filtered on those exact URLs; pick a `200` snapshot; download with the `id_` modifier.

Extracted Mac tree lives at `archives/original/VSnapmaticScreensaverInstaller.app/`. Unpatched SWF copied to `archives/original/movie.swf`.

---

## `movie.swf` / ActionScript

| Step | Detail |
|------|--------|
| Location in installer | `…/VSnapmaticScreensaver.saver/Contents/Resources/movie.swf` |
| Decompiler | [JPEXS Free Flash Decompiler (FFDec) 26.2.1](https://github.com/jindrapetrik/jpexs-decompiler) |
| Output | `archives/decompiled-source/scripts/` |
| Why | Live Social Club XML is gone; AS3 was the only way to learn the exact feed schema and `cloudStatus` gate |

Important classes we used:

- `config/AppConfig.as` — URL template `http://%s.rockstargames.com/social_club/.../snapmaticScreensaver.xml`
- `config/AppBootstrap.as` — requires `cloudStatus` truthy or shows cloud error
- `controllers/MosaicController.as` — loads `images.image[i].url`, uses `numCols`

### Binary patch → `web/movie_local.swf`

The SWF is zlib-compressed Flash. We:

1. Decompressed the SWF body.
2. Located the config URL string.
3. Replaced it with an **equal-length** localhost URL  
   `http://127.0.0.1:18765/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`  
   (the `xxxx/` segment pads length so we don’t shift the binary).
4. Recompressed and wrote `web/movie_local.swf`.

Always keep `archives/original/movie.swf` pristine; regenerate the local copy from it if the host/port changes.

---

## Social Club XML feed

| Attempt | Result |
|---------|--------|
| Live `*.rockstargames.com/.../snapmaticScreensaver.xml` | 404 |
| Wayback CDX for that path | No usable archived body |

**What we did instead:** rebuild the feed from the decompiled schema (see [photo-feed.md](photo-feed.md)). File in repo:

`web/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`

This is a **reconstruction**, not a recovered Rockstar document. Structure matches what the SWF expects; image URLs point at our local photo pool.

---

## Photos (`web/photos/`)

The original screensaver pulled **live Social Club Snapmatic uploads**. Those user-photo CDNs were not usefully archived, so we could not restore the exact 2013 mosaic pool.

**Substitute used:** period Rockstar Newswire / marketing JPEGs of GTA V (in-game stills, fan-pic roundups, update screenshots) from `media.rockstargames.com`, discovered via Wayback CDX (`*.jpg` under GTA V–related paths, ~2013–2015), then downloaded with `id_` URLs.

Filename patterns in the pool today reflect those article sets, for example:

| Pattern | Typical origin |
|---------|----------------|
| `GTAV_fan-pics_20-01-14_*.jpg` | Community / fan Snapmatic roundup Newswire assets |
| `*_gtavpc_03272015.jpg`, `gtav02272015_*.jpg` | PC / update screenshot sets |
| `gtav_details09122014_*.jpg` | “Details” style marketing stills |
| `GTAV_Beach_Bum_Screen_*.jpg` | Beach Bum update screenshots |

### Processing

1. Download raw JPEGs from Wayback.
2. Drop logos / flyer / box-art style assets (aspect or content filters).
3. Center-crop to 16:9 and resize to **exactly 640×360** with macOS `sips` — the mosaic cells are built around that size; larger images would only show a corner if left unscaled.
4. Register each file in the local XML feed.

### High-res buyers-guide still

`archives/GTAV_BuyersGuide_full.jpg` is a sharper copy of the Spijkermat-style GTA Online “Buyers Guide” infographic that appeared in the fan-pics set (`GTAV_fan-pics_20-01-14_6`). Sourced from the creator’s archived site after the Newswire thumbnail proved too soft; kept as a reference asset (mosaic copy in `web/photos/` may still be the 640×360 crop).

---

## App icon

| Candidate | Verdict |
|-----------|---------|
| Mac installer `DLMIcon.icns` | **Wrong** — contains Adobe Dreamweaver’s “Dw” icon (build-toolchain placeholder shipped in 2013) |
| Mac installer `installer.icns` | Generic installer art, not Snapmatic |
| `.saver` `thumbnail.png` | Tiny System Preferences preview (90×58), not app-icon quality |
| **PC EXE PE icons** | **Correct** — `CompanyName: Rockstar Games`, `ProductName: Snapmatic Screensaver` |

**Method:**

1. Unzip `v_snapmatic_pc.zip` → `snapmatic-screensaver.exe`.
2. Extract with 7-Zip: `.rsrc/1033/ICON/1.ico` … `6.ico` (16→256 px).
3. Build `apps/mac/AppIcon.icns` via `iconutil` from those native sizes (upscale only for 512/1024 Retina slots).
4. Keep sources in `apps/mac/icon-src/`.

That yellow camera is the in-game iFruit / Snapmatic app icon aesthetic from GTA V.

---

## Ruffle (Flash runtime)

| Item | Source |
|------|--------|
| Package | npm `@ruffle-rs/ruffle` |
| Vendored copy | `vendor/ruffle/` (JS + WASM) |
| Why vendor | App must run offline; no CDN dependency at play time |
| License | Apache-2.0 / MIT — https://ruffle.rs/ |

`apps/mac/build.sh` re-fetches from npm if `vendor/ruffle/` is missing.

Desktop Ruffle was tried first for the raw SWF; macOS sandbox / OpenH264 permission dialogs made the browser/WebView path more reliable, which is what the Mac app uses today.

---

## Mac app shell (`apps/mac/`)

Written for this project (Swift + AppKit + WKWebView). Not from Rockstar.

It exists because:

- The 2013 `.saver` is Intel Flash ScreenTime — unusable on modern Apple Silicon macOS as a system screensaver.
- Wrapping Ruffle + local feed in a real `.app` gives Dock/Spotlight launch, Esc/⌘Q, and Cmd-Tab without Chrome kiosk hacks.

Icon, SWF, photos, and feed are the archived/reconstructed pieces; the windowing and HTTP server are new.

---

## Tools used during revival

| Tool | Role |
|------|------|
| Wayback Machine + CDX API | Find and download installers + Newswire JPEGs |
| FFDec (JPEXS) | Decompile `movie.swf` AS3 |
| Python `zlib` patch script | Rewrite config URL inside SWF |
| `sips` | Crop/resize photos to 640×360 |
| 7-Zip | Pull `.ico` resources from the PC EXE |
| `iconutil` / `codesign` | Build `.icns`, ad-hoc sign the `.app` |
| Ruffle | Emulate Flash in WKWebView |

---

## What we still do **not** have

- The original live Social Club XML body (never archived).
- The exact set of user Snapmatic photos the screensaver showed in 2013–14.
- A signed Rockstar redistribution license — treat binaries/art as research/preservation only ([NOTICE](../NOTICE)).

If you find a better archive of the Social Club feed or authentic Snapmatic uploads from that era, drop them into `web/` and update the XML — the SWF does not care where the JPEGs originally came from, only that the schema matches.
