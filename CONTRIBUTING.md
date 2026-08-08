# Contributing

Unofficial fan preservation project. Keep the original mosaic working, document provenance, and don't claim Rockstar/Take-Two affiliation.

## Before you start

1. [README.md](README.md) and [NOTICE](NOTICE)
2. [docs/architecture.md](docs/architecture.md), [docs/platforms.md](docs/platforms.md)
3. Archives or media: [docs/sourcing.md](docs/sourcing.md)

## Useful work

| Area | Examples |
|------|----------|
| Platforms | Intel/universal Mac, Windows shell, modern `.saver` |
| Runtime | Ruffle updates, localhost server, Esc/focus quirks |
| Feed / photos | Period stills, XML coverage, authentic Snapmatic archives |
| Docs | Install steps, provenance, troubleshooting |
| Packaging | Releases, notarization notes, Windows installers |

## Dev (Apple Silicon)

```bash
chmod +x apps/mac/build.sh scripts/*.sh
./apps/mac/build.sh
./scripts/run-mac.sh
```

Feed/SWF without rebuilding the app: `./scripts/run-browser.sh`

## Pull requests

- Keep PRs focused; match style in touched files.
- Don't commit build products (`.app`, `dist/`).
- Leave `archives/original/movie.swf` pristine; regenerate `web/movie_local.swf` if the config URL changes.
- New photos: 640x360, register in the XML feed, note the source in `docs/sourcing.md` or the PR.
- Say what is new code vs archived Rockstar material.
- Don't strip trademark disclaimers or rebrand as official Rockstar.

## Bug reports

Include OS/arch, how you ran it (`apps/mac` vs browser script), steps, and whether `./scripts/run-browser.sh` fails too.
