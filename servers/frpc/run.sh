#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace


. ../../libShell/echo_color.lib

source ./.env

stop_frpc()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find frpc installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else

        echoG "Stopping frpc..."
	pushd ${INSTALL_PATH}
	docker-compose down -v
	popd
        echoG "Stopping frpc is finished!"
    fi
}

start_frpc()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find frpc installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else
        echoG "Starting frpc..."
	pushd ${INSTALL_PATH}
	docker-compose up -d
	popd
        echoG "Starting frpc is finished!"
    fi

}

install_frpc()
{
        if [ -d ${INSTALL_PATH} ]
        then 
            echoR "frpc have been installed in ${INSTALL_PATH}!"
            exit 1
        else
            echoG "frpc is going to be installed in ${INSTALL_PATH}..."

            sudo mkdir -p ${INSTALL_ROOT_PATH}
            sudo chown $(id -un):$(id -gn) ${INSTALL_ROOT_PATH}

            cp -a ${PWD} ${INSTALL_PATH}

            echoG "frpc has been installed in ${INSTALL_PATH}."
            echoY "Please config your frpc informations in following files before launch docker-compose!"
            echoY "${INSTALL_PATH}/cfgs/frpc.ini"
	    echoY "${INSTALL_PATH}/.env_host (IMAGE_TAG must match your platform!)"

            echo ""
        fi
}

usage_func()
{
    echoY "Usage:"
    echoY "./run.sh -c install -t frpc"
    echoY "-c:Operating command."
    echoY "-t:Operating target."
    echo ""

    echoY "Supported commands:"
    echoY "[ install, start, stop ]"
    echo ""

    echoY "Supported targets for install command:"
    echoY "[ frpc ]"
    echo ""
    
    echoY "Supported targets for start command:"
    echoY "[ frpc ]"
    echo ""
    
    echoY "Supported targets for stop command:"
    echoY "[ frpc ]"
    echo ""
    
    echoC "frpc is going to be installed in ${INSTALL_PATH}."
    echoC "Please config your frpc informations in following files before launch docker-compose!"
    echoC "${INSTALL_PATH}/cfgs/frpc.ini"
    echoC "${INSTALL_PATH}/.env_host (IMAGE_TAG must match your platform!)"
}

EXEC_COMMAND=""
EXEC_TARGET=""

no_args="true"
while getopts "c:t:" opts
do
    case $opts in
        c)
              # Execute command
              EXEC_COMMAND=$OPTARG
              ;;
        t)
              # Executing target
              EXEC_TARGET=$OPTARG
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

exec_operation=${EXEC_COMMAND}_${EXEC_TARGET}

${exec_operation}

