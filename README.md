# MacRack

Keep a Mac "server-ready" by preventing sleep, forcing zero brightness, and muting volume. Designed for headless rack or closet setups where a MacBook needs to stay awake without user interaction.

## Prerequisites

- **Auto-login enabled:** System Settings → Users & Groups → Automatic Login
- **FileVault disabled:** required for auto-login to work

Without auto-login, the Launch Agent won’t start until someone logs in.

## Installation

```bash
brew install 851-labs/tap/macrack
brew services start macrack
```

## Usage

```bash
macrack status
macrack config
macrack config --interval 60
macrack logs -n 50
macrack logs -f
macrack version
```

## Commands

- `macrack status` — Show current system state
- `macrack config` — Show or update configuration
- `macrack logs` — Show agent logs
- `macrack version` — Show version info

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

## Agent

The Launch Agent runs `macrack agent` and:

- Spawns `caffeinate -s`
- Enforces brightness and volume every interval
- Pauses enforcement when user activity is detected
- Reloads configuration on `SIGHUP`

## Development

```bash
swift build
swift run macrack status
```
