#!/bin/ash

source ./.env_target


sed -i "4 s/.*/iperf3 -s \&/" /etc/rc.local
echo "" >> /etc/rc.local

if [ ${TARGET_HW_VERSION} == "3B" ]
then
    echo 'echo 1200000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq' >> /etc/rc.local
elif [ ${TARGET_HW_VERSION} == "3B_PLUS" ]
then
    echo 'echo 1400000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq' >> /etc/rc.local
fi

echo 'echo "performance" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor' >> /etc/rc.local

echo "" >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local

