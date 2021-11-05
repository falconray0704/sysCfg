#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
#set -x

export LIBSHELL_ROOT_PATH=$(cd ../libShell && pwd)
. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib

# Checking environment setup symbolic link and its file exists
if [ -L ".env_setup" ] && [ -f ".env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ./.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi

SUPPORTED_CMD="install,uninstall,cfg"
SUPPORTED_TARGETS="x11vnc"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

install_x11vnc()
{
    echoY "Installing x11vnc ..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        sudo apt-get -y remove vino
        sudo apt-get -y install x11vnc
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi

    echoG "Installed x11vnc success!"
}

uninstall_x11vnc()
{
    echoY "Uninstalling x11vnc..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        sudo systemctl stop x11vnc.service
        sudo systemctl disable x11vnc.service
        sudo systemctl daemon-reload

        sudo apt-get -y remove x11vnc
        sudo apt-get -y purge x11vnc

        sudo rm /lib/systemd/system/x11vnc.service
        sudo rm -rf /etc/x11vnc
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi

    echoG "Uninstalled x11vnc success!"
}


cfg_x11vnc()
{
    sudo mkdir /etc/x11vnc
    sudo x11vnc --storepasswd /etc/x11vnc/vncpwd
    sudo cp ./x11vnc.service /lib/systemd/system/x11vnc.service
    sudo systemctl daemon-reload
    sudo systemctl enable x11vnc.service
    sudo systemctl start x11vnc.service
    sudo systemctl status x11vnc.service
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c install -l \"x11vnc\""
    echoY "eg:\n./run.sh -c cfg -l \"x11vnc\""
    echoY "eg:\n./run.sh -c uninstall -l \"x11vnc\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
}

no_args="true"
while getopts "c:l:" opts
do
    case $opts in
        c)
              # cmd
              EXEC_CMD=$OPTARG
              ;;
        l)
              # items list
              EXEC_ITEMS_LIST=$OPTARG
              ;;
        :)
            echo "The option -$OPTARG requires an argument."
            exit 1
            ;;
        ?)
            echo "Invalid option: -$OPTARG"
            usage_func
            exit 2
            ;;
        *)    #unknown error?
              echoR "unkonw error."
              usage_func
              exit 1
              ;;
    esac
    no_args="false"
done

[[ "$no_args" == "true" ]] && { usage_func; exit 1; }
#[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1


case ${EXEC_CMD} in
    "install")
        install_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "uninstall")
        uninstall_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "cfg")
        srcInstall_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


