#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace


. ../../libShell/echo_color.lib

source ./.env

stop_frps()
{
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
    echoY "./run.sh -c install -t frps"
    echoY "-c:Operating command."
    echoY "-t:Operating target."
    echo ""

    echoY "Supported commands:"
    echoY "[ install, start, stop ]"
    echo ""

    echoY "Supported targets for install command:"
    echoY "[ frps ]"
    echo ""
    
    echoY "Supported targets for start command:"
    echoY "[ frps ]"
    echo ""
    
    echoY "Supported targets for stop command:"
    echoY "[ frps ]"
    echo ""
    
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

