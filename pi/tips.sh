#!/bin/bash
set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../libShell/echo_color.lib

config_swap_size_func()
{
    echo "How to configure system swap size:"
    echo "sudo vim /etc/dphys-swapfile"
}

restore_from_image_func()
{
    echo "How to restore:"
    echo "sudo umount /dev/disk1 /dev/disk2"
    echo "sudo dd bs=4k if=image.img of=/dev/disk status=progress"
}

backup_from_sdCard_func()
{
    echo "How to backup:"
    echo "sudo fdisk -l"
    echo "sudo bs=4M dd if=/dev/<sdcard device> of=image-\`date +%Y%m%d%H%M\`.img status=progress"
}

shrink_image_func()
{
    echo "How to shrink image file:"
    echo "wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh"
    echo "./pishrink.sh image.img"
}

system_deploy_func()
{
    echoY "How to deploy raspbian system with raw sdcard:"
    echoY "(1) Deploy official image."
    restore_from_image_func
    echoY "(2) Upgrade kernel with BBR enable."
    echo "./kernelUpgrade.sh upgrade /dev/<sdcard device without suffix. eg:/dev/sdc , not /dev/sdc1>"
    echoY "(3) Avoid no hdmi output in case drop power unexpectively."
    echo "Uncomment hdmi_force_hotplug=1 in /boot/config.txt"
    echoY "(4) Install basic tools."
    echo "sudo apt-get install git vim wget curl"
    echoY "(5) Enable BBR configs."
    echo "./enable_bbr.sh enable"
    echo "sudo reboot"
    echoY "(6) Install docker and docker-compose."
    echo "./docker.sh install"
    echo "./docker.sh compose"
}

print_help_func()
{
    echoY "Supported utils commands:"
    echoY "configSwapSize"
    echoY "restore"
    echoY "backup"
    echoY "shrink"
}

[ $# -lt 1 ] && print_help_func && exit 1

case $1 in
    "os") echoY "Deploy raspbian..."
        system_deploy_func
        ;;
	"configSwapSize") echoY "How to configure swap size ..."
        config_swap_size_func
        ;;
	"restore") echoY "Recovering ..."
        restore_from_image_func
        ;;
	"backup") echoY "Backup sdcard ..."
        backup_from_sdCard_func
        ;;
	"shrink") echoY "Shrink image ..."
        shrink_image_func
        ;;
	*|-h) echoR "Unknow cmd: $1"
        print_help_func
        ;;
esac

