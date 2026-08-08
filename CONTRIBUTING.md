# Contributing

Thanks for helping keep the Snapmatic Screensaver alive on modern machines.

This is an unofficial fan **preservation** project. Contributions should keep the original mosaic experience working, document provenance honestly, and avoid claiming affiliation with Rockstar or Take-Two.

## Before you start

1. Read [README.md](README.md) and [NOTICE](NOTICE).
2. Skim [docs/architecture.md](docs/architecture.md) and [docs/platforms.md](docs/platforms.md).
3. If you touch archives or media, also read [docs/sourcing.md](docs/sourcing.md).

## Ways to help

| Area | Examples |
|------|----------|
| Platforms | Intel/universal Mac, Windows shell, modern `.saver` |
| Runtime | Ruffle updates, local HTTP server hardening, Esc/focus quirks |
| Feed / photos | More period-accurate stills, better XML coverage, authentic Snapmatic archives if found |
| Docs | Clearer install steps, provenance updates, troubleshooting |
| Packaging | Releases, notarization notes, Windows installers |

## Development quick start (Apple Silicon)

```bash
chmod +x apps/mac/build.sh scripts/*.sh
./apps/mac/build.sh
./scripts/run-mac.sh
```

Browser-only debug (no `.app`):

```bash
./scripts/run-browser.sh
```

## Pull request guidelines

- Prefer small, focused PRs over large mixed dumps.
- Match existing style in the files you touch.
- Do not commit build products (`.app`, `dist/`) — they are gitignored.
- Keep `archives/original/movie.swf` pristine; regenerate `web/movie_local.swf` from it if the config URL changes.
- When adding photos, crop/resize to **640×360**, register them in the local XML feed, and note the source in `docs/sourcing.md` or the PR description.
- Never commit secrets, personal paths, or private credentials.
- Be clear in the PR what is new original code vs archived Rockstar material.

## Legal / attribution reminders

- Do not remove trademark disclaimers from `README.md` or `NOTICE`.
- Do not rebrand this as an official Rockstar product.
- Original Rockstar binaries and art are **not** MIT-licensed — see `LICENSE` and `NOTICE`.
- Prefer citing Wayback / CDX URLs when you add recovered assets.

## Issues

Bug reports are most useful with:

- macOS / Windows version and CPU arch
- Steps to reproduce
- Whether `./scripts/run-browser.sh` also fails
- Relevant console / Ruffle errors

Feature requests should say which platform they target and why the original behavior needs it.
