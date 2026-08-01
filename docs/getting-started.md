# Install and run

## From source

Requirements: macOS 13+, Xcode Command Line Tools, and Swift 5.9 or newer.

```bash
swift build
./scripts/package-app.sh
open "dist/Tomito vlv.app"
```

The executable is `Tomito-vlv`. The visible app name is `Tomito vlv`.

macOS may show a first-run warning because v1.1.0 is ad-hoc signed and not notarized. This bundle is intended for local use.
