#!/bin/ash

source ./.env_target

uci del dropbear.@dropbear[0]
uci changes dropbear
uci commit dropbear

echo ""
echo ""
echo ""
echo "Rebooting......"
echo ""
echo ""
echo ""

reboot


