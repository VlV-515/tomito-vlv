# Release rules

- Version starts at `0.1.0`; pass a new version only with `APP_VERSION=x.y.z ./scripts/package-app.sh`.
- Verify from repository root:

```bash
swift build
./scripts/package-app.sh
plutil -p "dist/Tomito vlv.app/Contents/Info.plist"
codesign --verify --deep --strict "dist/Tomito vlv.app"
```

- A local `dist/` bundle is not a GitHub or SourceForge release.
- GitHub push, GitHub Release, signing with a Developer ID, notarization, and SourceForge publication require separate user authorization.
