# Changelog

## 1.0.4 - 2026-01-25
- Add pre-built universal binary distribution (no longer requires Xcode to install).
- Binary is now code-signed and notarized with Apple.

## 1.0.3 - 2026-01-25
- Fix network status ordering in `macrack status`.

## 1.0.2 - 2026-01-20
- Add network status to `macrack status`.

## 1.0.1 - 2026-01-19
- Add default route network status in `macrack status`.

## 1.0.0 - 2026-01-19
- Stable release with brightness, keyboard backlight, volume, and sleep enforcement.

## 0.1.18 - 2026-01-19
- Switch keyboard backlight control to CoreBrightness.

## 0.1.17 - 2026-01-19
- Switch keyboard backlight control to HID event system APIs.

## 0.1.16 - 2026-01-19
- Expand keyboard backlight `hidutil` payload.

## 0.1.15 - 2026-01-19
- Switch keyboard backlight control to `hidutil`.

## 0.1.14 - 2026-01-19
- Add keyboard backlight enforcement.

## 0.1.13 - 2026-01-19
- Keep user session awake with `caffeinate -s -d -i -u`.

## 0.1.12 - 2026-01-19
- Prevent display sleep by running `caffeinate -s -d`.

## 0.1.11 - 2026-01-19
- Align status and config label columns.

## 0.1.10 - 2026-01-19
- Avoid truncating config labels.

## 0.1.9 - 2026-01-19
- Simplify config labels to “Brightness Locked” and “Volume Locked”.

## 0.1.8 - 2026-01-19
- Add spacing after the config hint message.

## 0.1.7 - 2026-01-19
- Add `--verbose` to `macrack status` for caffeinate PID details.

## 0.1.6 - 2026-01-19
- Keep caffeinate details uncolored in status output.

## 0.1.5 - 2026-01-19
- Colorize status values by success/failure.

## 0.1.4 - 2026-01-19
- Use DisplayServices for brightness control.

## 0.1.3 - 2026-01-19
- Add Apple ARM backlight control fallback.

## 0.1.2 - 2026-01-19
- Support `-n` for `macrack logs`.

## 0.1.1 - 2026-01-19
- Improve status output and log path detection.

## 0.1.0 - 2026-01-19
- Initial experimental release.
