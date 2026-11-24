#!/system/bin/sh
SKIPUNZIP=0

DEVICE=$(getprop ro.product.vendor.device)
[ -z "$DEVICE" ] && DEVICE=$(getprop ro.product.device)

ui_print "========================================="
ui_print "  Marble Thermal Tuner v1.3 (HyperOS)    "
ui_print "========================================="
ui_print "- Detected device: ${DEVICE:-unknown}"

if [ "$DEVICE" != "marble" ] && [ "$DEVICE" != "marblein" ]; then
  ui_print "! Warning: This module is built specifically for POCO F5 / Redmi Note 12 Turbo (marble)."
  ui_print "! Continuing installation anyway..."
fi

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/apply_preset.sh" 0 0 0755
set_perm "$MODPATH/status.sh" 0 0 0755
set_perm "$MODPATH/hotinstall.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/boot-completed.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

# Preserve and migrate previously saved preset across updates
STATE_FILE="/data/adb/marble_thermal_tuner/preset"
if [ -f "$STATE_FILE" ]; then
  OLD=$(cat "$STATE_FILE" 2>/dev/null | tr -d '\r\n')
  case "$OLD" in
    gaming)      NEW="balanced" ;;
    cooler)      NEW="performance" ;;
    balanced|performance|unleashed|stock) NEW="$OLD" ;;
    *)           NEW="balanced" ;;
  esac
  echo "$NEW" > "$STATE_FILE"
  echo "$NEW" > "$MODPATH/saved_preset"
  chmod 0644 "$STATE_FILE" "$MODPATH/saved_preset"
  ui_print "- Preserving saved preset: $NEW"
fi

# Request KernelSU Hot Install (live activation without reboot on KernelSU 32700+)
export MODULE_HOT_INSTALL_REQUEST=true
export MODULE_HOT_RUN_SCRIPT=hotinstall.sh

ui_print "- Presets: Balanced, Performance, Unleashed, Stock."
ui_print "- KernelSU WebUI, Hot Reload & persistent boot restore enabled."
