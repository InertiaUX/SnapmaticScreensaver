#!/bin/bash
# Build Snapmatic Screensaver.app into ~/Applications (or DIST_DIR). Offline bundle.
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
APP_NAME="Snapmatic Screensaver.app"
DIST_DIR="${DIST_DIR:-$HOME/Applications}"
APP="$DIST_DIR/$APP_NAME"
RUFFLE="$ROOT/vendor/ruffle"
TARGET="${TARGET:-arm64-apple-macosx11.0}"

if [ ! -d "$RUFFLE" ] || [ -z "$(ls -A "$RUFFLE"/*.js 2>/dev/null)" ]; then
  echo "Fetching Ruffle into vendor/ruffle..."
  mkdir -p "$RUFFLE"
  TARBALL=$(curl -sL https://registry.npmjs.org/@ruffle-rs/ruffle \
    | python3 -c 'import json,sys; m=json.load(sys.stdin); print(m["versions"][m["dist-tags"]["latest"]]["dist"]["tarball"])')
  curl -sL "$TARBALL" | tar xz -C "$RUFFLE" --strip-components=1
  rm -f "$RUFFLE"/*.map "$RUFFLE"/README.md "$RUFFLE"/LICENSE_* "$RUFFLE"/package.json 2>/dev/null || true
fi

echo "Compiling for $TARGET..."
swiftc -O -target "$TARGET" -o "$HERE/SnapmaticScreensaver" "$HERE/main.swift" \
  -framework AppKit -framework WebKit

echo "Assembling bundle at $APP..."
pkill -f "MacOS/SnapmaticScreensaver" 2>/dev/null || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/web/ruffle"

cp "$HERE/SnapmaticScreensaver" "$APP/Contents/MacOS/"
cp "$HERE/Info.plist" "$APP/Contents/"
cp "$HERE/AppIcon.icns" "$APP/Contents/Resources/"
cp "$HERE/app-index.html" "$APP/Contents/Resources/web/index.html"
cp "$ROOT/web/movie_local.swf" "$APP/Contents/Resources/web/"
cp -R "$ROOT/web/photos" "$ROOT/web/xxxx" "$APP/Contents/Resources/web/"
cp "$RUFFLE"/*.js "$RUFFLE"/*.wasm "$APP/Contents/Resources/web/ruffle/"

codesign --force --deep -s - "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true

echo "Built: $APP"
echo "Open with: open -a \"$APP\""
