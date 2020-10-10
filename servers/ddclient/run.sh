#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace


. ../../libShell/echo_color.lib

source ./cfgs/.env

stop_ddclient()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find ddclient installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else

        echoG "Stopping ddclient..."
	pushd ${INSTALL_PATH}
	docker-compose down
	popd
        echoG "Stopping ddclient is finished!"
    fi
}

start_ddclient()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find ddclient installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else
        echoG "Starting ddclient..."
	pushd ${INSTALL_PATH}
	docker-compose up -d
	popd
        echoG "Starting ddclient is finished!"
    fi

}

install_ddclient()
{
        if [ -d ${INSTALL_PATH} ]
        then 
            echoR "ddclient have been installed in ${INSTALL_PATH}!"
            exit 1
        else
            echoG "ddclient is going to be installed in ${INSTALL_PATH}..."

            sudo mkdir -p ${INSTALL_ROOT_PATH}
            sudo chown $(id -un):$(id -gn) ${INSTALL_ROOT_PATH}

            cp -a ${PWD} ${INSTALL_PATH}
	    pushd ${INSTALL_PATH}/cfgs
	    mv ddclient-namecheap.conf ddclient.conf
	    popd
            echoG "ddclient has been installed in ${INSTALL_PATH}."
            echoY "Please config your domain informations in ${INSTALL_PATH}/cfgs/ddclient.conf before launch docker-compose!"
	    echoY "Only changes 3 items(YOURDOMAIN.COM, PASSWORD and SUBDOMAIN_NAME) by default."
	    echo ""
        fi
}

usage_func()
{
    echoY "Usage:"
    echoY "./run.sh -c install -t ddclient"
    echoY "-c:Operating command."
    echoY "-t:Operating target."
    echo ""

    echoY "Supported commands:"
    echoY "[ install, start, stop ]"
    echo ""

    echoY "Supported targets for install command:"
    echoY "[ ddclient ]"
    echo ""
    
    echoY "Supported targets for start command:"
    echoY "[ ddclient ]"
    echo ""
    
    echoY "Supported targets for stop command:"
    echoY "[ ddclient ]"
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

