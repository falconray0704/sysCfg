#!/bin/bash

# refer to:
# https://github.com/jonls/redshift

#set -o
set -e
#set -x

. ../libShell/echo_color.lib

source .env_host


SUPPORTED_CMD="cfg"
SUPPORTED_TARGETS="redshift"

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

cfg_redshift()
{
    mkdir -p downloads
    pushd downloads
    
    if [ ! -d redshift ]
    then
        git clone --depth=1 https://github.com/jonls/redshift.git
    fi

    cp redshift/redshift.conf.sample ~/.config/redshift.conf

    popd
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c cfg -l \"redshift\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"

    echo ""
    echoC "Config following variables as you like in ~/.config/redshift.conf "
    echo "temp-day=5700"
    echo "temp-night=5700"
    
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


 
