#!/usr/bin/env bash
set -euo pipefail

VERSION=$(grep -m1 '^version=' module.prop | cut -d= -f2)
OUT="Marble-Thermal-Tuner-${VERSION}.zip"

rm -f "$OUT"
zip -r9 "$OUT" \
  META-INF \
  presets \
  webroot \
  module.prop \
  customize.sh \
  apply_preset.sh \
  status.sh \
  hotinstall.sh \
  post-fs-data.sh \
  service.sh \
  boot-completed.sh \
  uninstall.sh

echo "Built $OUT"
