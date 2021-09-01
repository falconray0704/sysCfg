#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
set -x

. ../libShell/echo_color.lib
. ../libShell/utils.lib

source .env_host


SUPPORTED_CMD="sync"
SUPPORTED_TARGETS="shadowsocks-libev,manifest-tool,frp"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

sync_repo_branch()
{
    local repo_name=$1
    local repo_branch=$2
    local repo_upstream_name=$3

    echoY "Syncing branch ${repo_name}:${repo_branch} ..."

    if [ -d ${repo_name} ]
    then
        pushd ${repo_name}

        git fetch ${repo_upstream_name}
        git checkout ${repo_branch}
        git merge ${repo_upstream_name}/${repo_branch}
        git push

        #echoG "Merged ${repo_name}:${repo_branch} successed!"
        popd
    fi

}

sync_repo_branchs()
{

    local repo_name=$1
    local repo_branchs=$2
    local repo_upstream_name=$3

    echoY "Syncing branchs ${repo_name}:${repo_branchs} ..."

    local branchs_num=`echo ${repo_branchs}|awk -F"," '{print NF}'`
    local i=1
    for ((;$i<=${branchs_num};i++)); do
        local branch_name
        eval branch_name='`echo ${repo_branchs}|awk -F, "{ print $"$i" }"`'
        sync_repo_branch ${repo_name} ${branch_name} ${repo_upstream_name} 
    done

    echoG "Syncing branchs ${repo_name}:${repo_branchs} successed, total branchs:${branchs_num} !"
}

sync_items_func()
{
    local exec_cmd=$1
    local exec_items_list=$2

#    git config --global credential.helper 'cache --timeout 7200'
#    git config --global --unset credential.helper

    exec_items_iterator ${exec_cmd} ${exec_items_list} 

#    git config --global --unset credential.helper
}

sync_shadowsocks-libev()
{
    local exec_cmd=$1
    local repo_name=$2
    local repo_branchs="master"
    local repo_upstream_name="upstream"
    
    echoY ${repo_name} ${repo_branchs} ${repo_upstream_name}
    sync_repo_branchs ${repo_name} ${repo_branchs} ${repo_upstream_name}
}

sync_manifest-tool()
{
    local exec_cmd=$1
    local repo_name=$2
    local repo_branchs="main"
    local repo_upstream_name="upstream"
    
    echoY ${repo_name} ${repo_branchs} ${repo_upstream_name}
    sync_repo_branchs ${repo_name} ${repo_branchs} ${repo_upstream_name}
}

sync_frp()
{
    local exec_cmd=$1
    local repo_name=$2
    local repo_branchs="master,dev"
    local repo_upstream_name="upstream"

    echoY ${repo_name} ${repo_branchs} ${repo_upstream_name}
    sync_repo_branchs ${repo_name} ${repo_branchs} ${repo_upstream_name}
}


usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c sync -l \"shadowsocks-libev,manifest-tool,frp\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
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
    "sync")
        pushd ${SYNC_FORK_PATH}
        sync_items_func ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        popd
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


 
