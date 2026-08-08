# apps/mac-saver (experimental)

True `ScreenSaver.framework` module for System Settings → Screen Saver.

```bash
./apps/mac-saver/build.sh
# installs to ~/Library/Screen Savers/Snapmatic.saver

ARCH=universal DIST_DIR=./dist/saver ./apps/mac-saver/build.sh
```

- Fullscreen: WKWebView + Ruffle + in-process localhost feed (port 18765)
- Preview pane: Snapmatic icon only (Ruffle is too heavy there)
- Ad-hoc signed; newer macOS may require Legacy Screen Savers

See [docs/platforms.md](../../docs/platforms.md).
