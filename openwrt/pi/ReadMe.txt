
1. Download resources:
    ./host_01_fetch_init_packages.sh


2. Install openwrt with TF card:
export TARGET_DEV="/dev/<disk>"
export PI_BOOT_DEV="${TARGET_DEV}1"
export PI_ROOT_DEV="${TARGET_DEV}2"

sudo umount ${PI_BOOT_DEV} ${PI_ROOT_DEV}
sudo dd if=openwrt-19.07.7-brcm2708-bcm2710-rpi-3-ext4-factory.img of=${TARGET_DEV} bs=2M
sudo mount ${PI_ROOT_DEV} /mnt/piRoot
sudo cp -a piInit /mnt/piRoot/
sync
sudo umount ${PI_ROOT_DEV}


 


