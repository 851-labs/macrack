# MacRack

Keep a Mac "server-ready" by preventing sleep, forcing zero brightness, and muting volume. Designed for headless rack or closet setups where a MacBook needs to stay awake without user interaction.

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

- Spawns `caffeinate -s`
- Enforces brightness and volume every interval
- Pauses enforcement when user activity is detected
- Reloads configuration on `SIGHUP`

## Development

```bash
swift build
swift run macrack status
```
