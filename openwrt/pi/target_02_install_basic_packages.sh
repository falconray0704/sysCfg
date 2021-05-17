#!/bin/ash


opkg update
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade

opkg install vim-full diffutils
opkg install iperf3
opkg install kmod-usb-net-asix-ax88179
opkg install kmod-tcp-bbr
opkg install kmod-usb-net-rndis usb-modeswitch


opkg remove dnsmasq
opkg install dnsmasq-full

#reboot

