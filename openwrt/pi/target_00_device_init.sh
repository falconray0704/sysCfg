#!/bin/ash

source ./.env_target

if [ ${TARGET_HW_VERSION} == "3B" ]
then
    echo 'echo 1200000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq' > /etc/rc.local
    echo 'echo "performance" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor' >> /etc/rc.local
    echo 'iperf3 -s &' >> /etc/rc.local
    echo 'exit 0' >> /etc/rc.local
fi

