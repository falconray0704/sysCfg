#!/bin/bash

# refer to:
# https://hub.docker.com/r/alexandreoda/vlc
# docker pull alexandreoda/vlc

set -e
#set -x

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

TMP_DIR="tmp"

APDEV_NAME="piAPDev"
APDEV_MAC="macAddr"

APOUT_NAME=""
APOUT_MAC="macAddr"

#apMac="xx:xx:xx:xx:xx:xx"
#apName=piAPDev
apCh=6
apSSID=piAP
apPwd=piAP

ssIP="127.0.0.1"
ssPort=9000
ssrListenPort=62586
#ssEncryptMethod="aes-256-cfb"

ssTcpFast="N"
sstPort=9001


ARCH=$(arch)

RELEASE_ROOT_DIR="deployPkgs"
INSTALL_ROOT_PATH=${HOME}/${RELEASE_ROOT_DIR}/${ARCH}

rename_AP_device_func()
{

    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP:"
    read APDEV_NAME
    APDEV_MAC=$(get_iether_MAC ${APDEV_NAME})
    if [ ${APDEV_MAC} ]
    then
        echo "device mac: ${APDEV_MAC}"
        cp ./cfgs/70-piAPDev_network_interfaces.rules ./${TMP_DIR}/
        sed -i "s/macAddr/${APDEV_MAC}/" ./${TMP_DIR}/70-piAPDev_network_interfaces.rules
        sudo cp ./${TMP_DIR}/70-piAPDev_network_interfaces.rules /etc/udev/rules.d/
        cat ./${TMP_DIR}/70-piAPDev_network_interfaces.rules
    else
        echoR "Can not get the mac address of ${APDEV_NAME}"
    fi
}

rename_AP_out_func()
{

    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP out:"
    read APOUT_NAME
    APOUT_MAC=$(get_iether_MAC ${APOUT_NAME})
    if [ ${APOUT_MAC} ]
    then
        echo "device mac: ${APOUT_MAC}"
        cp ./cfgs/70-piAPOut_network_interfaces.rules ./${TMP_DIR}/
        sed -i "s/macAddr/${APOUT_MAC}/" ./${TMP_DIR}/70-piAPOut_network_interfaces.rules
        sudo cp ./${TMP_DIR}/70-piAPOut_network_interfaces.rules /etc/udev/rules.d/
        cat ./${TMP_DIR}/70-piAPOut_network_interfaces.rules
    else
        echoR "Can not get the mac address of ${APOUT_NAME}"
    fi
}

unmanaged_devices()
{
    echoY "Preparing config file for ${APDEV_NAME} run as AP node with static IP..."
	cp /etc/dhcpcd.conf ./${TMP_DIR}/
	sed -i '$a\interface piAPDev' ./${TMP_DIR}/dhcpcd.conf
	sed -i '$a\static ip_address=192\.168\.11\.1\/24' ./${TMP_DIR}/dhcpcd.conf
	sed -i '$a\nohook wpa_supplicant' ./${TMP_DIR}/dhcpcd.conf

}

get_hostapd_args_func()
{
	#iw list
	#lshw -C network
#    sudo lshw -C network | grep -E "-network|description|logical name|serial"
#    echoY "Please input the name of device which use for AP:"
#    read APDEV_NAME
    APDEV_MAC=$(get_iether_MAC ${APDEV_NAME})

    echoC "MAC of ${APDEV_NAME} is: ${APDEV_MAC}"
	echoY "Please input your AP channel number(eg:6):"
	read apCh
	echoY "Please input your AP SSID:"
	read apSSID
	echoY "Please input your AP password:"
	read apPwd


	echo "Your AP name is: ${APDEV_NAME}"
	echo "Your AP Mac address is: ${APDEV_MAC}"
	echo "Your AP channel is: ${apCh}"
	echo "Your AP SSID is: ${apSSID}"
	echo "Your AP password is: ${apPwd}"

	echoY "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echo "correct"
	else
		echo "incorrect"
		exit 1
	fi
}

config_hostapd_func()
{
	#cmd="s/interface/interface=${apName}"
	#echo "cmd:${cmd}"

    echoY "Preparing config file for hostapd..."
	cp ./cfgs/hostapd.conf ./${TMP_DIR}/hostapd.conf
	sed -i "s/interface=wlan0/interface=${APDEV_NAME}/g" ./${TMP_DIR}/hostapd.conf
	sed -i "s/ssid=piAP/ssid=${apSSID}/g" ./${TMP_DIR}/hostapd.conf
	sed -i "s/channel=6/channel=${apCh}/g" ./${TMP_DIR}/hostapd.conf
	sed -i "s/wpa_passphrase=piAP/wpa_passphrase=${apPwd}/g" ./${TMP_DIR}/hostapd.conf

	echoC "=== after config ./${TMP_DIR}/hostapd.conf start ==="
	cat ./${TMP_DIR}/hostapd.conf
	echoC "=== after config ./${TMP_DIR}/hostapd.conf end   ==="

	#sudo cp ./${TMP_DIR}/hostapd.conf /etc/hostapd/
}

