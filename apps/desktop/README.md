# apps/desktop

Portable launcher for **Windows** and **Linux** (optional Intel Mac fallback).

Starts a localhost feed server and opens Chrome/Edge/Chromium in app/kiosk mode with the shared Ruffle player.

```bash
./apps/desktop/build.sh
# zips land in dist/desktop/
```

Native Apple Silicon / Intel Mac `.app` builds still use `apps/mac/`. See [docs/platforms.md](../../docs/platforms.md).
