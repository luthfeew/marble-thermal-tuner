#!/system/bin/sh
export PATH="/data/adb/ksu/bin:/system/bin:/vendor/bin:/sbin:$PATH"
for f in thermal-mgame.conf thermal-hp-mgame.conf thermal-tgame.conf thermal-cgame.conf thermal-per-cgame.conf thermal-yuanshen.conf thermal-per-normal.conf; do
  while grep -q " /vendor/etc/$f " /proc/mounts 2>/dev/null; do
    umount "/vendor/etc/$f" 2>/dev/null || umount -l "/vendor/etc/$f" 2>/dev/null || break
  done
done
rm -rf /data/adb/marble_thermal_tuner
SVC=$(/system/bin/getprop | sed -n 's/^\[init\.svc\.\([^]]*mi_thermald[^]]*\)\]:.*/\1/p' | head -n 1)
[ -z "$SVC" ] && SVC="mi_thermald"
/system/bin/stop "$SVC" 2>/dev/null || true
sleep 0.2
/system/bin/start "$SVC" 2>/dev/null || true
