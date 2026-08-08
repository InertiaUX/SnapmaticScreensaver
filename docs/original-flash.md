# Original Flash screensaver

## What shipped (~2013)

1. Small host (`.saver` on Mac, `.exe` on Windows)
2. Embedded `movie.swf` (AS3 photo mosaic)
3. Live Social Club feed:

```
http://{region}.rockstargames.com/social_club/social_club_global_services/snapmaticScreensaver.xml
```

That feed is 404. Wayback has no usable copy of the XML.

## Files here

| Path | Notes |
|------|--------|
| `archives/original/v_snapmatic_mac.zip` | Wayback Mac installer ([sourcing](sourcing.md#installers-mac--pc)) |
| `archives/original/v_snapmatic_pc.zip` | Wayback PC EXE |
| `archives/original/VSnapmaticScreensaverInstaller.app/` | Extracted Mac installer |
| `archives/original/movie.swf` | Unpatched SWF from the `.saver` |
| `web/movie_local.swf` | Same SWF, config host rewritten to `127.0.0.1:18765` |
| `archives/decompiled-source/scripts/` | FFDec AS3 output |

Inside the Mac installer:

```
…/VSnapmaticScreensaver.saver/Contents/Resources/movie.swf
…/Resources/Prefs.xml          # had expirationDate in 2013
…/Resources/DLMIcon.icns       # Dreamweaver leftover, not Snapmatic
```

Real Snapmatic camera icon is in the PC EXE PE resources (`apps/mac/icon-src/`).

## AS3 (decompiled)

Under `com.rockstargames.screensavers.vsnapmatic`:

| Class | Job |
|-------|-----|
| `config/AppConfig.as` | Social Club XML URL template |
| `config/AppBootstrap.as` | Reads `cloudStatus`; mosaic or cloud-error |
| `controllers/MosaicController.as` | Loads image URLs, uses `numCols` |

`cloudStatus` must be truthy or you get the offline/cloud error screen.

## Binary patch (`movie_local.swf`)

The localhost URL is padded with an `xxxx/` segment so its length matches the original string (no binary shift). Keep `archives/original/movie.swf` pristine; regenerate the local SWF if the host/port changes.

## Why Ruffle

Flash Player is dead on modern OS versions. [Ruffle](https://ruffle.rs/) is enough for this SWF (XML + bitmaps). Vendored under `vendor/ruffle/` for offline use.
