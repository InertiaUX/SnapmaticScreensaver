#!/bin/bash
# Build if needed, then launch the Mac app.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$HOME/Applications/Snapmatic Screensaver.app"

if [ ! -x "$APP/Contents/MacOS/SnapmaticScreensaver" ]; then
  "$ROOT/apps/mac/build.sh"
fi

open -a "$APP"
echo "Running. Esc or Q to quit. Cmd-Tab to switch apps."
