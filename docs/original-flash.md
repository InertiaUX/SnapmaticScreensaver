# Original Flash screensaver

## What shipped in 2013

Rockstar released Mac and PC Snapmatic screensavers that:

1. Installed a small host (`.saver` on Mac, `.exe` on Windows).
2. Embedded **`movie.swf`** — an ActionScript 3 app that drew a scrolling photo mosaic.
3. Fetched live images from Social Club:

```
http://{region}.rockstargames.com/social_club/social_club_global_services/snapmaticScreensaver.xml
```

That feed is long dead (404). Wayback does not have a usable copy of the XML.

## Files in this repo

| Path | Notes |
|------|--------|
| `archives/original/v_snapmatic_mac.zip` | Wayback dump of the Mac installer ([sourcing](sourcing.md#installers-mac--pc)) |
| `archives/original/v_snapmatic_pc.zip` | Wayback dump of the PC EXE |
| `archives/original/VSnapmaticScreensaverInstaller.app/` | Extracted Mac installer |
| `archives/original/movie.swf` | Unpatched SWF from the `.saver` bundle |
| `web/movie_local.swf` | Same SWF with the config host rewritten to `127.0.0.1:18765` |
| `archives/decompiled-source/scripts/` | FFDec output of the AS3 packages |

Useful paths inside the Mac installer:

```
…/VSnapmaticScreensaver.saver/Contents/Resources/movie.swf
…/Resources/Prefs.xml          # had expirationDate in 2013
…/Resources/DLMIcon.icns       # NOT the Snapmatic icon (Dreamweaver leftover)
```

The real Snapmatic camera icon lives in the **PC EXE** PE icon group (`ProductName: Snapmatic Screensaver`). See `apps/mac/icon-src/`.

## AS3 layout (decompiled)

Key packages under `com.rockstargames.screensavers.vsnapmatic`:

| Class | Job |
|-------|-----|
| `config/AppConfig.as` | Builds the Social Club XML URL template |
| `config/AppBootstrap.as` | Reads `cloudStatus`; dispatches mosaic or cloud-error |
| `controllers/MosaicController.as` | Loads `Memory.config.images.image[i].url`, uses `numCols` |

`cloudStatus` must be `1` (or truthy) or the SWF shows a cloud/offline error screen instead of the mosaic.

## Binary patch (`movie_local.swf`)

The original URL string is longer than `127.0.0.1:18765/xxxx/...`. The patch replaces the hostname/path prefix with a same-or-shorter local URL (padding with the `xxxx` segment so length stays valid). Always keep `archives/original/movie.swf` as the pristine copy; regenerate the local SWF from it if you need to change the host again.

## Why Ruffle instead of Adobe Flash

Adobe Flash Player is discontinued and blocked on modern OS versions. [Ruffle](https://ruffle.rs/) reimplements enough AS3 + networking for this SWF to boot, load XML, and draw bitmaps. We vendor the npm `@ruffle-rs/ruffle` build under `vendor/ruffle/` so the app works offline.
