#!/bin/bash
# Build portable Snapmatic packages for windows-amd64 and linux-amd64 (and optional darwin-amd64).
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="${OUT:-$ROOT/dist/desktop}"
RUFFLE="$ROOT/vendor/ruffle"
VERSION="${VERSION:-1.1}"

if [ ! -d "$RUFFLE" ] || [ -z "$(ls -A "$RUFFLE"/*.js 2>/dev/null)" ]; then
  echo "Fetching Ruffle into vendor/ruffle..."
  mkdir -p "$RUFFLE"
  TARBALL=$(curl -sL https://registry.npmjs.org/@ruffle-rs/ruffle \
    | python3 -c 'import json,sys; m=json.load(sys.stdin); print(m["versions"][m["dist-tags"]["latest"]]["dist"]["tarball"])')
  curl -sL "$TARBALL" | tar xz -C "$RUFFLE" --strip-components=1
  rm -f "$RUFFLE"/*.map "$RUFFLE"/README.md "$RUFFLE"/LICENSE_* "$RUFFLE"/package.json 2>/dev/null || true
fi

stage_web() {
  local dest="$1"
  mkdir -p "$dest/ruffle"
  cp "$HERE/index.html" "$dest/index.html"
  cp "$ROOT/web/movie_local.swf" "$dest/"
  cp -R "$ROOT/web/photos" "$ROOT/web/xxxx" "$dest/"
  cp "$RUFFLE"/*.js "$RUFFLE"/*.wasm "$dest/ruffle/"
}

write_readme() {
  local dest="$1"
  local platform="$2"
  cat > "$dest/README.txt" <<EOF
Snapmatic Screensaver v${VERSION} (${platform})
Open source by Inertia - https://github.com/InertiaUX/SnapmaticScreensaver

Unofficial revival. Not affiliated with Rockstar Games or Take-Two.

Run
----
Windows: double-click SnapmaticScreensaver.exe
Linux:   ./SnapmaticScreensaver

Needs a Chromium-based browser (Chrome, Edge, Chromium, Brave) for fullscreen
app mode. Falls back to your default browser if none are found.

Quit: close the browser window, or Ctrl+C in the terminal.

See NOTICE in the source repo for licensing of Rockstar assets.
EOF
}

build_one() {
  local goos="$1"
  local goarch="$2"
  local label="$3"
  local bin="SnapmaticScreensaver"
  if [ "$goos" = "windows" ]; then
    bin="SnapmaticScreensaver.exe"
  fi

  local dir="$OUT/Snapmatic-Screensaver-${VERSION}-${label}"
  rm -rf "$dir"
  mkdir -p "$dir/web"

  echo "Building $label..."
  (cd "$HERE" && GOOS="$goos" GOARCH="$goarch" CGO_ENABLED=0 \
    go build -trimpath -ldflags="-s -w" -o "$dir/$bin" .)

  stage_web "$dir/web"
  write_readme "$dir" "$label"

  (cd "$OUT" && zip -qr "Snapmatic-Screensaver-${VERSION}-${label}.zip" "Snapmatic-Screensaver-${VERSION}-${label}")
  echo "Wrote $OUT/Snapmatic-Screensaver-${VERSION}-${label}.zip"
}

mkdir -p "$OUT"
build_one windows amd64 windows-amd64
build_one linux amd64 linux-amd64
# Optional Intel Mac portable launcher (native .app is preferred; see apps/mac)
if [ "${INCLUDE_DARWIN_AMD64:-0}" = "1" ]; then
  build_one darwin amd64 darwin-amd64
fi

echo "Done. Packages in $OUT"
ls -lh "$OUT"/*.zip
