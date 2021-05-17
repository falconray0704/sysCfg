#!/bin/ash

source ./.env_target

get_iether_MAC()
{
    local MAC_val=$(ip link show $1 | awk '/ether/ {print $2}')
    echo ${MAC_val}
}

uci del dhcp.lan.ignore
uci del dhcp.lan.start
uci del dhcp.lan.limit
uci del dhcp.lan.leasetime
uci del dhcp.lan.dhcpv6
uci del dhcp.lan.ra

uci changes dhcp
uci commit dhcp


uci set network.lan.ipaddr=${TARGET_GATEWAY_IP}
uci del network.lan.dns
uci del network.lan.gateway

uci set network.${USB_INTERFACE_WAN_NAME}='interface'
uci set network.${USB_INTERFACE_WAN_NAME}.ifname=${USB_INTERFACE_WAN_DEV}
uci set network.${USB_INTERFACE_WAN_NAME}.proto=${USB_INTERFACE_WAN_PROTO}
uci set network.${USB_INTERFACE_WAN_NAME}.macaddr=$(get_iether_MAC ${USB_INTERFACE_WAN_DEV}) 

uci changes network
uci commit network


uci add_list firewall.@zone[1].network=${USB_INTERFACE_WAN_NAME}
uci changes firewall
uci commit firewall

#reboot


