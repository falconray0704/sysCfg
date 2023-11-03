#!/bin/ash

## refer to: 
## https://github.com/dnscrypt/dnscrypt-proxy/wiki/Installation-on-OpenWRT

source ./.env_target

uci add_list system.ntp.server="162.159.200.123"
uci add_list system.ntp.server="162.159.200.1"
uci add_list system.ntp.server="216.239.35.0"
uci add_list system.ntp.server="216.239.35.4"
uci add_list system.ntp.server="216.239.35.8"
uci add_list system.ntp.server="216.239.35.12"

uci commit system.ntp
/etc/init.d/sysntpd restart

