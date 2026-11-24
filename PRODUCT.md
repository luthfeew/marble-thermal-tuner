# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

- **Primary users:** Rooted **POCO F5 / Redmi Note 12 Turbo (`marble` / `marblein`)** community users (GitHub, Telegram, XDA) running **HyperOS** with **KernelSU**.
- **Situation & job:** Before or during a mobile gaming session, users open the module WebUI inside KernelSU Manager to check live device temperatures and CPU clock ceilings, switch to the thermal preset matching their cooling setup (without cooler vs. with external fan/peltier cooler vs. stock), and verify that the new profile is actively mounted and applied without rebooting.

## Product Purpose

Marble Thermal Tuner (HyperOS) gives `marble` users immediate, systemless control over HyperOS gaming thermal throttling directly from KernelSU Manager's WebUI. Success means a user can accurately read current thermal/daemon state at a glance, switch between the 4 validated presets (`Balanced`, `Performance`, `Unleashed`, `Stock`) in ~1–2 seconds with instant Hot Reload, trust that the chosen preset persists across reboots, and clearly understand the cooling requirements and safety boundaries of each preset.

## Positioning

- **Instant Hot Reload without rebooting:** Swaps direct file bind mounts inside `PID 1`'s mount namespace, restarts `mi_thermald`, and re-applies the active `sconfig` in ~1–2 seconds—no reboot and no `meta-overlayfs` metamodule required on KernelSU v3+ (`32700+` Hot Install).
- **Targeted & systemless safety:** Overrides only the 7 native AES-128-CBC encrypted HyperOS gaming/performance thermal configs (`thermal-mgame.conf`, `thermal-hp-mgame.conf`, `thermal-tgame.conf`, `thermal-cgame.conf`, `thermal-per-cgame.conf`, `thermal-yuanshen.conf`, `thermal-per-normal.conf`) without modifying `/vendor` on disk, while keeping stock battery charging protection (`MONITOR-BAT`), low-battery brownout protection (`MONITOR-BCL`), daily `thermal-normal.conf`, camera thermals, and kernel/silicon hard limits intact.

## Operating Context

- **Host runtime:** Rendered inside **KernelSU Manager's Android WebView** (mobile viewport with `viewport-fit=cover`, `window.ksu.enableEdgeToEdge(true)`, system dark/light preference, and offline execution).
- **Bridge & scripts:** Communicates exclusively via `window.ksu.exec` and `window.ksu.toast` against local module scripts under `/data/adb/modules/marble_thermal_tuner/`:
  - `status.sh` — polled periodically (every 3s) and on manual refresh; returns JSON with `preset`, `sconfig`, `board_mc` (`VIRTUAL-SENSOR0`), `bat_dc` (battery NTC), `cpu_mc` (max CPU die), `cpu4_khz` / `cpu7_khz` (`scaling_max_freq`), `pid` (`mi_thermald`), and `mounted` (`0`–`7`).
  - `apply_preset.sh <preset> hot` — persists preset to `/data/adb/marble_thermal_tuner/preset` and `saved_preset`, swaps bind mounts in PID 1 namespace, restarts `mi_thermald`, re-applies `sconfig`, and prints a single-line status (`OK mode=hot ...` or error).
- **Preview fallback:** When opened outside KernelSU Manager (`window.ksu` unavailable), the WebUI enters a non-destructive preview state rather than crashing.
- **Packaging & distribution:** Packaged via `./package.sh` and `.github/workflows/release.yml` into `Marble-Thermal-Tuner-<version>.zip` for GitHub Releases, containing `webroot/index.html`, shell scripts, `presets/`, `module.prop`, and `META-INF/`.

## Capabilities and Constraints

- **Product scope:** Strictly the KernelSU WebUI (`webroot/index.html`) supporting the 4 presets (`Balanced`, `Performance`, `Unleashed`, `Stock`), live telemetry, manual refresh, hot-reload apply action, and execution log output. No companion landing page, docs site, custom preset editor, or historical graphing is in scope unless explicitly added later.
- **Single-file, zero-build, 100% offline constraint:** `webroot/index.html` must remain a single self-contained HTML file (inline CSS and JS) with **no npm/bundler build step** and **no external network, CDN, or webfont dependencies**, because KernelSU WebView runs offline on device.
- **Safety & honesty invariants:**
  - `Unleashed` must always surface a clear, unmissable **active cooler required** warning (userspace CPU, GPU, backlight, and hotplug limits bypassed; relies strictly on kernel/hardware limits: GPU `95°C`, CPU LMh ~`95–100°C` / `110°C`, TSENS `115–125°C`).
  - Must communicate accurately that stock charging protection (`MONITOR-BAT`) and hardware/kernel hard limits stay active and that preset selection persists across reboots.
- **Technical terminology & data fidelity:** Preserve accurate device/system labels and thresholds (`POCO F5 (marble)`, `VIRTUAL-SENSOR0`, `Battery NTC`, `cpu4`/`cpu7` frequencies, `sconfig` profile codes/names, `mi_thermald` PID, `0/7`–`7/7` bind mounts, and exact per-preset temperature/frequency ceilings).
- **Language:** Current WebUI copy is English; localization/i18n is not currently planned.

## Brand Commitments

- **Name & identity:** **Marble Thermal Tuner** (`Marble Thermal Tuner (HyperOS)` in `module.prop`, module ID `marble_thermal_tuner`, author `luthfeew`).
- **Voice:** Direct, technical, and safety-conscious—written for rooted Android enthusiasts who value exact thermal numbers and transparent system state over marketing hype.

## Evidence on Hand

- **Repository sources:**
  - `README.md` — full feature list, preset comparison table, safety invariants, and install/uninstall flows.
  - `module.prop` — module identity (`v1.4`, `versionCode=140`, with `updateJson` for KernelSU in-app updates).
  - `webroot/index.html` — complete current WebUI implementation with exact preset copy, `SCONFIG_NAMES` map, telemetry formatting, and `ksuExec` bridge.
  - `status.sh` & `apply_preset.sh` — authoritative JSON telemetry schema and Hot Reload execution contract.
  - `presets/{balanced,performance,unleashed}/thermal-*.conf` — the 7 encrypted Xiaomi thermal configs per custom preset.
  - `package.sh` & `.github/workflows/release.yml` — release packaging pipeline.
- **Absences (do not fabricate):** No external user testimonials, third-party reviews, multi-game benchmark suites (only the README's single reference to `~58 FPS Genshin` for Performance), or external imagery/logo assets exist in the repository.

## Product Principles

1. **Glanceable truth over guesswork:** Live temperatures, CPU ceilings, `mi_thermald` daemon state, `sconfig`, and bind-mount count (`0/7`–`7/7`) must make it immediately obvious whether a preset is truly active and how the device is running.
2. **Fast, confident pre-game switching:** Selecting and hot-reloading a preset on a phone screen should be low-friction and clear about what is selected versus what is currently active, with immediate feedback during the 1–2 second daemon restart.
3. **Safety boundaries stay unmissable:** The distinction between daily-safe presets (`Balanced`, `Performance`, `Stock`) and cooler-only `Unleashed` must never be blurred or hidden behind frictionless ambiguity.
4. **Offline-first, zero-bloat delivery:** Everything ships inside one lightweight `webroot/index.html` with zero external requests and zero build tooling, matching the simplicity of a KernelSU module ZIP.
5. **Respect hardware and community precision:** Keep real Xiaomi/KernelSU telemetry identifiers and exact thermal thresholds intact so experienced `marble` users can verify behavior without ambiguity.
