<p align="center">
  <img src="Assets/AppIcon-source.png" width="144" alt="Tomito vlv app icon">
</p>

<h1 align="center">Tomito vlv</h1>

<p align="center">A calmer, open-source Pomodoro timer for macOS.</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13%2B-0f172a?logo=apple&logoColor=white" alt="macOS 13 or later">
  <img src="https://img.shields.io/badge/version-0.1.0-dc2626" alt="Version 0.1.0">
  <img src="https://img.shields.io/badge/license-MIT-059669" alt="MIT License">
</p>

Tomito vlv keeps Pomodoro focused: a beautiful timer, useful breaks, menu-bar controls, and no clutter. It is local-first, private by design, and yours to inspect or improve.

## Why Tomito vlv?

- **Focused by default** — Sessions, short breaks, and long breaks without history dashboards, widgets, sounds, or distractions.
- **Mac-aware** — Optional notifications, sleep/wake behavior, and a power assertion that keeps your Mac awake while a timer runs.
- **Bilingual** — Starts in English. Switch to `🇺🇸 English` or `🇲🇽 Español` from Preferences.
- **Native and open** — SwiftUI + AppKit, no accounts, no analytics, no network dependency.

## Included in v0.1.0

| Area | What you get |
| --- | --- |
| Timer | Start, pause, resume, stop, restart, skip; session, short-break, and long-break cycles |
| Automation | Configurable durations, long-break interval, automatic session/break starts |
| macOS | Menu-bar controls, local notifications, optional window behavior |
| Sleep | Keep Mac awake while active; pause on sleep; optionally resume on wake |
| Appearance | System, light, or dark mode; tomato or forest accent |
| Language | English default plus Spanish selector with country flags |
| About | App icon, v0.1.0, GitHub and SourceForge project links |

Not included: history/statistics, timer widget, sounds, global shortcuts, AppleScript, analytics, or accounts.

## Run it

```bash
swift build
./scripts/package-app.sh
open "dist/Tomito vlv.app"
```

The app bundle is ad-hoc signed for local use. It is not notarized or released to GitHub/SourceForge yet.

## Links

- [GitHub repository](https://github.com/VlV-515/tomito-vlv)
- [SourceForge project URL](https://sourceforge.net/projects/tomito-vlv/)
- [User documentation](docs/README.md)
- [Contributor guide](AGENTS.md)

## License

MIT. See [LICENSE](LICENSE).