config_AP_service_func()
{
    echo "Preparing systemd service config file for hostapd..."
	cp cfgs/AP.service ./${TMP_DIR}/
	sed -i "s/wlan0/${APDEV_NAME}/g" ./${TMP_DIR}/AP.service

	echoC "=== after config ./${TMP_DIR}/AP.service start ==="
	cat ./${TMP_DIR}/AP.service
	echoC "=== after config ./${TMP_DIR}/AP.service end   ==="
}

cfg_AP_device_func()
{
    get_hostapd_args_func
    unmanaged_devices
    config_hostapd_func
    config_AP_service_func
}

enable_AP_service_func()
{
	sudo systemctl daemon-reload
	sudo systemctl enable AP.service
}

install_AP_device_func()
{
	sudo cp ./${TMP_DIR}/dhcpcd.conf /etc/dhcpcd.conf
	sudo cp ./${TMP_DIR}/hostapd.conf /etc/hostapd/
	sudo cp ./${TMP_DIR}/AP.service /lib/systemd/system/

    enable_AP_service_func

}

disable_AP_service_func()
{
	sudo systemctl disable AP.service
	sudo systemctl daemon-reload
}

release_AP_IP_func()
{
	sudo sed -i '/interface piAPDev' /etc/dhcpcd.conf
	sudo sed -i '/static ip_address=192\.168\.11\.1\/24' /etc/dhcpcd.conf
	sudo sed -i '/nohook wpa_supplicant' /etc/dhcpcd.conf
}

uninstall_AP_device_func()
{
    disable_AP_service_func
	sudo rm /lib/systemd/system/AP.service 

    release_AP_IP_func
	sudo rm /etc/hostapd/hostapd.conf 
}

config_AP_DHCP_func()
{
    echoY "Preparing config file for DHCP server for ${APDEV_NAME} AP node."
    cp ./cfgs/dhcpd.conf ./${TMP_DIR}/
    cp ./cfgs/isc-dhcp-server ./${TMP_DIR}/

	sed -i "s/INTERFACES=\"\"/INTERFACES=\"${APDEV_NAME}\"/" ./${TMP_DIR}/isc-dhcp-server

	echoC "=== after config ./${TMP_DIR}/isc-dhcp-server start ==="
	cat ./${TMP_DIR}/isc-dhcp-server
	echoC "=== after config ./${TMP_DIR}/isc-dhcp-server end   ==="
}

enable_DHCP_service_func()
{
    #sudo systemctl start isc-dhcp-server.service
    sudo systemctl enable isc-dhcp-server.service
    sudo systemctl restart isc-dhcp-server.service
}

install_AP_DHCP_func()
{
    sudo cp ./${TMP_DIR}/dhcpd.conf /etc/dhcp/dhcpd.conf
    sudo cp ./${TMP_DIR}/isc-dhcp-server /etc/default/

    enable_DHCP_service_func
}

disable_DHCP_service_func()
{
    sudo systemctl stop isc-dhcp-server.service
    sudo systemctl disable isc-dhcp-server.service
}

uninstall_AP_DHCP_func()
{
    disable_DHCP_service_func

    sudo rm /etc/dhcp/dhcpd.conf
    sudo rm /etc/default/
}


config_AP_DNS_func()
{
    pushd ${INSTALL_ROOT_PATH}/dnscrypt-proxy
	sed -i "s/^listen_addresses =.*/listen_addresses = \['127.0.0.1:53', '192.168.11.1:53'\]/" dnscrypt-proxy.toml
    popd
}

install_AP_DNS_func()
{
    pushd ${INSTALL_ROOT_PATH}/dnscrypt-proxy
    sudo ./dnscrypt-proxy -service restart
    popd
}

uninstall_AP_DNS_func()
{
    pushd ${INSTALL_ROOT_PATH}/dnscrypt-proxy
	sed -i "s/^listen_addresses =.*/listen_addresses = \['127.0.0.1:53'\]/" dnscrypt-proxy.toml
    sudo ./dnscrypt-proxy -service restart
    popd
}

get_iptable_args_func()
{
    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP out:"

    read APOUT_NAME
    APOUT_MAC=$(get_iether_MAC ${APOUT_NAME})

	echo "Your AP out name is: ${APOUT_NAME}"
	echo "Your AP out Mac address is: ${APOUT_MAC}"

	echoY "Please input your ss server IP:"
	read ssIP
	echoY "Please input your ss-redir local port:"
	read ssrListenPort

	echo "Your server IP is: ${ssIP}"
	echo "Your ss-redir local port is: ${ssrListenPort}"
}

