#!/bin/ash


# Shadowsocks
opkg update
opkg install shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-rules shadowsocks-libev-ss-tunnel
opkg install luci-app-shadowsocks-libev

cp ./shadowsocks-libev /etc/config
/etc/init.d/shadowsocks-libev restart

iptables-save | grep ss_rules
netstat -lntp | grep -E '8053|1100'
ps ww | grep ss-


#reboot

