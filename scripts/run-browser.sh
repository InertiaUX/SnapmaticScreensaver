#!/bin/bash
# Dev fallback: serve web/ on port 18765 and open the HTML player in Chrome
# (kiosk). Useful when iterating on the feed/SWF without rebuilding the .app.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT=18765

# Prefer the Mac app's HTML if present; otherwise a minimal local player.
PLAYER="$ROOT/apps/mac/app-index.html"
WEB="$ROOT/web"

if lsof -tiTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT already serving; reusing it."
else
  # Serve from a staging dir that mirrors the bundle layout.
  STAGE=$(mktemp -d)
  cp -R "$WEB/"* "$STAGE/"
  cp "$PLAYER" "$STAGE/index.html"
  mkdir -p "$STAGE/ruffle"
  cp "$ROOT/vendor/ruffle/"*.js "$ROOT/vendor/ruffle/"*.wasm "$STAGE/ruffle/" 2>/dev/null || true
  python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$STAGE" \
    >"$ROOT/scripts/server.log" 2>&1 &
  echo "Started feed server on port $PORT (pid $!)."
  sleep 1
fi

open -na "Google Chrome" --args \
  --user-data-dir="$ROOT/.chrome-profile" \
  --app="http://127.0.0.1:$PORT/index.html" \
  --kiosk --start-fullscreen \
  --no-first-run --no-default-browser-check

echo "Browser player open. Press Cmd+Q in that window to quit."
