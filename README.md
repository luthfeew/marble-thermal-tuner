# Marble Thermal Tuner (HyperOS)

A systemless **KernelSU** module for **POCO F5 / Redmi Note 12 Turbo (`marble`)** running **HyperOS** that lets you switch gaming thermal presets on the fly via **KernelSU WebUI** — with **instant Hot Reload (no reboot)**, **KernelSU Hot Install**, and **persistent boot restore**.

## Features

- **KernelSU WebUI** (`webroot/index.html`) with live telemetry:
  - Virtual board temperature (`VIRTUAL-SENSOR0`), battery NTC temperature, max CPU die temperature & active `cpu4`/`cpu7` max frequencies
  - Active `sconfig` profile, `mi_thermald` PID status, and bind-mount count (`7/7` active / `0/7` stock)
- **Instant Hot Reload (no reboot)**: swaps bind mounts inside `PID 1`'s mount namespace, restarts `mi_thermald`, and re-applies the active `sconfig` in ~1–2 seconds.
- **No metamodule required**: uses direct file bind mounts (no `system/` overlay needed, so it works out of the box on KernelSU v3+ without `meta-overlayfs`).
- **KernelSU Hot Install**: activates immediately upon flashing in KernelSU Manager (`32700+`).
- **Persistent across reboots**: restores the saved preset automatically on boot via `post-fs-data.sh`, `service.sh`, and `boot-completed.sh`.
- **100% systemless & safe**: never writes to `/vendor` on disk. Battery charging protection (`MONITOR-BAT`), low-battery brownout protection (`MONITOR-BCL`), daily `thermal-normal.conf`, camera, and kernel/hardware thermal hard limits always remain intact.

## Thermal Presets

All custom presets override the 7 HyperOS gaming/performance profiles (`thermal-mgame.conf`, `thermal-hp-mgame.conf`, `thermal-tgame.conf`, `thermal-cgame.conf`, `thermal-per-cgame.conf`, `thermal-yuanshen.conf`, `thermal-per-normal.conf`), AES-128-CBC encrypted in native Xiaomi `mi_thermald` format.

| Preset | Target Use | CPU Big (`cpu4`) / Prime (`cpu7`) | GPU Limit | Display Backlight | Safety |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Balanced** *(Recommended)* | Daily gaming **without cooler** (~45°C battery) | Full up to `46°C` → `1.88` / `1.55` / `1.11 GHz` | Full up to `48°C` (Lv 1 @ `48°C`, Lv 3 @ `50°C`) | Full up to `45°C` | Stock charging • Hotplug `51°C` |
| **Performance** | Sustained high FPS (~58 FPS Genshin) | Full up to `49°C` → `2.00` / `1.55` / `1.11 GHz` | Full up to `50°C` (Lv 1 @ `50°C`, Lv 2 @ `52°C`) | Full up to `49°C` | Stock charging • Hotplug `52.5°C` |
| **Unleashed** *(Cooler Only)* | Active fan cooler / peltier or benchmarks | Userspace overridden to `90°C` (hardware/kernel only) | Userspace overridden to `90°C` (kernel `95°C`) | No thermal dimming | Stock charging • Hardware/kernel hard limits |
| **Stock** | Original HyperOS ROM | Unmounts all overrides (`0/7` mounts) | Stock HyperOS | Stock HyperOS (`37°C`) | 100% original `/vendor/etc` |

> **Warning for `Unleashed`:** All userspace CPU, GPU, backlight, boost, hotplug, and `temp_state` throttling is bypassed, relying strictly on kernel (`gpu0` 95°C, `cpu4-emerg` 110°C) and Qualcomm silicon hard limits (LMh ~95–100°C, TSENS 115–125°C). **Use with an external fan cooler / peltier** to protect long-term battery health.

## Installation

1. Download **`Marble-Thermal-Tuner-v1.3.zip`** from the [Releases](https://github.com/luthfeew/marble-thermal-tuner/releases) page.
2. Open **KernelSU Manager** → **Modules** → **Install** and select the ZIP.
3. Tap **Open / WebUI** on **Marble Thermal Tuner (HyperOS)** to pick and apply any preset without rebooting.

## Uninstall

Tap **Uninstall** in KernelSU Manager and reboot. `uninstall.sh` cleanly unmounts all bind mounts, removes `/data/adb/marble_thermal_tuner`, and restores 100% stock HyperOS thermal behavior.

## Building the ZIP from Source

```bash
./package.sh
```
