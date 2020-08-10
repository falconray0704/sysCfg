#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

# refer to https://www.raspberrypi.org/documentation/linux/kernel/building.md#default_configuration

. ../libShell/echo_color.lib

KERNEL=kernel7

piRoot=/mnt/n03/raspberrypi
kernelVersion=4.19
#kernelVersion=4.20
#kernelVersion=5.3
kernelPath=${piRoot}/kernels/${kernelVersion}
installPath=${kernelPath}/install/rpi-${kernelVersion}

sdCard_boot=/media/ray/PI_BOOT
sdCard_root=/media/ray/PI_ROOT

install_dependence()
{
    mkdir -p ${piRoot}

    pushd ${piRoot}
    git clone https://github.com/raspberrypi/tools.git
    popd

#    export PATH=$PATH:/${piRoot}/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin
    export PATH=$PATH:/${piRoot}/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin

    arm-linux-gnueabihf-gcc -v
}

build_kernel_func()
{

#    export PATH=$PATH:/$piRoot/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin
    export PATH=$PATH:/$piRoot/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin

    pushd ${kernelPath}/linux
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
    make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs -j 18

    popd
}

fetch_kernel_func()
{
    mkdir -p ${kernelPath}/install
    pushd ${kernelPath}
    git clone -b rpi-${kernelVersion}.y --depth=1 https://github.com/raspberrypi/linux
    popd
}

upgrade_sdcard_func() 
{
    sdcard=$1
    fsBoot=/mnt/piBoot
    fsRoot=/mnt/piRoot
    installPath=${fsRoot}

    set +o errexit
    sudo umount -f ${sdcard}*
    set -o errexit

    sudo mkdir -p ${fsBoot}
    sudo mkdir -p ${fsRoot}

    sudo mount ${sdcard}1 ${fsBoot}
    sudo mount ${sdcard}2 ${fsRoot}

    export PATH=$PATH:/${piRoot}/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin

    pushd ${kernelPath}/linux

    sudo PATH=$PATH:/${piRoot}/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=${installPath} modules_install 

    sudo cp ${fsBoot}/${KERNEL}.img ${fsBoot}/${KERNEL}-backup.img
    sudo cp arch/arm/boot/zImage ${fsBoot}/${KERNEL}.img
    sudo cp arch/arm/boot/dts/*.dtb ${fsBoot}/
    sudo cp arch/arm/boot/dts/overlays/*.dtb* ${fsBoot}/overlays/
    sudo cp arch/arm/boot/dts/overlays/README ${fsBoot}/overlays/

    sync
    popd

    set +o errexit
    sudo umount -f ${sdcard}*
    set -o errexit

}

tips_func()
{
    echoY "1) Configure kernel using bbr as default congestion control:"
    echo "Location:"
    echo "-> Networking support (NET [=y])"
    echo " -> Networking options"
    echo "  -> TCP/IP networking (INET [=y])"
    echo "   -> TCP: advanced congestion control (TCP_CONG_ADVANCED [=y])"
    echo "    -> Default TCP congestion control (<choice> [=y])"
    
#    echoY "2) Configure kernel enable multipath tcp:"

}

print_usage_func()
{
    echoY "Supported commands:"
    echo "fetch"
    echo "build"
    echo "upgrade </dev/sdcard-device>"
    echo ""
    tips_func
    echo ""
}

[ $# -lt 1 ] && echoR "Invalid args." && print_usage_func && exit 1

case $1 in
	"fetch") echoC "Kernel fetching..."
        fetch_kernel_func
	;;
	"build") echoC "Kernel building..."
        build_kernel_func
	;;
	"upgrade") echoC "Upgrade sdcard for kernel upgrade..."
        [ $# -lt 2 ] && echoR "Without sdcard device arg." && print_usage_func && exit 1
        upgrade_sdcard_func $2
	;;
    "tips") echoC "Tips for enable kernel features:"
        tips_func
    ;;
	*) echoR "Unknow cmd: $1"
        print_usage_func
esac


