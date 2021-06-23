#!/bin/bash

# refer to:
# https://bogdancornianu.com/change-swap-size-in-ubuntu/

#set -o
set -e
#set -x

. ../libShell/echo_color.lib

source .env_host


SUPPORTED_CMD="cfg"
SUPPORTED_TARGETS="SWAPSIZE"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

exec_items_iterator()
{
    local exec_cmd=$1
    local exec_items_list=$2

    local exec_items_num=`echo ${exec_items_list}|awk -F"," '{print NF}'`
    local i=1
    for (( ; $i<=${exec_items_num} ; i++)); do
        local item
        eval item='`echo ${exec_items_list}|awk -F, "{ print $"$i" }"`'
        local exec_name=${exec_cmd}_${item}
        ${exec_name} ${exec_cmd} ${item}
    done

}

cfg_SWAPSIZE()
{
    #1. Turn off all swap processes 
    sudo swapoff -a

    #2. Resize the swap
    # if = input file
    # of = output file
    # bs = block size
    # count = multiplier of blocks
    sudo dd if=/dev/zero of=/swapfile bs=1G count=${SWAP_SIZE_GB}

    #3. Change permission
    sudo chmod 600 /swapfile
    
    #4. Make the file usable as swap
    sudo mkswap /swapfile

    #5. Activate the swap file
    sudo swapon /swapfile
    
    #6. Edit /etc/fstab and add the new swapfile if it isn’t already there
    echoY "Current /etc/fstab is:"
    cat /etc/fstab
    echo ""
    echoY "Check following contents are in /etc/fstab ."
    echo "/swapfile none swap sw 0 0"
    echo ""

    #7. Check the amount of swap available
    echoY "Current total swap size is:"
    grep SwapTotal /proc/meminfo

}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c cfg -l \"SWAPSIZE\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"

    echo ""
    
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
    "cfg")
        exec_items_iterator ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


 
