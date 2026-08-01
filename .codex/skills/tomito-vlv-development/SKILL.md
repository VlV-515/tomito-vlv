---
name: tomito-vlv-development
description: Build, change, package, or validate the native macOS Pomodoro app Tomito vlv. Use for SwiftUI timer behavior, menu-bar controls, preferences, English/Spanish copy, sleep prevention, About content, app icon resources, or macOS release packaging in this repository.
---

# Tomito vlv development

Read `AGENTS.md`, `.codex/project-brief.md`, and `design-system/tomito-vlv/MASTER.md` before changing code.

## Work flow

1. Inspect current diff. Preserve user changes outside request scope.
2. Keep source and documentation English. Route UI copy through `AppCopy`.
3. Use native SwiftUI controls, system symbols, semantic labels, and 4/8-point spacing.
4. For timer behavior, change `TimerState`; for persisted preferences, change `TimerSettings`.
5. Build with `swift build`.
6. If packaging changes, read `references/packaging.md`, package, inspect bundle metadata, and verify codesign.
7. Commit focused validated stages. Do not push or publish without explicit approval.

## Product limits

Do not add history/statistics, a timer widget, sounds, global shortcuts, AppleScript, analytics, accounts, or remote services unless the user explicitly expands scope.

## Visual checks

Build success does not prove macOS visual behavior. When requested, manually check start/pause/skip, menu-bar actions, language toggle, preferences persistence, sleep prevention, and About links.
