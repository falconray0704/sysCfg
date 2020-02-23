#!/bin/bash

set -o nounset
set -o errexit

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

install_pinyin_input_method_func()
{
	# refer to: https://leimao.github.io/blog/Ubuntu-Gaming-Chinese-Input/
	# Install fcitx input method system
	sudo apt-get -y install fcitx-bin
	# Install Google Pinyin Chinese input method
	sudo apt-get -y  install fcitx-googlepinyin
	
	# https://kyooryoo.wordpress.com/2018/12/23/add-chinese-or-japanese-input-method-in-elementary-os-5-0-juno/
	sudo apt-get install fcitx-table-all
	sudo apt-get install fcitx fcitx-googlepinyin
	sudo apt-get install im-config
	#echoY "Run command for configure:"
       	#echoG "$ im-config"
	sudo im-config
	reboot
}

install_touchpad_gestures_func()
{
	INSTALL_ROOT=${HOME}/installGestures
	mkdir -p ${INSTALL_ROOT}
	pushd ${INSTALL_ROOT}

	echoY "Refer to: https://www.youtube.com/watch?v=uxajYK6kwfg"
	echoY "Refer to: https://medium.com/@s0rata/gesture-setup-on-elementary-os-fce53997a50"

	echoY "Install https://github.com/bulletmark/libinput-gestures :"
	sudo apt-get install xdotool wmctrl
	sudo apt-get install libinput-tools
	sudo apt-get install python3 python3-setuptools python3-gi python-gobject
	rm -rf libinput-gestures
	git clone https://github.com/bulletmark/libinput-gestures.git
	pushd libinput-gestures
	sudo ./libinput-gestures-setup install
	# or sudo make install
	./libinput-gestures-setup autostart
	./libinput-gestures-setup start
	popd
	
	
	echoY "Install https://gitlab.com/cunidev/gestures :"
	sudo apt install python3 python3-setuptools xdotool python3-gi libinput-tools python-gobject
	rm -rf gestures
	git clone https://gitlab.com/cunidev/gestures
	pushd gestures
	sudo python3 setup.py install
	popd

	popd

	sudo reboot
}

auto_hide_wingpanel_func()
{
	echo "Refer to: http://entornosgnulinux.com/2018/01/01/autohide-en-wingpanel-para-elementary-os-loki/ "
	sudo apt-get install software-properties-common
	sudo add-apt-repository ppa:yunnxx/elementary
	sudo apt update
	sudo apt install elementary-wingautohide
	echoY "Add elementary-wingautohide to system startup:"
	echo "Applications-->All Settings-->Startup"
	echo 'Add new item with command "sh /usr/bin/wingautohide.sh"'
	echo ""
	echoY "Remove elementary-wingautohide:"
	echo "sudo apt purge elementary-wingautohide"
	echo ""
}

install_init_tools_func()
{
	sudo apt-get install git vim tree htop dnsutils
}

install_tweaks_func()
{
	sudo apt-get install software-properties-common
	sudo add-apt-repository ppa:philip.scott/elementary-tweaks
	sudo apt-get update
	sudo apt-get install elementary-tweaks
}

print_usage_func()
{
    echoY "Usage: ./sysInit.sh <target>"
    echoC "Supported targets:"
    echo "[ sysUpgrade, tweaks, initTools, cfgWingpanel, inputGroup, touchPad, pinyin ]"
}

[ $# -lt 1 ] && print_usage_func && exit 1


case $1 in
	sysUpgrade) echoY "System upgrade..."
		is_root_func
		sudo apt-get update
		sudo apt-get dist-upgrade
		;;
	tweaks) echoY "Install tweaks..."
		install_tweaks_func
		;;
	initTools) echoY "Install system initial tools..."
		is_root_func
		install_init_tools_func
		;;
	cfgWingpanel) echoY "Configuring wingpanel for autohide..."
		is_root_func
		auto_hide_wingpanel_func
		;;
	inputGroup) echoY "Join into group of input."
		sudo gpasswd -a $USER input
		reboot
		;;
	touchPad) echoY "Installing touchpad gestures..."
		install_touchpad_gestures_func
		;;
	pinyin) echoY "Installing pinyin input method..."
		install_pinyin_input_method_func
		;;
	*) echoR "Unsupported target:$1"
		print_usage_func
		;;
esac

