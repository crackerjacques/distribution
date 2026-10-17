#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})

# identify the boot device
if [ -z "$BOOT_DISK" ]; then
  case $BOOT_PART in
    /dev/mmcblk*) BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g");;
  esac
fi

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

echo "Updating device trees..."
mkdir -p $BOOT_ROOT/device_trees
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $BOOT_ROOT/device_trees

# The SPL finds U-Boot by GPT partition name, so write into that partition on
# the boot disk only. The eMMC holds stock Android with its own uboot_a/b.
if [ -f "$SYSTEM_ROOT/usr/share/bootloader/uboot_dhtb.img" -a -n "$BOOT_DISK" ]; then
  for UEVENT in /sys/class/block/${BOOT_DISK##*/}p*/uevent; do
    if grep -qx "PARTNAME=uboot" "$UEVENT"; then
      UBOOT_PART="/dev/$(sed -n 's/^DEVNAME=//p' "$UEVENT")"
      echo "Updating uboot_dhtb.img on $UBOOT_PART..."
      dd if=$SYSTEM_ROOT/usr/share/bootloader/uboot_dhtb.img of=$UBOOT_PART bs=512 conv=fsync &>/dev/null
      break
    fi
  done
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
