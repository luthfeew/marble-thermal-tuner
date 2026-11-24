#!/system/bin/sh
# Marble Thermal Tuner — Hot Reload & Persistent Boot Engine
export PATH="/data/adb/ksu/bin:/system/bin:/vendor/bin:/sbin:$PATH"

MODDIR="${0%/*}"
STATE_DIR="/data/adb/marble_thermal_tuner"
ACTIVE_DIR="$STATE_DIR/active"
PRESET_FILE="$STATE_DIR/preset"
BACKUP_PRESET_FILE="$MODDIR/saved_preset"
LOG_FILE="$STATE_DIR/boot.log"

PRESET="$1"
MODE="${2:-hot}" # "hot" (restart mi_thermald) or "boot" (early boot, before mi_thermald)

MANAGED_FILES="
thermal-mgame.conf
thermal-hp-mgame.conf
thermal-tgame.conf
thermal-cgame.conf
thermal-per-cgame.conf
thermal-yuanshen.conf
thermal-per-normal.conf
"

# Always enter PID 1 global mount namespace so mi_thermald and all processes see bind mounts
if [ -z "$MTT_IN_NS1" ]; then
  SELF_NS=$(readlink /proc/self/ns/mnt 2>/dev/null)
  INIT_NS=$(readlink /proc/1/ns/mnt 2>/dev/null)
  if [ -n "$SELF_NS" ] && [ -n "$INIT_NS" ] && [ "$SELF_NS" != "$INIT_NS" ]; then
    NSENTER=""
    if [ -x /data/adb/ksu/bin/busybox ]; then
      NSENTER="/data/adb/ksu/bin/busybox nsenter"
    elif command -v nsenter >/dev/null 2>&1; then
      NSENTER="nsenter"
    fi
    if [ -n "$NSENTER" ]; then
      export MTT_IN_NS1=1
      exec $NSENTER -t 1 -m -- /system/bin/sh "$0" "$@"
    fi
  fi
fi

# Accept legacy names gracefully if ever invoked manually
case "$PRESET" in
  gaming) PRESET="balanced" ;;
  cooler) PRESET="performance" ;;
esac

case "$PRESET" in
  stock|balanced|performance|unleashed) ;;
  *)
    echo "ERROR: Invalid preset '$PRESET' (expected: balanced, performance, unleashed, stock)" >&2
    exit 1
    ;;
esac

mkdir -p "$ACTIVE_DIR"
chmod 0755 "$STATE_DIR" "$ACTIVE_DIR"

# Persist selected preset immediately in both locations and flush to disk
echo "$PRESET" > "$PRESET_FILE"
chmod 0644 "$PRESET_FILE"
echo "$PRESET" > "$BACKUP_PRESET_FILE" 2>/dev/null || true
chmod 0644 "$BACKUP_PRESET_FILE" 2>/dev/null || true
sync

detect_thermal_svc() {
  local svc
  svc=$(/system/bin/getprop | sed -n 's/^\[init\.svc\.\([^]]*mi_thermald[^]]*\)\]:.*/\1/p' | head -n 1)
  [ -z "$svc" ] && svc="mi_thermald"
  echo "$svc"
}

CUR_SCONFIG=""
SVC="mi_thermald"
if [ "$MODE" = "hot" ]; then
  CUR_SCONFIG=$(cat /sys/class/thermal/thermal_message/sconfig 2>/dev/null | tr -d '\r\n')
  SVC=$(detect_thermal_svc)
  /system/bin/stop "$SVC" 2>/dev/null || true
  i=0
  while [ $i -lt 10 ]; do
    pidof mi_thermald >/dev/null 2>&1 || break
    sleep 0.1
    i=$((i + 1))
  done
  if pidof mi_thermald >/dev/null 2>&1; then
    killall mi_thermald 2>/dev/null || true
    sleep 0.2
  fi
fi

# Unmount any existing bind mounts cleanly
for f in $MANAGED_FILES; do
  TARGET="/vendor/etc/$f"
  while grep -q " $TARGET " /proc/mounts 2>/dev/null; do
    umount "$TARGET" 2>/dev/null || umount -l "$TARGET" 2>/dev/null || break
  done
done

MOUNTED=0
if [ "$PRESET" != "stock" ]; then
  SRC_DIR="$MODDIR/presets/$PRESET"
  if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Preset directory not found: $SRC_DIR" >&2
    [ "$MODE" = "hot" ] && /system/bin/start "$SVC" 2>/dev/null || true
    exit 1
  fi

  for f in $MANAGED_FILES; do
    SRC="$SRC_DIR/$f"
    DST="$ACTIVE_DIR/$f"
    TARGET="/vendor/etc/$f"
    if [ -f "$SRC" ] && [ -f "$TARGET" ]; then
      cp -f "$SRC" "$DST"
      chmod 0644 "$DST"
      chown 0:0 "$DST"
      chcon u:object_r:vendor_configs_file:s0 "$DST" 2>/dev/null || true
      if mount -o bind "$DST" "$TARGET" 2>/dev/null || mount --bind "$DST" "$TARGET" 2>/dev/null; then
        MOUNTED=$((MOUNTED + 1))
      else
        echo "WARN: Failed to bind-mount $TARGET" >&2
      fi
    fi
  done
fi

sync

if [ "$MODE" = "hot" ]; then
  /system/bin/start "$SVC" 2>/dev/null || true
  i=0
  while [ $i -lt 20 ]; do
    pidof mi_thermald >/dev/null 2>&1 && break
    sleep 0.1
    i=$((i + 1))
  done
  if [ -n "$CUR_SCONFIG" ] && [ -w /sys/class/thermal/thermal_message/sconfig ]; then
    sleep 0.2
    echo "$CUR_SCONFIG" > /sys/class/thermal/thermal_message/sconfig 2>/dev/null || true
  fi
  PID=$(pidof mi_thermald 2>/dev/null | awk '{print $1}')
  MSG="OK mode=hot preset=$PRESET mounted=$MOUNTED svc=$SVC pid=${PID:-none} sconfig=${CUR_SCONFIG:-none}"
else
  MSG="OK mode=boot preset=$PRESET mounted=$MOUNTED"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') $MSG" >> "$LOG_FILE" 2>/dev/null || true
if [ -f "$LOG_FILE" ]; then
  tail -n 40 "$LOG_FILE" > "${LOG_FILE}.tmp" 2>/dev/null && mv -f "${LOG_FILE}.tmp" "$LOG_FILE" 2>/dev/null || true
fi

echo "$MSG"
exit 0
