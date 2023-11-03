#!/bin/ash

source ./.env_target

uci set network.lan.ipaddr=${TARGET_GATEWAY_IP}

uci changes network
uci commit network



echo ""
echo ""
echo ""
echo "REBOOT......"
echo ""
echo ""
echo ""

reboot


