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

sleep 2
PRESET=$(read_saved_preset)
MOUNTED=$(grep -c '/vendor/etc/thermal-.*\.conf ' /proc/mounts 2>/dev/null)
[ -z "$MOUNTED" ] && MOUNTED=0

NEED_APPLY=0
if [ "$PRESET" = "stock" ]; then
  [ "$MOUNTED" -gt 0 ] && NEED_APPLY=1
else
  if [ "$MOUNTED" -lt 7 ]; then
    NEED_APPLY=1
  elif ! cmp -s "/vendor/etc/thermal-mgame.conf" "$MODDIR/presets/$PRESET/thermal-mgame.conf" 2>/dev/null; then
    NEED_APPLY=1
  fi
fi

if [ "$NEED_APPLY" = "1" ]; then
  /system/bin/sh "$MODDIR/apply_preset.sh" "$PRESET" hot >/dev/null 2>&1
fi
