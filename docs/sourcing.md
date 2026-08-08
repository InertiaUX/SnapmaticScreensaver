# Sourcing & provenance

Where each asset came from. Useful for re-download, citation, or extending the archive.

## Starting point

Newswire (download buttons broken as of 2026):

https://www.rockstargames.com/newswire/article/89k8a554595772/the-snapmatic-screensaver.html

Archived HTML does not embed the installer URLs (injected via JS). Paths recovered from period `media.rockstargames.com` layout and confirmed in Wayback CDX:

```
http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_mac.zip
http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_pc.zip
```

Both are 404 live.

## Installers (Mac + PC)

| Asset | Wayback timestamp | Notes |
|-------|-------------------|--------|
| `archives/original/v_snapmatic_mac.zip` | `20141112213215` | Installer → `.saver` + `movie.swf` |
| `archives/original/v_snapmatic_pc.zip` | `20150915134808` | `snapmatic-screensaver.exe` |

Raw Wayback downloads (`id_` = no toolbar):

```
https://web.archive.org/web/20141112213215id_/http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_mac.zip
https://web.archive.org/web/20150915134808id_/http://media.rockstargames.com/rockstargames/img/global/downloads/screensavers/games/v_snapmatic_pc.zip
```

Method: CDX API on those URLs → pick a `200` snapshot → download with `id_`.

Extracted Mac tree: `archives/original/VSnapmaticScreensaverInstaller.app/`. Unpatched SWF: `archives/original/movie.swf`.

## `movie.swf` / ActionScript

| Step | Detail |
|------|--------|
| In installer | `…/VSnapmaticScreensaver.saver/Contents/Resources/movie.swf` |
| Decompiler | [FFDec 26.2.1](https://github.com/jindrapetrik/jpexs-decompiler) |
| Output | `archives/decompiled-source/scripts/` |
| Why | Only way to learn feed schema / `cloudStatus` gate |

Useful classes:

- `config/AppConfig.as`: URL template `http://%s.rockstargames.com/social_club/.../snapmaticScreensaver.xml`
- `config/AppBootstrap.as`: requires truthy `cloudStatus`
- `controllers/MosaicController.as`: loads `images.image[i].url`, uses `numCols`

### Binary patch → `web/movie_local.swf`

1. Decompress SWF body (zlib).
2. Find the config URL string.
3. Replace with equal-length localhost URL  
   `http://127.0.0.1:18765/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`  
   (`xxxx/` pads length).
4. Recompress → `web/movie_local.swf`.

Keep `archives/original/movie.swf` pristine.

## Social Club XML feed

Live path: 404. Wayback: no usable body.

Rebuilt from decompiled schema ([photo-feed.md](photo-feed.md)):

`web/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`

Reconstruction, not a recovered Rockstar document.

## Photos (`web/photos/`)

Original screensaver used live Social Club Snapmatic uploads. That CDN was not usefully archived.

Substitute: Rockstar Newswire / marketing JPEGs (~2013-2015) from `media.rockstargames.com` via Wayback CDX, downloaded with `id_` URLs.

| Pattern | Origin |
|---------|--------|
| `GTAV_fan-pics_20-01-14_*.jpg` | Fan Snapmatic roundup Newswire assets |
| `*_gtavpc_03272015.jpg`, `gtav02272015_*.jpg` | PC / update screenshots |
| `gtav_details09122014_*.jpg` | Marketing stills |
| `GTAV_Beach_Bum_Screen_*.jpg` | Beach Bum update |

Processing: download → drop logos/flyer/box-art → center-crop 16:9 → resize to **640x360** with `sips` (mosaic cells expect that size; larger images only show a corner) → register in XML.

`archives/GTAV_BuyersGuide_full.jpg`: sharper Buyers Guide reference (Newswire thumb was soft). Mosaic may still use the 640x360 crop.

## App icon

| Candidate | Verdict |
|-----------|---------|
| Mac `DLMIcon.icns` | Wrong (Dreamweaver "Dw" placeholder) |
| Mac `installer.icns` | Generic installer art |
| `.saver` `thumbnail.png` | 90x58 preview only |
| **PC EXE PE icons** | Correct (`ProductName: Snapmatic Screensaver`) |

1. Unzip PC zip → `snapmatic-screensaver.exe`
2. 7-Zip: `.rsrc/1033/ICON/1.ico` … `6.ico` (16→256 px)
3. `iconutil` → `apps/mac/AppIcon.icns` (upscale only for 512/1024)
4. Sources stay in `apps/mac/icon-src/`

## Ruffle

| Item | Source |
|------|--------|
| Package | npm `@ruffle-rs/ruffle` |
| Vendored | `vendor/ruffle/` |
| Why vendor | Offline play; no CDN at runtime |
| License | Apache-2.0 / MIT (https://ruffle.rs/) |

`build.sh` fetches from npm if missing. Desktop Ruffle hit macOS sandbox / OpenH264 dialogs; WebView path is what we use.

## Mac shell (`apps/mac/`)

New Swift + AppKit + WKWebView code (not Rockstar). The 2013 `.saver` is Intel Flash ScreenTime and useless on Apple Silicon as a system screensaver. A real `.app` gives Dock/Spotlight, Esc/⌘Q, and Cmd-Tab without Chrome kiosk hacks.

## Tools

| Tool | Role |
|------|------|
| Wayback + CDX | Installers + Newswire JPEGs |
| FFDec | Decompile AS3 |
| Python zlib patch | Rewrite SWF config URL |
| `sips` | Crop/resize to 640x360 |
| 7-Zip | Icons from PC EXE |
| `iconutil` / `codesign` | `.icns` + ad-hoc sign |
| Ruffle | Flash in WKWebView |

## Still missing

- Original live Social Club XML body
- Exact 2013-14 Snapmatic photo set
- Redistribution license from Rockstar ([NOTICE](../NOTICE))

If you find a better feed or authentic Snapmatic uploads, drop them in `web/` and update the XML. The SWF only cares that the schema matches.
