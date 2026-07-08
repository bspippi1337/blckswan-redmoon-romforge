#!/usr/bin/env bash
set -euo pipefail
source build/envsetup.sh
lunch blckswan_lamu-userdebug
mka -j"$(nproc)" | tee build.log
echo "BLCKSWAN OS 42 RED MOON build complete."
