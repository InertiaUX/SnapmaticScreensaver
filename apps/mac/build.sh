#!/bin/bash
# Build Snapmatic Screensaver.app into ~/Applications (or DIST_DIR). Offline bundle.
# ARCH=arm64|x86_64|universal  (default: arm64)
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
APP_NAME="Snapmatic Screensaver.app"
DIST_DIR="${DIST_DIR:-$HOME/Applications}"
APP="$DIST_DIR/$APP_NAME"
RUFFLE="$ROOT/vendor/ruffle"
ARCH="${ARCH:-arm64}"

case "$ARCH" in
  arm64) TARGET="${TARGET:-arm64-apple-macosx11.0}" ;;
  x86_64|intel) ARCH=x86_64; TARGET="${TARGET:-x86_64-apple-macosx11.0}" ;;
  universal) TARGET="" ;;
  *) echo "Unknown ARCH=$ARCH (use arm64, x86_64, or universal)"; exit 1 ;;
esac

if [ ! -d "$RUFFLE" ] || [ -z "$(ls -A "$RUFFLE"/*.js 2>/dev/null)" ]; then
  echo "Fetching Ruffle into vendor/ruffle..."
  mkdir -p "$RUFFLE"
  TARBALL=$(curl -sL https://registry.npmjs.org/@ruffle-rs/ruffle \
    | python3 -c 'import json,sys; m=json.load(sys.stdin); print(m["versions"][m["dist-tags"]["latest"]]["dist"]["tarball"])')
  curl -sL "$TARBALL" | tar xz -C "$RUFFLE" --strip-components=1
  rm -f "$RUFFLE"/*.map "$RUFFLE"/README.md "$RUFFLE"/LICENSE_* "$RUFFLE"/package.json 2>/dev/null || true
fi

compile_one() {
  local target="$1"
  local out="$2"
  echo "Compiling for $target..."
  swiftc -O -target "$target" -o "$out" "$HERE/main.swift" \
    -framework AppKit -framework WebKit
}

BIN="$HERE/SnapmaticScreensaver"
rm -f "$BIN" "$HERE/SnapmaticScreensaver-arm64" "$HERE/SnapmaticScreensaver-x86_64"

if [ "$ARCH" = "universal" ]; then
  compile_one "arm64-apple-macosx11.0" "$HERE/SnapmaticScreensaver-arm64"
  compile_one "x86_64-apple-macosx11.0" "$HERE/SnapmaticScreensaver-x86_64"
  echo "Creating universal binary..."
  lipo -create -output "$BIN" \
    "$HERE/SnapmaticScreensaver-arm64" "$HERE/SnapmaticScreensaver-x86_64"
  rm -f "$HERE/SnapmaticScreensaver-arm64" "$HERE/SnapmaticScreensaver-x86_64"
else
  compile_one "$TARGET" "$BIN"
fi

echo "Assembling bundle at $APP..."
pkill -f "MacOS/SnapmaticScreensaver" 2>/dev/null || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/web/ruffle"

cp "$BIN" "$APP/Contents/MacOS/"
cp "$HERE/Info.plist" "$APP/Contents/"
cp "$HERE/AppIcon.icns" "$APP/Contents/Resources/"
cp "$HERE/app-index.html" "$APP/Contents/Resources/web/index.html"
cp "$ROOT/web/movie_local.swf" "$APP/Contents/Resources/web/"
cp -R "$ROOT/web/photos" "$ROOT/web/xxxx" "$APP/Contents/Resources/web/"
cp "$RUFFLE"/*.js "$RUFFLE"/*.wasm "$APP/Contents/Resources/web/ruffle/"

codesign --force --deep -s - "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true

echo "Built: $APP ($(lipo -archs "$APP/Contents/MacOS/SnapmaticScreensaver" 2>/dev/null || true))"
echo "Open with: open -a \"$APP\""
