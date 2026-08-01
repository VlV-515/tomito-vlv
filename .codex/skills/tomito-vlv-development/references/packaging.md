# Packaging reference

Use:

```bash
./scripts/package-app.sh
```

Output: `dist/Tomito vlv.app`.

The script builds release Swift code, copies `Assets/AppIcon.icns`, copies SwiftPM resource bundles, writes `Info.plist`, then signs ad-hoc by default. Set `CODESIGN_IDENTITY` only when the user explicitly provides an approved signing identity.

Verify:

```bash
plutil -p "dist/Tomito vlv.app/Contents/Info.plist"
codesign --verify --deep --strict "dist/Tomito vlv.app"
```
