# Release guide

GitHub Releases are the primary release channel. SourceForge is a separate mirror and is never uploaded by these scripts.

## Build and validate assets

```bash
./scripts/package-release.sh 1.1.0
(cd dist && shasum -a 256 -c Tomito-vlv-1.1.0-macos-unsigned.zip.sha256)
plutil -p "dist/Tomito vlv.app/Contents/Info.plist"
codesign --verify --deep --strict "dist/Tomito vlv.app"
```

The ZIP and checksum are:

- `dist/Tomito-vlv-1.1.0-macos-unsigned.zip`
- `dist/Tomito-vlv-1.1.0-macos-unsigned.zip.sha256`

## Publish GitHub

After committing and pushing the release commit and tag:

```bash
gh release create v1.1.0 \
  dist/Tomito-vlv-1.1.0-macos-unsigned.zip \
  dist/Tomito-vlv-1.1.0-macos-unsigned.zip.sha256 \
  --title "Tomito vlv v1.1.0" \
  --generate-notes
```

Confirm the result with:

```bash
gh release view v1.1.0
```

## Prepare SourceForge mirror

```bash
./scripts/prepare-sourceforge-release.sh 1.1.0
```

This creates local-only files in `dist/sourceforge/v1.1.0/`. See [SourceForge mirror](sourceforge.md) for the manual upload list.
