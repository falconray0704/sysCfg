#!/bin/ash

## refer to : https://3os.org/infrastructure/openwrt/disable-ipv6/

source ./.env_target

uci set network.lan.ipv6='0'
uci set network.${USB_INTERFACE_WAN_NAME}.ipv6='0'
uci set dhcp.lan.dhcpv6='disabled'
/etc/init.d/odhcpd disable
uci commit


# Disable RA and DHCPv6 so no IPv6 IPs are handed out:
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci commit dhcp
/etc/init.d/odhcpd restart

# You can now disable the LAN delegation:
uci set network.lan.delegate="0"
uci commit network
/etc/init.d/network restart

# You might as well disable odhcpd:
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop

# And finally you can delete the IPv6 ULA Prefix:
uci -q delete network.globals.ula_prefix
uci commit network
/etc/init.d/network restart

