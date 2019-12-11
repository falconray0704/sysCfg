#!/bin/bash

set -o nounset
set -o errexit

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

check_bbr_func()
{
    echo "Current configuration: "
    sysctl net.ipv4.tcp_available_congestion_control
    sysctl net.ipv4.tcp_congestion_control
    sysctl net.core.default_qdisc
}

# apply new config
enable_bbr_func()
{
    sed -i '/### bbr/d' /etc/sysctl.conf
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo '### bbr'
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1

}

print_usage_func()
{
    echoY "Supported operations:"
    echo "check"
    echo "enable"
    echo ""
}

[ $# -lt 1 ] && print_usage_func && exit 1

case $1 in
    "check") echoY "Checking current system BBR setting..."
        check_bbr_func
        ;;
    "enable") echoY "Configuring current system for BBR enable..."
        is_root_func
        enable_bbr_func
        ;;
    *) echoR "Unsupported command: $1"
        print_usage_func
        ;;
esac





