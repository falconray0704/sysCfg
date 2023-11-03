
# References:
https://github.com/openwrt/openwrt
https://www.v2fly.org
https://guide.v2fly.org/
https://github.com/v2fly/v2ray-core
https://github.com/v2fly/v2ray-examples
https://github.com/v2fly/docker
https://github.com/dnscrypt/dnscrypt-proxy/wiki/Installation-on-OpenWRT
https://openwrt.org/docs/guide-user/services/dns/dnscrypt_dnsmasq_dnscrypt-proxy2
https://openwrt.org/docs/guide-user/base-system/uci
https://github.com/vernesong/OpenClash.git


1. Install self-building OpenWrt with OpenClash integrated.

Install openwrt with TF card:

export TARGET_DEV="/dev/<disk>"
export PI_BOOT_DEV="${TARGET_DEV}1"
export PI_ROOT_DEV="${TARGET_DEV}2"

sudo umount ${PI_BOOT_DEV} ${PI_ROOT_DEV}
sudo dd bs=1M count=200 if=/dev/zero of=/dev/sda status=progress
sudo dd if=openwrt-bcm27xx-bcm2710-rpi-3-squashfs-factory.img of=${TARGET_DEV} bs=2M status=progress

2. Plugin usb ethernet adapter for WAN, and connect PC to LAN.

3. Launch Pi by TF card without WAN connecting.

4. scp piInit_23.05 to Pi.

5. ssh into Pi, and configure the pi step by step with scripts in piInit_23 directory.
   But the step 08 and 09 are optional.

6. Login to Pi, upload config for OpenClash and switch to the config file in the tab of "Plugin Settings".

7. Connect network cable to WAN, and download Clash in the "Version Update" sub-tab of "Plugin Settings".

8. Select the server in the OpenClash "Overview" tab

