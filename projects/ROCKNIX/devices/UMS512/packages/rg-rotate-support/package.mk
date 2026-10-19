# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rg-rotate-support"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="https://rocknix.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain alsa-utils"
PKG_LONGDESC="Anbernic RG Rotate (Unisoc T618) board support"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -av ${PKG_DIR}/sources/bin/* ${INSTALL}/usr/bin
    chmod 0755 ${INSTALL}/usr/bin/rotate-*

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/sprd
    cp -av ${PKG_DIR}/sources/firmware/sprd/*.ini ${INSTALL}/$(get_full_firmware_dir)/sprd

  mkdir -p ${INSTALL}/usr/lib/rg-rotate-support
    cp -av ${PKG_DIR}/sources/rotate-quit-fallback.sh ${INSTALL}/usr/lib/rg-rotate-support
    chmod 0755 ${INSTALL}/usr/lib/rg-rotate-support/rotate-quit-fallback.sh

  mkdir -p ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d
    cp -av ${PKG_DIR}/sources/wireplumber/*.conf ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d

  # Every card name alsa-lib may look up points at the one profile.
  local ucm=${INSTALL}/usr/share/alsa/ucm2
  mkdir -p ${ucm}/sprdphonesc2730 ${ucm}/sprdphone-sc2730 ${ucm}/sprdphone-sc273 ${ucm}/conf.d/sprdphone-sc273
    cp -av ${PKG_DIR}/sources/ucm2/sprdphonesc2730/*.conf ${ucm}/sprdphonesc2730
    ln -sf ../sprdphonesc2730/HiFi.conf ${ucm}/sprdphone-sc2730/HiFi.conf
    ln -sf ../sprdphonesc2730/sprdphonesc2730.conf ${ucm}/sprdphone-sc2730/sprdphone-sc2730.conf
    ln -sf ../sprdphonesc2730/HiFi.conf ${ucm}/sprdphone-sc273/HiFi.conf
    ln -sf ../sprdphonesc2730/sprdphonesc2730.conf ${ucm}/sprdphone-sc273/sprdphone-sc273.conf
    ln -sf ../sprdphonesc2730/sprdphonesc2730.conf ${ucm}/sprdphone-sc273/sprdphone-sc2730.conf
    ln -sf ../../sprdphonesc2730/HiFi.conf ${ucm}/conf.d/sprdphone-sc273/HiFi.conf
    ln -sf ../../sprdphonesc2730/sprdphonesc2730.conf ${ucm}/conf.d/sprdphone-sc273/sprdphone-sc273.conf
    ln -sf ../../sprdphonesc2730/sprdphonesc2730.conf ${ucm}/conf.d/sprdphone-sc273/sprdphone-sc2730.conf
}

post_install() {
  enable_service rotate-extract-firmware.service
  enable_service rotate-audio.service
  enable_service rotate-audio-prime.service
}