enableAP_ss_forward()
{

	sudo iptables -t nat -N SHADOWSOCKS

	sudo iptables -t nat -A SHADOWSOCKS -d ${ssIP} -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

	sudo iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports ${ssrListenPort}
	sudo iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS
	sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS

}

ss_AP_forward_startup_config()
{
#	sudo lshw -C network | grep -E "-network|description|logical name|serial"

	#echo "Please input your AP device Name:"
	#read apName
#	echo "Please input your output deviceName(eg:eth0):"
#	read outInterface

	echoY "All packets of ${APDEV_NAME} will be forward to: ${APOUT_NAME}"

	echoY "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echoG "Continue to config iptable rules...."
	else
		echoR "incorrect"
		exit 1
	fi

	sudo iptables -t nat -A POSTROUTING -o ${APOUT_NAME} -j MASQUERADE
	sudo iptables -A FORWARD -i ${APOUT_NAME} -o ${APDEV_NAME} -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i ${APDEV_NAME} -o ${APOUT_NAME} -j ACCEPT

    enableAP_ss_forward

	sudo sh -c "iptables-save > ./${TMP_DIR}/iptables.ipv4.nat"

}

config_iptable_func()
{
    get_iptable_args_func
    ss_AP_forward_startup_config
}


install_iptable_func()
{
	sudo cp ./${TMP_DIR}/iptables.ipv4.nat /etc/iptables.ipv4.nat
    sudo cp ./cfgs/iptables /etc/network/if-up.d/

}

uninstall_iptable_func()
{
	sudo rm /etc/iptables.ipv4.nat
    sudo rm /etc/network/if-up.d/iptables 
}

usage_func()
{
    echoY "./configure.sh <cmd> <target>"
    echo ""
    echoY "Supported cmd:"
    echo "[ install, rename, cfg, uninstall ]"
    echo ""
    echoY "Supported target:"
    echo "[ dep, devAP, devOut, apDHCP, apDNS, iptable ]"
}


[ $# -lt 2 ] && echoR "Invalid args count:$# " && usage_func && exit 1

mkdir -p ${TMP_DIR}

case $1 in
    install) echoY "Installing AP dependence..."
        if [ $2 == "dep" ]
        then
            sudo apt-get -y install lshw hostapd isc-dhcp-server
        elif [ $2 == "devAP" ]
        then
            install_AP_device_func

            echoG "Install finished..."
            echoY "Press any key to reboot system"
            read rb
            sudo reboot
        elif [ $2 == "apDHCP" ]
        then
            install_AP_DHCP_func
        elif [ $2 == "apDNS" ]
        then
            install_AP_DNS_func
        elif [ $2 == "iptable" ]
        then
            install_iptable_func
            echoG "Install $2 finished..."
            echoY "Press any key to reboot system"
            read rb
            sudo reboot
        else
            echoR "Command install only support targets [ dep, devAP, apDHCP, apDNS, iptable ]."
        fi
        ;;
    rename) echoY "Renaming AP device name to piAPDev..."
        if [ $2 == "devAP" ]
        then
            rename_AP_device_func
        elif [ $2 == "devOut" ]
        then
            rename_AP_out_func
        else
            echoR "Command rename only support targets: [ devAP, devOut ]."
        fi
        ;;
    cfg) echoY "Making configs for $2..."
        if [ $2 == "devAP" ]
        then
            cfg_AP_device_func
        elif [ $2 == "apDHCP" ]
        then
            config_AP_DHCP_func
        elif [ $2 == "apDNS" ]
        then
            config_AP_DNS_func
        elif [ $2 == "iptable" ]
        then
            config_iptable_func
        else
            echoR "Command cfg only support targets [ devAP, apDNS, iptable ]."
        fi
        ;;
    uninstall) echoY "Uninstalling $2 ..."
        if [ $2 == "devAP" ]
        then
            uninstall_AP_device_func
            echoG "Uninstall $2 finished..."
            echoY "Press any key to reboot system"
            read rb
            sudo reboot
        elif [ $2 == "apDHCP" ]
        then
            uninstall_AP_DHCP_func
            echoG "uninstall $2 finished..."
            echoY "press any key to reboot system"
            read rb
            sudo reboot
        elif [ $2 == "apDNS" ]
        then
            uninstall_AP_DNS_func
        elif [ $2 == "iptable" ]
        then
            uninstall_iptable_func
        else
            echoR "Command uninstall only support targets [ devAP, apDHCP, apDNS, iptable ]."
        fi
        ;;
    *) echo "Unsupported cmd:$1."
        usage_func
        exit 1
esac

exit 0

