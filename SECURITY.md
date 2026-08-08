# Security Policy

Fixes land on the default branch when we can.

## Reporting

Don't open a public issue for security-sensitive bugs (e.g. RCE via the local HTTP server or WebView).

Email the maintainer on the GitHub profile, or use a private [security advisory](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) if enabled.

Include OS/version, repro steps, and whether the issue is localhost-only or network-reachable.

## Scope

- The Mac app serves the player/feed/photos on **localhost**. Exposure beyond loopback is a bug.
- Report Ruffle bugs [upstream](https://ruffle.rs/) unless the issue is our integration.
- We don't patch the archived Rockstar installers.
