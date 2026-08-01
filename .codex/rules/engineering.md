# Engineering rules

- Target macOS 13 or newer; use SwiftUI native controls before custom controls.
- Keep timer mutations on `@MainActor`.
- Use `TimerState` for timer behavior and `TimerSettings` for persisted settings. Do not duplicate state in views.
- Give icon-only controls accessibility labels. Preserve tabular timer digits.
- Add user-facing strings through `AppCopy`; default English remains complete when Spanish changes.
- Keep notifications and sleep assertions optional, explainable preferences.
