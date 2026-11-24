# Changelog

## v1.4

- **KernelSU in-app updates:** Added `updateJson` support so future releases can be updated directly from KernelSU Manager.
- **Redesigned WebUI:** Compact hardware-instrument layout with live telemetry, calibrated `VIRTUAL-SENSOR0` Board Scale, and all 4 presets visible above the fold on mobile (`360dp`–`390dp`).
- **Unleashed guardrails:** Separated `Unleashed` behind an `Active Cooling Required` divider, added a confirmation dialog before applying, and added a persistent active alert banner with one-tap `Safe Exit → Balanced`.
- **Hardened Hot Reload:** Paused 3s polling during `mi_thermald` restart, verified bind-mount count (`0/7` or `7/7`) and live PID, added copyable/dismissible execution logs, and improved `status.sh` error handling.
- **Accessibility & polish:** Full WCAG AA contrast across dark/light themes, `44px+` touch targets, keyboard shortcuts (`Alt+R`, `Alt+Enter`), and thermal severity coloring for Board, Battery, and CPU die temps.

## v1.3

- Initial release with 4 presets (`Stock`, `Balanced`, `Performance`, `Unleashed`), KernelSU WebUI, instant Hot Reload, Hot Install, and persistent boot restore.
