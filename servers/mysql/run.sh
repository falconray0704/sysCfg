#!/bin/bash

# refer to:
# https://github.com/erikwittek/multiuser-mysql/blob/master/add-users.sh
# https://medium.com/@onexlab.io/docker-compose-mysql-multiple-database-fe640938e06b
# https://github.com/oxlb/Docker-Compose-MySQL-Multiple-Databases/blob/master/docker-compose.yml


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

install_server()
{
	if [ -d ${INSTALL_PATH} ]
	then 
	    echoR "MySQL have been installed in ${INSTALL_PATH}!"
	    exit 1
	else
	    echoY "MySQL is going to be installed in ${INSTALL_PATH}..."

	    sudo mkdir -p ${DBDATA_PATH}
	    sudo chown -hR $(id -un):$(id -gn) ${INSTALL_PATH}
	    cp -a cfgs/dbinit ${DATAS_ROOT_PATH}
	    cp ./.env ${INSTALL_PATH}
	    cp ./docker-compose.yml ${INSTALL_PATH}
	    cp ./run.sh ${INSTALL_PATH}

	    echoG "MySQL has been installed in:\n$(tree -a ${INSTALL_PATH})."
	    
	    echoY "Please configure your user name and password for database in ${INSTALL_PATH}/.env"
	    echoY "    and dbinit files in ${DBINIT_PATH} before server configuration!"
	    echo ""
	fi
}

usage_func()
{
    echoY "Usage:"
    echoY "./run.sh -c get -t cert"
    echoY "-c:Operating command."
    echoY "-t:Operating target."
    echo ""

    echoY "Supported commands:"
    echoY "[ install, start, stop ]"
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

