#!/bin/bash
# Serve web/ on :18765 and open the player in Chrome kiosk (no .app rebuild).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT=18765

PLAYER="$ROOT/apps/mac/app-index.html"
WEB="$ROOT/web"

if lsof -tiTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT already serving; reusing it."
else
  # Staging dir mirrors the .app Resources/web layout.
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
