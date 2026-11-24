#!/system/bin/sh
export PATH="/data/adb/ksu/bin:/system/bin:/vendor/bin:/sbin:$PATH"
MODDIR="${0%/*}"
read_saved_preset() {
  local p=""
  if [ -f "/data/adb/marble_thermal_tuner/preset" ]; then
    p=$(cat "/data/adb/marble_thermal_tuner/preset" 2>/dev/null | tr -d '\r\n')
  fi
  if [ -z "$p" ] && [ -f "$MODDIR/saved_preset" ]; then
    p=$(cat "$MODDIR/saved_preset" 2>/dev/null | tr -d '\r\n')
  fi
  case "$p" in
    gaming) echo "balanced" ;;
    cooler) echo "performance" ;;
    stock|balanced|performance|unleashed) echo "$p" ;;
    *) echo "balanced" ;;
  esac
}
PRESET=$(read_saved_preset)
/system/bin/sh "$MODDIR/apply_preset.sh" "$PRESET" hot
