# Marble Thermal Tuner (HyperOS)

Systemless **KernelSU** thermal preset controller for **POCO F5 / Redmi Note 12 Turbo (`marble`)** on HyperOS — with WebUI telemetry, instant Hot Reload, and reboot persistence.

## Presets

Overrides the 7 native AES-128-CBC HyperOS gaming/performance configs in `/vendor/etc` via bind mounts (no `/vendor` writes, no metamodule required).

| Preset | Best For | Board Triggers (`VIRTUAL-SENSOR0`) | Safety |
| :--- | :--- | :--- | :--- |
| **Stock** | Original HyperOS behavior | `43°C` CPU · `37°C` dim (`0/7` mounts) | 100% stock `/vendor/etc` |
| **Balanced** *(Recommended)* | Daily gaming without cooler | `46°C` CPU · `48°C` GPU · `45°C` dim | Stock `MONITOR-BAT` · Hotplug `51°C` |
| **Performance** | Sustained high FPS | `49°C` CPU · `50°C` GPU · `49°C` dim | Stock `MONITOR-BAT` · Hotplug `52.5°C` |
| **Unleashed** *(Cooler Only)* | Fan/peltier cooler & benchmarks | Userspace limits bypassed (`90°C`) | Kernel/silicon hard limits only |

> **Cooler required for `Unleashed`:** Bypasses userspace CPU, GPU, backlight, and hotplug throttling (relying on kernel GPU `95°C`, CPU LMh `~95–100°C` / `110°C`, TSENS `115–125°C`). Always use active cooling to protect battery health.

## Highlights

- **WebUI Telemetry:** Live board (`VIRTUAL-SENSOR0`), battery NTC, and CPU die temps, calibrated board scale, `cpu4`/`cpu7` ceilings, `sconfig` profile, `mi_thermald` PID, and `0/7`–`7/7` bind-mount verification.
- **Instant Hot Reload:** Applies presets in ~1–2s inside `PID 1`'s mount namespace without rebooting.
- **KernelSU Native:** Supports Hot Install (`32700+`), KernelSU v3+ without `meta-overlayfs`, and **in-app updates** via `updateJson` (`v1.4+`).
- **Systemless & Persistent:** Restores your preset on boot while keeping stock charging (`MONITOR-BAT`), brownout (`MONITOR-BCL`), `thermal-normal.conf`, and camera thermals intact.

## Install & Update

1. Download the latest ZIP from [Releases](https://github.com/luthfeew/marble-thermal-tuner/releases/latest).
2. Flash in **KernelSU Manager → Modules → Install**, then tap **WebUI**.
3. From **v1.4+**, future versions can be updated directly inside KernelSU Manager's **Modules** menu.
4. To remove, tap **Uninstall** in KernelSU Manager and reboot.

## Build from Source

```bash
./package.sh
```
