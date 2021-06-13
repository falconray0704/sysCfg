#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
#set -x

. ../libShell/echo_color.lib

source .env_host

DOWNLOAD_DIR="downloads"
RELEASE_BIN_FILE_NAME="frp_${VERSION_RELEASE_FRP}_linux_amd64.tar.gz" 
RELEASE_SRC_FILE_NAME="v${VERSION_RELEASE_FRP}.tar.gz" 

SUPPORTED_CMD="get,build"
SUPPORTED_TARGETS="releaseBin,releaseSrc,dockerImageServer"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

EXEC_CMD_TARGET=""


apt_install_pkg()
{
    sudo apt-get -y install $1
}

apt_uninstall_pkg()
{
    sudo apt remove --purge $1
}

exec_items_iterator()
{
    PKGS=${EXEC_ITEMS_LIST}
    #pushd ${DOWNLOAD_DIR}
    PKGS_NUM=`echo ${PKGS}|awk -F"," '{print NF}'`
    for ((i=1;i<=${PKGS_NUM};i++)); do
        eval pkg='`echo ${PKGS}|awk -F, "{ print $"$i" }"`'
        exec_name=${EXEC_CMD}_${pkg}
        EXEC_CMD_TARGET=${pkg}
        ${exec_name}
    done
}

get_items_func()
{
    exec_items_iterator
}

install_items_func()
{
    PKGS=${EXEC_ITEMS_LIST}
    #pushd ${DOWNLOAD_DIR}
    PKGS_NUM=`echo ${PKGS}|awk -F"," '{print NF}'`
    for ((i=1;i<=${PKGS_NUM};i++)); do
        eval pkg='`echo ${PKGS}|awk -F, "{ print $"$i" }"`'
        exec_name=install_${pkg}
        ${exec_name}
    done
    #popd
}

uninstall_items_func()
{
    PKGS=${EXEC_ITEMS_LIST}
    #pushd ${DOWNLOAD_DIR}
    PKGS_NUM=`echo ${PKGS}|awk -F"," '{print NF}'`
    for ((i=1;i<=${PKGS_NUM};i++)); do
        eval pkg='`echo ${PKGS}|awk -F, "{ print $"$i" }"`'
        exec_name=uninstall_${pkg}
        ${exec_name}
    done
    #popd
}

mkdirs_get_releaseBin()
{
    echoY "Preparing running dirs for ${EXEC_CMD} ${EXEC_CMD_TARGET} ..."
    if [ ! -d ${DOWNLOAD_DIR} ]
    then
    mkdir -p ${DOWNLOAD_DIR}
    fi
    echoG "Preparing running dirs for ${EXEC_CMD} ${EXEC_CMD_TARGET} success!"
}

get_releaseBin()
{
    echoY "Downloading ${VERSION_RELEASE_FRP} frp release ${RELEASE_BIN_FILE_NAME} ..."

    mkdirs_get_releaseBin
    
    pushd ${DOWNLOAD_DIR}
    if [ -f ${RELEASE_BIN_FILE_NAME} ]
    then
        set +e
        tar -zxf ${RELEASE_BIN_FILE_NAME}
        if [ $? -ne 0 ]
        then
            rm ${RELEASE_BIN_FILE_NAME}
            wget -c https://github.com/fatedier/frp/releases/download/v${VERSION_RELEASE_FRP}/${RELEASE_BIN_FILE_NAME}
        fi

        echoY "File ${RELEASE_BIN_FILE_NAME} already exsisted!"
        set -e
    else
        wget -c https://github.com/fatedier/frp/releases/download/v${VERSION_RELEASE_FRP}/${RELEASE_BIN_FILE_NAME}
    fi
    popd

    echoG "Downloading ${VERSION_RELEASE_FRP} frp success!"
    ls -al ${DOWNLOAD_DIR}
}

get_releaseSrc()
{
    echoY "Downloading ${VERSION_RELEASE_FRP} frp release source ${RELEASE_SRC_FILE_NAME} ..."

    mkdirs_get_releaseBin
    
    pushd ${DOWNLOAD_DIR}
    if [ -f ${RELEASE_SRC_FILE_NAME} ]
    then
        set +e
        tar -zxf ${RELEASE_SRC_FILE_NAME} -O > /dev/null 
        if [ $? -ne 0 ]
        then
            rm ${RELEASE_SRC_FILE_NAME}
            wget -c https://github.com/fatedier/frp/archive/refs/tags/${RELEASE_SRC_FILE_NAME}
        fi
        set -e
    else
        wget -c https://github.com/fatedier/frp/archive/refs/tags/${RELEASE_SRC_FILE_NAME}
    fi
    popd

    echoG "Downloading ${VERSION_RELEASE_FRP} frp source success!"
    ls -al ${DOWNLOAD_DIR}
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c get -l \"releaseBin,releaseSrc\""

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
    "get")
        get_items_func
        ;;
    "build")
        mkdir -p ${DOWNLOAD_DIR}
        uninstall_items_func
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


 
