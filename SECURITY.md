# Security Policy

## Supported versions

This project is a volunteer preservation effort. Security fixes are applied on a best-effort basis to the default branch.

## Reporting a vulnerability

Please **do not** open a public issue for security-sensitive reports (for example remote code execution via the local HTTP server or WebView).

Instead, email the maintainer listed on the GitHub repository profile, or open a private [GitHub security advisory](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) if that is enabled for the repo.

Include:

- Affected platform / OS version
- Steps to reproduce
- Impact assessment (local-only vs network-reachable)

## Scope notes

- The Mac app binds a **localhost** HTTP server to serve the Flash player, feed, and photos. Treat unexpected exposure beyond loopback as a bug.
- Vendored [Ruffle](https://ruffle.rs/) issues should generally be reported upstream unless the bug is in our integration.
- Archived Rockstar binaries are historical artifacts; we do not patch the original installers.
