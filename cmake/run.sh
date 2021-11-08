#!/bin/bash

# refer to https://apt.kitware.com/


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

SUPPORTED_CMD="install,uninstall"
SUPPORTED_TARGETS="cmake"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

install_cmake()
{
    echoY "Installing cmake ..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        rm -rf kitware-archive.sh
        wget -O kitware-archive.sh https://apt.kitware.com/kitware-archive.sh
        sudo chmod a+x kitware-archive.sh

        uninstall_old_cmake_ubuntu
        sudo apt-get update

        sudo ./kitware-archive.sh
        sudo apt-get -y install cmake
        sudo apt-get update
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi

    echoG "Installed cmake success!"
}

uninstall_old_cmake_ubuntu()
{
        set +e
        sudo apt-get -y purge cmake kitware-archive-keyring
        sudo apt autoremove -y
        sudo apt-add-repository -y -r "deb https://apt.kitware.com/ubuntu/ bionic main"
        sudo rm -rf /etc/apt/sources.list.d/kitware.list
        set -e
}

uninstall_cmake()
{
    echoY "Uninstalling cmake..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        uninstall_old_cmake_ubuntu
        sudo apt-get update
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi

    echoG "Uninstalled cmake success!"
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c install -l \"cmake\""
    echoY "eg:\n./run.sh -c uninstall -l \"cmake\""

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
    *)
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


