<div align="center">
  <img width="180" height="180" src="docs/screenshots/icon.png" alt="MacRack icon">
  <h1><b>MacRack</b></h1>
  <p>Keep a Mac "server-ready" by preventing sleep, forcing zero brightness, muting volume, and disabling keyboard backlight.</p>
</div>

<div align="center">
  <a href="https://github.com/851-labs/macrack/releases/latest">
    <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple&logoColor=white&style=flat" alt="macOS 13.0+">
  </a>
  <img src="https://img.shields.io/badge/Swift-6.2-f05138?logo=swift&logoColor=white&style=flat" alt="Swift 6.2">
  <a href="https://github.com/851-labs/homebrew-tap">
    <img src="https://img.shields.io/badge/Homebrew-851--labs%2Ftap-fbb040?logo=homebrew&logoColor=white&style=flat" alt="Homebrew tap">
  </a>
  <a href="https://github.com/851-labs/macrack/releases/latest">
    <img src="https://img.shields.io/github/v/release/851-labs/macrack?style=flat" alt="Latest release">
  </a>
</div>

## Prerequisites

- **Enable Auto-login:** System Settings → Users & Groups → Automatic Login
- **Disable FileVault:** required for auto-login to work

Without auto-login, the Launch Agent won’t start until someone logs in.

## Installation

```bash
brew install 851-labs/tap/macrack
brew services start macrack
```

## Usage

```bash
macrack status               # Show current system state
macrack config               # Show or update configuration
macrack config --interval 60 # Set the check interval to 60 seconds
macrack logs -n 50           # Show the last 50 log lines
macrack logs -f              # Follow log output
macrack version              # Show version info
```

Service management (via Homebrew):

```bash
brew services start macrack
brew services stop macrack
brew services restart macrack
```

## Configuration

Config file location:

```
~/.config/macrack/config.json
```

Defaults:

```json
{
  "brightnessLockEnabled": true,
  "volumeLockEnabled": true,
  "keyboardBacklightLockEnabled": true,
  "checkIntervalSeconds": 30,
  "autoPauseEnabled": true,
  "autoPauseIdleThresholdSeconds": 300
}
```

## Logs

Homebrew log path:

```
~/Library/Logs/Homebrew/macrack.log
```

If you installed via Homebrew services on Apple Silicon, the log may live at:

```
/opt/homebrew/var/log/macrack.log
```

## Agent

The Launch Agent runs `macrack agent` and:

- Spawns `caffeinate -s -d -i -u`
- Enforces brightness, keyboard backlight, and volume every interval
- Pauses enforcement when user activity is detected
- Reloads configuration on `SIGHUP`

## Development

```bash
swift build
swift run macrack status
```
