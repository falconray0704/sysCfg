#!/bin/ash

source ./.env_target

opkg install ca-certificates_20200601-1_all.ipk

opkg install libpcre_8.43-1_aarch64_cortex-a53.ipk
opkg install zlib_1.2.11-3_aarch64_cortex-a53.ipk
opkg install libopenssl1.1_1.1.1k-1_aarch64_cortex-a53.ipk
opkg install wget_1.20.3-4_aarch64_cortex-a53.ipk

opkg install libustream-openssl20150806_2020-03-13-40b563b1-1_aarch64_cortex-a53.ipk

sed -i "s/http:/https:/" /etc/opkg/distfeeds.conf

uci set dhcp.lan.ignore='1'
uci commit dhcp

uci set network.lan.ipaddr=${TARGET_INIT_CONFIG_IP}
uci set network.lan.dns=${TARGET_INIT_GATEWAY_IP}
uci set network.lan.gateway=${TARGET_INIT_GATEWAY_IP}
uci commit network

uci del dropbear.@dropbear[0]
uci changes dropbear
uci commit dropbear

passwd

#reboot


