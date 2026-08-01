# Build and package

## Development build

```bash
swift build
```

## App bundle

```bash
./scripts/package-app.sh
open "dist/Tomito vlv.app"
```

## Version override

```bash
APP_VERSION=1.0.1 APP_BUILD=2 ./scripts/package-app.sh
```

## Verify bundle

```bash
plutil -p "dist/Tomito vlv.app/Contents/Info.plist"
codesign --verify --deep --strict "dist/Tomito vlv.app"
```

Packaging creates local files only. It does not push Git, publish a GitHub Release, notarize, or upload to SourceForge.

## Release assets

Create the ZIP and SHA-256 checksum uploaded to GitHub Releases:

```bash
./scripts/package-release.sh 1.1.0
```

Prepare the identical local SourceForge mirror folder without uploading it:

```bash
./scripts/prepare-sourceforge-release.sh 1.1.0
```

See [Release guide](release.md) for the full validation and publishing sequence.
