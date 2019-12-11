#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

ARCH=$(arch)
RELEASE_ROOT_DIR="deployPkgs"
INSTALL_ROOT_PATH=${HOME}/${RELEASE_ROOT_DIR}/${ARCH}

SS_INSTALL_PATH=${INSTALL_ROOT_PATH}/ss

SS_SRV_DEPLOY_PATH=${HOME}

isCorrect="N"

ssServerIP="0.0.0.0"
ssServerPort=443
ssServerPassword="ss-redir"
ssRedirLocalPort=1080

get_ss_redir_config_args()
{
	echoY "Please input your ss server IP:"
	read ssServerIP
	echoY "Please input your ss server port:"
	read ssServerPort
	#echo "Please input your ss server password:"
	#read ssServerPassword
	echoY "Please input your ss-redir local port:"
	read ssRedirLocalPort

	echoY "Your server IP is: ${ssServerIP}"
	echoY "Your server Port is: ${ssServerPort}"
	#echo "Your server password is: ${ssServerPassword}"
	echoY "Your ss-redir local port is: ${ssRedirLocalPort}"

    isCorrect="N"
	echoY "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echoG "correct"
	else
		echoR "incorrect"
		exit 1
	fi
}

check_bbr_func()
{
    sysctl net.ipv4.tcp_available_congestion_control
    sysctl net.ipv4.tcp_congestion_control
    sysctl net.core.default_qdisc
    lsmod | grep bbr
}

build_ss_redir_configs()
{
    pushd ${SS_INSTALL_PATH}
    rm -rf ./tmpSSConfigs
    mkdir -p ./tmpSSConfigs
    cp ./config.json ./tmpSSConfigs/

	sed -i "s/0\.0\.0\.0/${ssServerIP}/" ./tmpSSConfigs/config.json
	sed -i "s/443/${ssServerPort}/" ./tmpSSConfigs/config.json
	sed -i "s/1080/${ssRedirLocalPort}/" ./tmpSSConfigs/config.json

    echoY "=== config.json is : ==="
    cat ./tmpSSConfigs/config.json
    echoY "========================"
    echo ""
    echoY "You can change default password in in ./tmpSSConfigs/config.json tmpSSConfigs/config.json before install service"
    echo ""
    echoY "========================"
    popd
}

make_ss_configs_func()
{
    get_ss_redir_config_args
    build_ss_redir_configs
}

install_ss_service_func()
{
    pushd ${SS_INSTALL_PATH}
    sudo mkdir -p /etc/shadowsocks-libev

    sudo cp ./ss-redir /usr/bin/
    sudo cp ./shadowsocks-libev-redir.service /lib/systemd/system/

    sudo cp ./tmpSSConfigs/config.json /etc/shadowsocks-libev/
    popd
}

uninstall_ss_service_func()
{
    disable_ss_service_func

    sudo rm -rf /etc/shadowsocks-libev_bak

    sudo rm /lib/systemd/system/shadowsocks-libev-redir.service
    sudo rm /usr/bin/ss-redir
}

enable_ss_service_func()
{
	sudo systemctl enable shadowsocks-libev-redir.service
	sudo systemctl start shadowsocks-libev-redir.service
}

disable_ss_service_func()
{
	sudo systemctl stop shadowsocks-libev-redir.service
	sudo systemctl disable shadowsocks-libev-redir.service
}

deploy_docker_server_func()
{
    rm -rf ${SS_SRV_DEPLOY_PATH}/ssSrv
    cp -a ./scripts/ssSrv ${SS_SRV_DEPLOY_PATH}/
    pushd ${SS_SRV_DEPLOY_PATH}/ssSrv
    sed -i "s/ss_arch/ss_${ARCH}/" ./docker-compose.yml
    popd
}

usage_func()
{
    echoY "./run.sh <cmd> <target>"
    echo ""
    echoY "Supported cmd:"
    echo "[ mk, install, uninstall, enable, disable, deploy, check ]"
    echoY "Supported targets:"
    echo "[ cfgs, ssredir, server, bbr ]"
}

[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
	mk)
        if [ $2 == "cfgs" ]
        then
            echoY "Make ss config files..."
            make_ss_configs_func
        else
            echoR "mk command only targets: [ cfgs ]"
        fi
	;;
	install)
        if [ $2 == "ssredir" ]
        then 
            echoY "Installing ss-redir ..."
            install_ss_service_func
            enable_ss_service_func
        else
            echoR "install command only targets: [ ssredir ]"
        fi
	;;
	uninstall)
        if [ $2 == "ssredir" ]
        then
            echoY "Uninstall ss-redir service..."
            uninstall_ss_service_func
        else
            echoR "uninstall command only targets: [ ssredir ]"
        fi
	;;
	enable)
        if [ $2 == "ssredir" ]
        then
            echoY "Enable ss-redir service..."
            enable_ss_service_func
        else
            echoR "enable command only targets: [ ssredir ]"
        fi
	;;
	disable)
        if [ $2 == "ssredir" ]
        then
            echoY "Disable ss-redir service..."
            disable_ss_service_func
        else
            echoR "enable command only targets: [ ssredir ]"
        fi
	;;
	deploy)
        if [ $2 == "server" ]
        then
            echoY "Deploying ss server with docker ..."
            deploy_docker_server_func
        else
            echoR "deploy command only targets: [ server ]"
        fi
	;;
	check)
        if [ $2 == "bbr" ]
        then
            echoY "Checking for enable bbr..."
            check_bbr_func
        else
            echoR "check command only targets: [ bbr ]"
        fi
	;;
	*) echo "unknow cmd"
        usage_func
esac

