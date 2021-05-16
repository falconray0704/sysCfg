#!/bin/ash


# Install packages
opkg update
opkg install dnscrypt-proxy2

# Enable DNS encryption
/etc/init.d/dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.53"
uci commit dhcp
/etc/init.d/dnsmasq start
# Test
#nslookup openwrt.org localhost


#reboot

