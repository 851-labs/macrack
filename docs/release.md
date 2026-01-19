# Release Process

This document outlines how to ship a new MacRack CLI release and update the Homebrew tap.

## Prerequisites

- GitHub access to `851-labs/macrack`
- Homebrew tap repo: `851-labs/homebrew-tap`
- `gh` CLI authenticated
- Homebrew available locally for install validation

## Release Steps

### 1) Bump Version

Update the CLI version in:

- `Sources/macrack/MacrackVersion.swift`

Commit the bump:

```
git add Sources/macrack/MacrackVersion.swift
git commit -m "chore: bump version to x.y.z"
```

### 2) Tag and Push

Create the tag and push it:

```
git tag vX.Y.Z
git push origin vX.Y.Z
```

### 3) Create GitHub Release

```
gh release create vX.Y.Z --title "vX.Y.Z" --notes "<summary>"
```

### 4) Compute SHA256

Download the tag tarball and compute the checksum:

```
curl -L "https://github.com/851-labs/macrack/archive/refs/tags/vX.Y.Z.tar.gz" -o "/tmp/macrack-vX.Y.Z.tar.gz"
shasum -a 256 "/tmp/macrack-vX.Y.Z.tar.gz"
```

### 5) Update Homebrew Tap

Edit `homebrew-tap/Formula/macrack.rb`:

```
url "https://github.com/851-labs/macrack/archive/refs/tags/vX.Y.Z.tar.gz"
sha256 "<sha256>"
```

Commit and push:

```
cd ~/repos/851-labs/homebrew-tap
git add Formula/macrack.rb
git commit -m "chore: bump macrack to X.Y.Z"
git push
```

### 6) Validate Install

If validating on your local (non-rack) machine, make sure to stop the service after the check. On a rack-mounted host, it’s fine (recommended) to leave the service running.

```
brew update
brew upgrade macrack
brew services restart macrack
macrack version
macrack status
```

Local machine cleanup:

```
brew services stop macrack
```

## Notes

- The Homebrew formula builds from source using `swift build -c release --disable-sandbox`.
- If `macrack status` shows brightness as `unknown`, check that the machine has an active display and that the DisplayServices backend is available.
