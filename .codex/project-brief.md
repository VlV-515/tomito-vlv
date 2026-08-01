# Tomito vlv

Native SwiftUI/AppKit Pomodoro timer for macOS 13+. Version `0.1.0`.

## Product contract

- Visible name: `Tomito vlv`; executable: `Tomito-vlv`.
- Primary experience: one focused timer window plus menu bar controls.
- Default language: English. Preferences offer `🇺🇸 English` and `🇲🇽 Español`.
- Local-only preferences in `UserDefaults`; no accounts, telemetry, or remote APIs.
- Include session/short-break/long-break cycles, notifications, appearance, window behavior, sleep behavior, and a custom About window.
- Exclude history/statistics, widget, sounds, global shortcuts, and AppleScript in v0.1.0.

## Architecture

- `TimerState`: timer lifecycle, phase transitions, notifications, macOS sleep assertion, workspace sleep/wake handling.
- `TimerSettings`: persisted user preferences.
- `AppCopy`: runtime English/Spanish strings.
- `UI/`: SwiftUI main window, preferences, menu-bar content, and About view.
- `scripts/package-app.sh`: builds release, assembles `dist/Tomito vlv.app`, copies resources, signs ad-hoc by default.

Read `AGENTS.md` first. Read `design-system/tomito-vlv/MASTER.md` before visual changes.
