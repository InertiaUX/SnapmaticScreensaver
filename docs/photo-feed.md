# Photo feed

The SWF never hardcodes photos. It downloads an XML document and then each `<url>`.

## Expected schema

Reconstructed from decompiled `AppBootstrap` / mosaic code and verified against a working local feed:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<snapmaticScreensaver>
  <config>
    <cloudStatus>1</cloudStatus>
    <numCols>5</numCols>
  </config>
  <bitmaps root=""/>
  <css/>
  <fonts/>
  <images>
    <image>
      <url>http://127.0.0.1:18765/photos/example.jpg</url>
      <contentId>00000000</contentId>
    </image>
    <!-- more <image> nodes -->
  </images>
</snapmaticScreensaver>
```

| Field | Meaning |
|-------|---------|
| `cloudStatus` | Must be `1` or the app shows the cloud error path |
| `numCols` | Mosaic column count (original used `5`) |
| `images/image/url` | Absolute HTTP URL Ruffle will fetch |
| `contentId` | Opaque id string; zeros are fine |

Live file:  
`web/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`

The odd `xxxx/` prefix exists so the patched SWF URL stays length-compatible with the original Social Club path.

## Photos

- Directory: `web/photos/`
- Count: ~44 stills today
- Format: JPEG, **640×360** (16:9), matching the mosaic cell size the SWF was built around
- Content: archived GTA V marketing / Newswire / community Snapmatic shots from the 2013–2015 era

The original live Social Club photo CDN was not archived; this pool is a period-accurate substitute. How each batch was found and processed: [sourcing.md](sourcing.md#photos-webphotos).

A higher-resolution reference for the Spijkermat “Buyers Guide” infographic is kept at `archives/GTAV_BuyersGuide_full.jpg` (not necessarily in the mosaic pool at full res).

### Adding photos

1. Drop a JPEG into `web/photos/`.
2. Crop/resize to 640×360 if needed (`sips` on macOS works well).
3. Append an `<image>` block to the XML with the next `contentId`.
4. Rebuild the Mac app (`apps/mac/build.sh`) so the bundle picks up the new files.

## Local server

The Mac app starts:

```text
python3 -m http.server 18765 --bind 127.0.0.1 --directory <bundle>/Contents/Resources/web
```

For feed-only iteration without rebuilding the `.app`, use `scripts/run-browser.sh`.
