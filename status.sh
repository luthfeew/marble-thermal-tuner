#!/system/bin/sh
export PATH="/data/adb/ksu/bin:/system/bin:/vendor/bin:/sbin:$PATH"

MODDIR="${0%/*}"
STATE_DIR="/data/adb/marble_thermal_tuner"
PRESET_FILE="$STATE_DIR/preset"
BACKUP_PRESET_FILE="$MODDIR/saved_preset"

PRESET=""
if [ -f "$PRESET_FILE" ]; then
  PRESET=$(cat "$PRESET_FILE" 2>/dev/null | tr -d '\r\n')
fi
if [ -z "$PRESET" ] && [ -f "$BACKUP_PRESET_FILE" ]; then
  PRESET=$(cat "$BACKUP_PRESET_FILE" 2>/dev/null | tr -d '\r\n')
fi
case "$PRESET" in
  gaming) PRESET="balanced" ;;
  cooler) PRESET="performance" ;;
  stock|balanced|performance|unleashed) ;;
  *) PRESET="stock" ;;
esac

SCONFIG=$(cat /sys/class/thermal/thermal_message/sconfig 2>/dev/null | tr -d '\r\n')
BOARD_RAW=$(cat /sys/class/thermal/thermal_message/board_sensor_temp 2>/dev/null | tr -d '\r\n')
BAT_RAW=$(cat /sys/class/power_supply/battery/temp 2>/dev/null | tr -d '\r\n')
PID=$(pidof mi_thermald 2>/dev/null | awk '{print $1}')
MOUNTED=$(grep -c '/vendor/etc/thermal-.*\.conf ' /proc/mounts 2>/dev/null)
[ -z "$MOUNTED" ] && MOUNTED=0

CPU_MAX=0
for z in /sys/class/thermal/thermal_zone*; do
  t=$(cat "$z/type" 2>/dev/null)
  case "$t" in
    cpuss-*|cpu-1-*)
      v=$(cat "$z/temp" 2>/dev/null)
      if [ -n "$v" ] && [ "$v" -gt "$CPU_MAX" ] 2>/dev/null; then
        CPU_MAX=$v
      fi
      ;;
  esac
done

CPU4_MAX=$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null | tr -d '\r\n')
CPU7_MAX=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null | tr -d '\r\n')

printf '{"preset":"%s","sconfig":"%s","board_mc":%s,"bat_dc":%s,"cpu_mc":%s,"cpu4_khz":%s,"cpu7_khz":%s,"pid":"%s","mounted":%s}\n' \
  "${PRESET}" \
  "${SCONFIG:-0}" \
  "${BOARD_RAW:-0}" \
  "${BAT_RAW:-0}" \
  "${CPU_MAX:-0}" \
  "${CPU4_MAX:-0}" \
  "${CPU7_MAX:-0}" \
  "${PID:-}" \
  "${MOUNTED:-0}"
