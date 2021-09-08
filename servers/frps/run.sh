#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#set -o
set -e
#set -x

source ./.env_run_server

export LIBSHELL_ROOT_PATH=${ENV_RUN_LIBSHELL_ROOT_PATH}
. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib

# Checking environment setup symbolic link and its file exists
if [ -L ".env_setup" ] && [ -f ".env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ./.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi


SUPPORTED_CMD="install,start,stop"
SUPPORTED_TARGETS="frps"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

stop_frps()
{

    local TARGET_USER_NAME=${DOCKER_USER_NAME}
    local TARGET_NAME=${FRP_DOCKER_NAME}
    local TARGET_ARCH=${OSENV_DOCKER_CPU_ARCH}

    export DOCKER_TARGET=${TARGET_USER_NAME}/${TARGET_ARCH}_${FRP_DOCKER_NAME}:${VERSION_RELEASE_FRP}

    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find frps installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else

        echoG "Stopping frps..."
	pushd ${INSTALL_PATH}
	docker-compose down -v
	popd
        echoG "Stopping frps is finished!"
    fi
}

start_frps()
{
    local TARGET_USER_NAME=${DOCKER_USER_NAME}
    local TARGET_NAME=${FRP_DOCKER_NAME}
    local TARGET_ARCH=${OSENV_DOCKER_CPU_ARCH}

    export DOCKER_TARGET="${TARGET_USER_NAME}/${TARGET_ARCH}_${FRP_DOCKER_NAME}:${VERSION_RELEASE_FRP}"
   
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find frps installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else
        echoG "Starting frps..."
	pushd ${INSTALL_PATH}
	docker-compose up -d
	popd
        echoG "Starting frps is finished!"
    fi

}

install_frps()
{
        if [ -d ${INSTALL_PATH} ]
        then 
            echoR "frps have been installed in ${INSTALL_PATH}!"
            exit 1
        else
            echoG "frps is going to be installed in ${INSTALL_PATH}..."

            sudo mkdir -p ${INSTALL_ROOT_PATH}
            sudo chown $(id -un):$(id -gn) ${INSTALL_ROOT_PATH}

            cp -a ${PWD} ${INSTALL_PATH}

            echoG "frps has been installed in ${INSTALL_PATH}."
            echoY "Please config your frps informations in ${INSTALL_PATH}/cfgs/frps.ini before launch docker-compose!"
            echo ""
        fi
}


usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c install -l \"frps\""
    echoY "eg:\n./run.sh -c start -l \"frps\""
    echoY "eg:\n./run.sh -c stop -l \"frps\""

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
    "install")
        install_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "start")
        start_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "stop")
        stop_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac



