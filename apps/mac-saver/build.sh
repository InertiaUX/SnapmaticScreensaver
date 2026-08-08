#!/bin/bash
# Build experimental Snapmatic.saver into ~/Library/Screen Savers (or DIST_DIR).
# ARCH=arm64|x86_64|universal  (default: arm64)
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
NAME="Snapmatic.saver"
DIST_DIR="${DIST_DIR:-$HOME/Library/Screen Savers}"
SAVER="$DIST_DIR/$NAME"
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
  echo "Compiling saver for $target..."
  # Screen savers are Mach-O bundles loaded by ScreenSaverEngine.
  swiftc -O -target "$target" \
    -emit-library -o "$out" \
    "$HERE/SnapmaticView.swift" \
    -framework ScreenSaver -framework WebKit -framework AppKit -framework Network \
    -Xlinker -bundle
}

BIN="$HERE/Snapmatic"
rm -f "$BIN" "$HERE/Snapmatic-arm64" "$HERE/Snapmatic-x86_64"

if [ "$ARCH" = "universal" ]; then
  compile_one "arm64-apple-macosx11.0" "$HERE/Snapmatic-arm64"
  compile_one "x86_64-apple-macosx11.0" "$HERE/Snapmatic-x86_64"
  lipo -create -output "$BIN" "$HERE/Snapmatic-arm64" "$HERE/Snapmatic-x86_64"
  rm -f "$HERE/Snapmatic-arm64" "$HERE/Snapmatic-x86_64"
else
  compile_one "$TARGET" "$BIN"
fi

echo "Assembling $SAVER..."
mkdir -p "$DIST_DIR"
rm -rf "$SAVER"
mkdir -p "$SAVER/Contents/MacOS" "$SAVER/Contents/Resources/web/ruffle"

cp "$BIN" "$SAVER/Contents/MacOS/Snapmatic"
cp "$HERE/Info.plist" "$SAVER/Contents/"
cp "$HERE/index.html" "$SAVER/Contents/Resources/web/index.html"
cp "$ROOT/web/movie_local.swf" "$SAVER/Contents/Resources/web/"
cp -R "$ROOT/web/photos" "$ROOT/web/xxxx" "$SAVER/Contents/Resources/web/"
cp "$RUFFLE"/*.js "$RUFFLE"/*.wasm "$SAVER/Contents/Resources/web/ruffle/"
cp "$ROOT/apps/mac/icon-src/snapmatic-256.png" "$SAVER/Contents/Resources/"

codesign --force --deep -s - "$SAVER"

echo "Built: $SAVER ($(lipo -archs "$SAVER/Contents/MacOS/Snapmatic" 2>/dev/null || true))"
echo "Experimental. Open System Settings → Screen Saver and choose Snapmatic."
echo "On newer macOS you may need Legacy Screen Savers enabled."
