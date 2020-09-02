#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
#set -x

. ../libShell/echo_color.lib

DOWNLOAD_DIR="downloads"

SUPPORTED_CMD="install"
SUPPORTED_TARGETS="FILEZILLA,SUBLIME,WIRESHARK,FFMPEG,VLC,INTEL_MICROCODE"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

FILEZILLA_NAME="filezilla"
SUBLIME_NAME="sublime-text"
INTEL_MICROCODE_NAME="intel-microcode"
WIRESHARK_NAME="wireshark"
FFMPEG_NAME="ffmpeg"
VLC_NAME="vlc"

apt_install_pkg()
{
    sudo apt-get -y install $1
}

install_VLC()
{
    apt_install_pkg ${VLC}
}

install_FFMPEG()
{
    apt_install_pkg ${FFMPEG_NAME}
}

install_WIRESHARK()
{
    apt_install_pkg ${WIRESHARK_NAME}
    apt_install_pkg ${WIRESHARK_NAME}-doc
}

install_INTEL_MICROCODE()
{
    apt_install_pkg ${INTEL_MICROCODE_NAME}
}

install_SUBLIME()
{
    apt_install_pkg ${SUBLIME_NAME}
}

install_FILEZILLA()
{
    apt_install_pkg ${FILEZILLA_NAME}
}

install_items_func()
{
    PKGS=${EXEC_ITEMS_LIST}
    pushd ${DOWNLOAD_DIR}
    PKGS_NUM=`echo ${PKGS}|awk -F"," '{print NF}'`
    for ((i=1;i<=${PKGS_NUM};i++)); do
        eval pkg='`echo ${PKGS}|awk -F, "{ print $"$i" }"`'
        exec_name=install_${pkg}
        ${exec_name}
    done
    popd
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c install -l \"${SUPPORTED_TARGETS}\""

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
        mkdir -p ${DOWNLOAD_DIR}
        install_items_func
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


 
