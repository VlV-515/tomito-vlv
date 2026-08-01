# SourceForge mirror

SourceForge is a secondary mirror. GitHub Releases remain the primary download source.

## Prepare files locally

```bash
./scripts/prepare-sourceforge-release.sh 1.1.0
```

This creates:

- `dist/sourceforge/v1.1.0/Tomito-vlv-1.1.0-macos-unsigned.zip`
- `dist/sourceforge/v1.1.0/Tomito-vlv-1.1.0-macos-unsigned.zip.sha256`
- `dist/sourceforge/v1.1.0/readme.md`

## Upload manually

1. Open [Tomito vlv files](https://sourceforge.net/projects/tomito-vlv/files/).
2. Create the `v1.1.0` folder if it does not exist.
3. Upload the ZIP, checksum, and `readme.md` from the local folder above.
4. Mark the ZIP as the default macOS download if SourceForge offers that option.

The app is ad-hoc signed and not notarized. Mirroring it does not change Gatekeeper behavior.
