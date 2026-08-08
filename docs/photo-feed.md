# Photo feed

The SWF downloads XML, then each `<url>`.

## Schema

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
  </images>
</snapmaticScreensaver>
```

| Field | Meaning |
|-------|---------|
| `cloudStatus` | Must be `1` or cloud-error path |
| `numCols` | Mosaic columns (original used `5`) |
| `images/image/url` | Absolute HTTP URL |
| `contentId` | Opaque id; zeros are fine |

Live file: `web/xxxx/social_club/social_club_global_services/snapmaticScreensaver.xml`

The `xxxx/` prefix keeps the patched SWF URL length-compatible with the original path.

## Photos

- `web/photos/` (~44 JPEGs)
- **640x360** (16:9); matches mosaic cell size
- Period GTA V Newswire / marketing stills (2013-2015). Live Social Club Snapmatic CDN was not archived. See [sourcing.md](sourcing.md#photos-webphotos).

Reference: `archives/GTAV_BuyersGuide_full.jpg` (higher-res Buyers Guide still).

### Adding photos

1. Drop a JPEG into `web/photos/`.
2. Crop/resize to 640x360 (`sips` on macOS).
3. Append an `<image>` block to the XML.
4. Rebuild: `./apps/mac/build.sh`.

## Local server

```text
python3 -m http.server 18765 --bind 127.0.0.1 --directory <bundle>/Contents/Resources/web
```

Iterate without rebuilding: `scripts/run-browser.sh`.
