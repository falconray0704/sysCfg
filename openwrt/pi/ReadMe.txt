
# refer to:
https://openwrt.org/docs/guide-user/services/dns/dnscrypt_dnsmasq_dnscrypt-proxy2
https://github.com/openwrt/packages/blob/master/net/shadowsocks-libev/README.md#recipes
https://openwrt.org/docs/guide-user/services/proxy/shadowsocks

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

3. Launch Pi with TF card without network cable connecting.

4. Enable ssl for opkg:
    ./target_01_enable_ssl_for_opkg.sh
    reboot

5. Connect network cable to LAN.

6. Install basic packages:
    ./target_02_install_basic_packages.sh
    reboot

7. Install dnscrypt-proxy:
    ./target_03_install_dnscrypt_proxy.sh
    reboot

8. Plug usb network adapter for working as WAN.

9. Config usb network adapter as WAN, and native eth0 as LAN:
    ./target_04_reconfig_wan_lan_for_rounter.sh
    reboot

10. Install SS:
    ./target_05_ss.sh
    reboot
 
11. Reconfig server IP, port, and password from LuCi.


