#!/bin/bash
# Stops the build if the kernel can write touch firmware: a kernel from another device
# has already flashed the wrong firmware on this phone. Usage: check_kernel.sh <version> <source> <obj>
KV=$1; S=$2; O=$3; rc=0
for f in System.map vmlinux .config; do [ -s "$O/$f" ] || { echo "FAIL: missing $O/$f"; exit 1; }; done

if grep -E 'fts_ctpm_(upgrade_with|upgrade_init|fw_upgrade|auto_upgrade|lcd_cfg|rom_or_pram)|fts_updatefun$|fts_upgrade_|fts_fwupg|fts_fwupgrade|CTPM_FW|aucFW_PRAM_BOOT' "$O/System.map"; then
  echo "FAIL: touch firmware upgrade symbols present"; rc=1
fi
if grep -aE -m3 'HQ_D2_XIAOMI|FT8716_app|XIAPU' "$O/vmlinux" >/dev/null; then
  echo "FAIL: touch firmware references present"; rc=1
fi
[ -e "$O/drivers/input/touchscreen/ft8716" ] && { echo "FAIL: ft8716 was built"; rc=1; }

case "$KV" in
  3.18|4.9)
    grep -q ' fts_ts_probe$' "$O/System.map" || { echo "FAIL: touch driver not linked"; rc=1; } ;;
  6.19)
    grep -q 'edt_ft5x06_ts_probe$' "$O/System.map" || { echo "FAIL: touch driver not linked"; rc=1; }
    # Every option the defconfig asks for must survive dependency resolution
    while IFS= read -r line; do
      grep -qxF "$line" "$O/.config" || { echo "FAIL: $line did not apply"; rc=1; }
    done < <(grep -E '^CONFIG_[A-Z0-9_]+=y$' "$S/arch/arm64/configs/a001d_twrp_defconfig") ;;
  *) echo "FAIL: unknown kernel $KV"; rc=1 ;;
esac

[ $rc = 0 ] && echo "OK: $KV kernel has no touch firmware write path"
exit $rc
