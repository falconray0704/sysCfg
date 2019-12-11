#!/bin/bash
set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../libShell/echo_color.lib

checkVersion_func()
{
    echoY "Check Yocto kernel version:"
    echoC 'bitbake -e virtual/kernel | grep "^PV"'
    echo ""
    echoY "Check Yocto kernel information of the kernel:"
    echoC 'bitbake -e <kernel_name> | grep "^PV"'
    echo ""
    echoY "Check Yocto kernel name:"
    echoC 'bitbake -e virtual/kernel | grep "^PN"'
}

print_help_func()
{
    echoY "Supported utils commands:"
    echoC "checkVersion"
}

[ $# -lt 1 ] && print_help_func && exit 1

case $1 in
    "checkVersion")
        checkVersion_func
        ;;
	*|-h) echoR "Unknow cmd: $1"
        print_help_func
        ;;
esac

