#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
#set -x

. ../libShell/echo_color.lib

DOWNLOAD_DIR="downloads"

SUPPORTED_CMD="install"
SUPPORTED_TARGETS="FILEZILLA,SUBLIME,WIRESHARK,FFMPEG,VLC,GEDIT,TREE,HTOP,DNSUTILS,V4L_UTILS,SSHPASS,IPERF3,INTEL_MICROCODE,GIT,BASH_COMPLETION,PINYIN,TERMINATOR,REMMINA,XRDP,GTKTERM"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

FILEZILLA_NAME="filezilla"
SUBLIME_NAME="sublime-text"
INTEL_MICROCODE_NAME="intel-microcode"
WIRESHARK_NAME="wireshark"
FFMPEG_NAME="ffmpeg"
VLC_NAME="vlc"
GEDIT_NAME="gedit"
TREE_NAME="tree"
HTOP_NAME="htop"
DNSUTILS_NAME="dnsutils"
V4L_UTILS_NAME="v4l-utils"
SSHPASS_NAME="sshpass"
IPERF3_NAME="iperf3"
GIT_NAME="git"
BASH_COMPLETION_NAME="bash-completion"
PINYIN_NAME="pinyin"
TERMINATOR_NAME="terminator"
REMMINA_NAME="remmina"
XRDP_NAME="xrdp"
GTKTERM_NAME="gtkterm"

apt_install_pkg()
{
    sudo apt-get -y install $1
}

install_BASH_COMPLETION()
{
    apt_install_pkg ${BASH_COMPLETION_NAME}
}

install_GTKTERM()
{
    apt_install_pkg ${GTKTERM_NAME}
    sudo usermod -aG dialout $USER
    echoY "Reboot required for adding dialout group applying."
}

install_GIT()
{
    apt_install_pkg ${GIT_NAME}
}

install_TERMINATOR()
{
    apt_install_pkg ${TERMINATOR_NAME}
}

install_IPERF3()
{
    apt_install_pkg ${IPERF3_NAME}
}

install_SSHPASS()
{
    apt_install_pkg ${SSHPASS_NAME}
}

install_V4L_UTILS()
{
    apt_install_pkg ${V4L_UTILS_NAME}
}

install_DNSUTILS()
{
    apt_install_pkg ${DNSUTILS_NAME}
}

install_HTOP()
{
    apt_install_pkg ${HTOP_NAME}
}

install_TREE()
{
    apt_install_pkg ${TREE_NAME}
}

install_GEDIT()
{
    apt_install_pkg ${GEDIT_NAME}
}

install_VLC()
{
    apt_install_pkg ${VLC_NAME}
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

install_PINYIN()
{
	# refer to: https://leimao.github.io/blog/Ubuntu-Gaming-Chinese-Input/
	# Install fcitx input method system
	apt_install_pkg fcitx-bin
	# Install Google Pinyin Chinese input method
	apt_install_pkg fcitx-googlepinyin
	
	# https://kyooryoo.wordpress.com/2018/12/23/add-chinese-or-japanese-input-method-in-elementary-os-5-0-juno/
	apt_install_pkg fcitx-table-all fcitx fcitx-googlepinyin im-config
	#echoY "Run command for configure:"
       	#echoG "$ im-config"
	sudo im-config
	echoY "Reboot system for applying input method."
}

install_REMMINA()
{
    apt_install_pkg ${REMMINA_NAME}
}

install_XRDP()
{
    apt_install_pkg ${XRDP_NAME}
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


 
