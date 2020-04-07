#!/bin/bash

set -o nounset
set -o errexit

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

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

	cp ./configs/Gestures.conf ${HOME}/.config/libinput-gestures.conf 

	sudo reboot
}

hide_wingpanel_func()
{
#	echo "Refer to: http://entornosgnulinux.com/2018/01/01/autohide-en-wingpanel-para-elementary-os-loki/ "
#	sudo apt-get install software-properties-common
#	sudo add-apt-repository ppa:yunnxx/elementary
#	sudo apt update
#	sudo apt install elementary-wingautohide
#	echoY "Add elementary-wingautohide to system startup:"
#	echo "Applications-->All Settings-->Startup"
#	echo 'Add new item with command "sh /usr/bin/wingautohide.sh"'
#	echo ""
#	echoY "Remove elementary-wingautohide:"
#	echo "sudo apt purge elementary-wingautohide"
#	echo ""

    sudo cp ./configs/hide_top_panel /usr/bin/hide_top_panel
    sudo chmod +x /usr/bin/hide_top_panel
    echoY "Add keyborad shortcut for command hide_top_panel."

}

install_tweaks_func()
{
	sudo apt-get install software-properties-common
	sudo add-apt-repository ppa:philip.scott/elementary-tweaks
	sudo apt-get update
	sudo apt-get install elementary-tweaks
}

fix_system_bugs_func()
{
#	sudo sed -i "s/^#DefaultTimeoutStartSec=/DefaultTimeoutStartSec=/" /etc/systemd/system.conf
#	sudo sed -i "s/^#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=20s/" /etc/systemd/system.conf
    sudo echo "options snd-hda-intel dmic_detect=0" >> /etc/modprobe.d/alsa-base.conf

	reboot
}

install_right_click_menu_func()
{
	sudo cp ./configs/folder-terminator.contract /usr/share/contractor/
}

cfg_swap_func()
{
    # refer to: https://help.ubuntu.com/community/SwapFaq#What_is_swappiness_and_how_do_I_change_it.3F
    echo "vm.swappiness=0" >> /etc/sysctl.conf
    cp ./configs/swap2ram.sh /usr/local/sbin/
}

install_cpu_cfg_tools_func()
{
    # install cpupower tools
    # refer to:
    # https://wiki.archlinux.org/index.php/CPU_frequency_scaling#cpupower-gui
    # https://unix.stackexchange.com/questions/341927/how-to-install-cpupower-on-ubuntu-14-04-kernel-4-6-0
    # https://github.com/vagnum08/cpupower-gui
    sudo apt-get install -y linux-tools-$(uname -r)
    sudo add-apt-repository ppa:erigas/cpupower-gui
    sudo apt-get update
    sudo apt-get install cpupower-gui

}

install_init_tools_func()
{
	sudo apt-get update
	sudo apt-get install software-properties-common
	sudo apt-get update

	sudo apt-get install git vim tree htop dnsutils gtkterm gnome-disk-utility

    # install time shift
	sudo add-apt-repository -y ppa:teejee2008/timeshift
	sudo apt-get update
	sudo apt-get install timeshift
}

print_usage_func()
{
    echoY "Usage: ./sysInit.sh <target>"
    echoC "Supported targets:"
    echo "[ sysUpgrade, initTools, cpupower, cfgSwap, rightClickMenu, fixBugs, tweaks, cfgWingpanel, touchPad, inputGroup, pinyin ]"
}

[ $# -lt 1 ] && print_usage_func && exit 1


case $1 in
	sysUpgrade) echoY "System upgrade..."
		is_root_func
		sudo apt-get update
		sudo apt-get dist-upgrade
		;;
	initTools) echoY "Install system initial tools..."
		is_root_func
		install_init_tools_func
		;;
    cpupower) echoY "Install cpupower and cpupower-gui..."
        install_cpu_cfg_tools_func
        ;;
    cfgSwap) echoY "Configuring swap ..."
		is_root_func
        cfg_swap_func
        ;;
	rightClickMenu) echoY "Install right click context menu..."
		install_right_click_menu_func
		;;
	fixBugs) echoY "Fixing system bugs..."
		fix_system_bugs_func
		;;
	tweaks) echoY "Install tweaks..."
		install_tweaks_func
		;;
	cfgWingpanel) echoY "Configuring wingpanel for autohide..."
		hide_wingpanel_func
		;;
	touchPad) echoY "Installing touchpad gestures..."
		install_touchpad_gestures_func
		;;
	inputGroup) echoY "Join into group of input."
		sudo gpasswd -a $USER input
		reboot
		;;
	pinyin) echoY "Installing pinyin input method..."
		install_pinyin_input_method_func
		;;
	*) echoR "Unsupported target:$1"
		print_usage_func
		;;
esac

