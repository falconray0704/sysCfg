#!/bin/bash

# refer to:


set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace


. ../../libShell/echo_color.lib

source ./.env

stop_server()
{
	pushd ${INSTALL_PATH}
#	docker-compose down -v
	docker-compose down
	popd
}

start_server()
{
	pushd ${INSTALL_PATH}
	docker-compose up -d
	popd
}

cfg_server()
{
	if [ ! -d ${INSTALL_PATH} ]
	then
		echoR "Could not find Nginx installation in ${INSTALL_ROOT_PATH}!"
		exit 1
	else
		# server configs initialize
		echoG "Initializing Nginx..."

		mkdir -p ${NGINX_CONF_PATH} ${NGINX_LOG_PATH}
		cp ./cfgs/default_https.conf.template ${NGINX_CONF_PATH}/default.conf
		sed -i "s/FQDN_OR_IP/${FQDN_OR_IP}/g" ${NGINX_CONF_PATH}/default.conf

		echoG "Initializing is finished!"
	fi
}

install_server()
{
	if [ -d ${INSTALL_PATH} ]
	then 
	    echoR "Nginx have been installed in ${INSTALL_PATH}!"
	    exit 1
	else
	    echoY "Nginx is going to be installed in ${INSTALL_PATH}..."

        sudo mkdir -p ${INSTALL_ROOT_PATH}
        sudo chown $(id -un):$(id -gn) ${INSTALL_ROOT_PATH}

        mkdir -p ${INSTALL_PATH}
        cp -a ./.env ${INSTALL_PATH}
        cp -a ./run.sh ${INSTALL_PATH}
        cp -a ./docker-compose.yml ${INSTALL_PATH}

		cp -a ./cfgs ${INSTALL_PATH}

        echoG "Nginx has been installed in ${INSTALL_PATH}."
        echoY "Please config your user name and password for database in ${INSTALL_PATH}/.env before server configuration!"
	    echo ""
	fi
}

usage_func()
{
    echoY "Usage:"
    echoY "./run.sh -c install -t server"
    echoY "-c:Operating command."
    echoY "-t:Operating target."
    echo ""

    echoY "Supported commands:"
    echoY "[ install, cfg, start, stop ]"
    echo ""

    echoY "Supported target:"
    echoY "[ server ]"
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

