#!/bin/bash

set -e

wget -c https://downloads.openwrt.org/releases/19.07.7/targets/brcm2708/bcm2710/openwrt-19.07.7-brcm2708-bcm2710-rpi-3-ext4-factory.img.gz

gzip -dk openwrt-19.07.7-brcm2708-bcm2710-rpi-3-ext4-factory.img.gz


mkdir piInit

pushd piInit

wget -c https://downloads.openwrt.org/releases/19.07.7/packages/aarch64_cortex-a53/base/ca-certificates_20200601-1_all.ipk
wget -c https://downloads.openwrt.org/releases/19.07.7/packages/aarch64_cortex-a53/base/libustream-openssl20150806_2020-03-13-40b563b1-1_aarch64_cortex-a53.ipk

wget -c https://downloads.openwrt.org/releases/19.07.7/packages/aarch64_cortex-a53/packages/libpcre_8.43-1_aarch64_cortex-a53.ipk
wget -c https://downloads.openwrt.org/releases/19.07.7/packages/aarch64_cortex-a53/base/zlib_1.2.11-3_aarch64_cortex-a53.ipk
wget -c https://downloads.openwrt.org/releases/19.07.7/packages/aarch64_cortex-a53/base/libopenssl1.1_1.1.1k-1_aarch64_cortex-a53.ipk
wget -c https://downloads.openwrt.org/releases/19.07.7/packages/aarch64_cortex-a53/packages/wget_1.20.3-4_aarch64_cortex-a53.ipk

popd

cp ./target_*.sh piInit/
cp ./.env_target piInit/
cp ./shadowsocks-libev piInit/

