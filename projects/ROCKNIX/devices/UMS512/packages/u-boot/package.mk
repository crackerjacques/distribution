# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

# Unisoc vendor U-Boot 2015.07; mainline has no ums512 support.
# The SPL is flashed to the eMMC once and is not built here.
PKG_NAME="u-boot"
PKG_VERSION="d1f91089bcb2df300f1e8a92938c1ca84a183e8c"
PKG_SHA256="4732db543aa7542bddd72d9d80d7cde284a193c8eeef94b1761d8f2cf4fc35bc"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/crackerjacques/u-boot-ums512"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

# UMS512_UBOOT_PREBUILT=/path/to/uboot_dhtb.img ships that file instead.
PKG_STAMP="${UMS512_UBOOT_PREBUILT}"

# This tree does not build as C23, the GCC 15+ default.
ums512_uboot_make() {
  KCFLAGS="-std=gnu11" LDFLAGS="" make ARCH=arm \
    CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" HOSTCC="${HOST_CC} -std=gnu11" "$@"
}

make_target() {
  if [ -n "${UMS512_UBOOT_PREBUILT}" ]; then
    cp -v "${UMS512_UBOOT_PREBUILT}" uboot_dhtb.img
    return
  fi

  ums512_uboot_make mrproper
  ums512_uboot_make ums512_rg_rotate_defconfig
  ums512_uboot_make DEVICE_TREE=ums512_rg_rotate u-boot-dtb.bin

  # DHTB: "DHTB" | version 1 @0x4 | sha256 @0x8 | size @0x30 | payload @0x200
  python3 - u-boot-dtb.bin uboot_dhtb.img <<'EOF'
import hashlib, struct, sys

payload = open(sys.argv[1], "rb").read()
payload += b"\x00" * ((-len(payload)) % 512)

hdr = bytearray(512)
hdr[0x00:0x04] = b"DHTB"
hdr[0x04:0x08] = struct.pack("<I", 1)
hdr[0x08:0x28] = hashlib.sha256(payload).digest()
hdr[0x30:0x34] = struct.pack("<I", len(payload))

open(sys.argv[2], "wb").write(bytes(hdr) + payload)
EOF
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
    cp -av uboot_dhtb.img ${INSTALL}/usr/share/bootloader
}
