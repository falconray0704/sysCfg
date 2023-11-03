#!/bin/ash

source ./.env_target


# /etc/config/network
uci set network.${USB_INTERFACE_WAN_NAME}=interface
uci set network.${USB_INTERFACE_WAN_NAME}.proto='dhcp'
uci set network.${USB_INTERFACE_WAN_NAME}.device='eth1'
uci set network.${USB_INTERFACE_WAN_NAME}.hostname='*'
uci set network.${USB_INTERFACE_WAN_NAME}.delegate='0'

uci changes network
uci commit network

# /etc/config/firewall
#uci del firewall.cfg03dc81.network
#uci add_list firewall.cfg03dc81.network='wan'
#uci add_list firewall.cfg03dc81.network='wan6'
#uci add_list firewall.cfg03dc81.network='WAN_DHCP_f32b'
uci add_list firewall.@zone[1].network=${USB_INTERFACE_WAN_NAME}

uci changes firewall
uci commit firewall

