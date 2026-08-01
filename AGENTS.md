# Tomito vlv agent guide

Use `caveman` in `ultra` mode for every response in this repository.

## Scope

Tomito vlv is a native macOS Pomodoro timer. Keep product copy, source names, documentation, and commits in English. The app itself starts in English and offers English and Spanish in Preferences.

## Commands

```bash
swift build
./scripts/package-app.sh
open "dist/Tomito vlv.app"
```

Do not launch the GUI unless the user asks. Never use `ng serve`; this is a SwiftPM project.

## Boundaries

- Keep the app local-first. Do not add analytics, accounts, tracking, or network dependencies.
- Do not add history/statistics, timer widget, sounds, global shortcuts, or AppleScript unless explicitly requested.
- Keep the sleep assertion active only while a running timer has `keepMacAwake` enabled.
- Preserve visible `Tomito vlv` and technical executable `Tomito-vlv` names.
- `dist/` and `.build/` are generated. Do not commit them.

## Validation and commits

- Build with `swift build` after source changes.
- Run `./scripts/package-app.sh`, inspect `Info.plist`, and run `codesign --verify --deep --strict` before claiming bundle validation.
- Treat a successful build as code validation, not GUI validation. State manual visual limitations plainly.
- Make focused local commits after completed stages. Do not push, publish a release, or create a SourceForge project without explicit authorization.
