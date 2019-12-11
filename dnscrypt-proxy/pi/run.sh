#!/bin/bash

set -e
#set -x

. ../../libShell/echo_color.lib

ARCH=$(arch)

RELEASE_ROOT_DIR="deployPkgs"
INSTALL_ROOT_PATH=${HOME}/${RELEASE_ROOT_DIR}/${ARCH}

check_dns_func()
{
    ss -lp 'sport = :domain'
}

uninstall_systemDNS_func()
{
    sudo apt-get remove dnsmasq
    sudo apt-get purge dnsmasq

    sudo apt-get remove --auto-remove avahi-daemon
    sudo apt-get purge --auto-remove avahi-daemon

    sudo systemctl stop systemd-resolved.service
    sudo systemctl disable systemd-resolved.service

    # prevent /etc/resolv.conf using gateway's dns
	sudo sed -i '/^static domain_name_servers=.*/d' /etc/dhcpcd.conf
	sudo sed -i '/^#static domain_name_servers=192.168.1.1$/a\static domain_name_servers=127.0.0.1' /etc/dhcpcd.conf

}

config_func()
{

    pushd ${INSTALL_ROOT_PATH}/dnscrypt-proxy
    cp example-dnscrypt-proxy.toml dnscrypt-proxy.toml
	sed -i "s/^# server_names =.*/server_names = \['cisco', 'google', 'scaleway-fr', 'yandex', 'cloudflare'\]/" dnscrypt-proxy.toml
	sed -i "s/^listen_addresses =.*/listen_addresses = \['127.0.0.1:53'\]/" dnscrypt-proxy.toml
	sed -i "s/.*ignore_system_dns =.*/ignore_system_dns = true/" dnscrypt-proxy.toml
	sed -i "s/.*force_tcp =.*/force_tcp = true/" dnscrypt-proxy.toml
	sed -i "s/^timeout =.*/timeout = 3000/" dnscrypt-proxy.toml

    echoY "Downloading public-resolvers..."
    set +e
    ./dnscrypt-proxy
    set -e

    popd
}

install_from_docker_installer_func()
{
    echoY "Installing dnscrypt-proxy to your ${INSTALL_ROOT_PATH}..."
    sudo rm -rf ${INSTALL_ROOT_PATH}/dnscrypt-proxy
    mkdir -p ${INSTALL_ROOT_PATH}
    docker run --rm -it -v ${INSTALL_ROOT_PATH}:/target rayruan/dnscrypt-proxy_${ARCH}:installer 
    USER_NAME=$(id -un)
    GROUP_NAME=$(id -gn)
    #echo "### ${USER_NAME}"
    sudo chown -hR ${USER_NAME}:${GROUP_NAME} ${INSTALL_ROOT_PATH}/dnscrypt-proxy
    cp dnsCryptSrc/public-resolvers.md* ${INSTALL_ROOT_PATH}/dnscrypt-proxy/

    config_func
    cp ./dnsCryptSrc/public* ${INSTALL_ROOT_PATH}/dnscrypt-proxy/
}

install_service_func()
{
	sudo sed -i '/^static domain_name_servers=.*/d' /etc/dhcpcd.conf
	sudo sed -i '/^#static domain_name_servers=192.168.1.1$/a\static domain_name_servers=127.0.0.1' /etc/dhcpcd.conf

    pushd ${INSTALL_ROOT_PATH}/dnscrypt-proxy
    sudo ./dnscrypt-proxy -service install
    popd
}

uninstall_service_func()
{
    pushd ${INSTALL_ROOT_PATH}/dnscrypt-proxy
    sudo ./dnscrypt-proxy -service stop
    sudo ./dnscrypt-proxy -service uninstall
    popd

	sudo sed -i '/^static domain_name_servers=.*/d' /etc/dhcpcd.conf
}


usage_func()
{
    echo "./run.sh <cmd> <target>"
    echo ""
    echo "Supported cmd:"
    echo "[ check, uninstall, mk, install, uninstall ]"
    echo ""
    echo "Supported target:"
    echo "[ sysDNS, cfgs, dns, service ]"
}

[ $# -lt 2 ] && echo "Invalid args count:$# " && usage_func && exit 1

case $1 in
    check) echoY "Checking local $2 service ..."
        if [ $2 == "sysDNS" ] 
        then
            check_dns_func
        else
            echoR "Unknow target:$2, only support checking targets [sysDNS]."
            usage_func
        fi
        ;;
    mk) echoY "Making configs of $2"
        if [ $2 == "cfgs" ]
        then
            config_func
        else
            echoR "Unknow target:$2, only support mk targets [ cfgs ]."
        fi
        ;;
    install) echoY "Installing..."
        if [ $2 == "dns" ] 
        then
            #install_from_docker_installer_func
            echoY "Unsupport install from docker installer now, please install relPkgs."
        elif [ $2 == "service" ]
        then
            echoY "Installing dnscrypt-proxy service..."
            install_service_func
        else
            echoR "Unknow target:$2, only support installing targets [dns, service]."
        fi
        echoG "Install $2 finished."
        ;;
    uninstall) echoY "Uninstalling..."
        if [ $2 == "sysDNS" ] 
        then
            uninstall_systemDNS_func
        elif [ $2 == "dns" ] 
        then
            echoY "Uinstalling dnscrypt-proxy service ..."
            sudo rm -rf ${INSTALL_ROOT_PATH}/dnscrypt-proxy
        elif [ $2 == "service" ]
        then
            echoY "Installing dnscrypt-proxy service..."
            uninstall_service_func
        else
            echoR "Unknow target:$2, only support uninstalling targets [dns, service]."
        fi
        echoG "Uninstall $2 finished."
        ;;
    *) echo "Unsupported cmd:$1."
        usage_func
        exit 1
esac

exit 0

