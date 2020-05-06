#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

INSTALL_ROOT_PATH="/opt/servers"
INSTALL_DIR="wordpress"
INSTALL_PATH="${INSTALL_ROOT_PATH}/${INSTALL_DIR}"

EMAIL_ADDR="falconray@yahoo.com"
DOMAINNAME="doryhub.com"
DOMAINNAME_WWW="www.doryhub.com"

DATAS_ROOT_PATH="${INSTALL_DIR}/datas"
CERTBOT_ETC_DATA_PATH="${DATAS_ROOT_PATH}/certbot-etc"
WORDPRESS_DATA_PATH="${DATAS_ROOT_PATH}/wordpress"
DBDATA_DATA_PATH="${DATAS_ROOT_PATH}/dbdata"

isCorrect="N"

ssServerIP="0.0.0.0"
ssServerPort=443
ssServerPassword="ss-redir"
ssRedirLocalPort=1080

get_ss_redir_config_args()
{
	echoY "Please input your ss server IP:"
	read ssServerIP
	echoY "Please input your ss server port:"
	read ssServerPort
	#echo "Please input your ss server password:"
	#read ssServerPassword
	echoY "Please input your ss-redir local port:"
	read ssRedirLocalPort

	echoY "Your server IP is: ${ssServerIP}"
	echoY "Your server Port is: ${ssServerPort}"
	#echo "Your server password is: ${ssServerPassword}"
	echoY "Your ss-redir local port is: ${ssRedirLocalPort}"

    isCorrect="N"
	echoY "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echoG "correct"
	else
		echoR "incorrect"
		exit 1
	fi
}

configure_wordpress_func()
{
    pushd ${INSTALL_PATH}

    if [ $1 == "http" ]
    then
        cp ./nginx-conf/nginx.conf_http ./nginx-conf/nginx.conf
        cp ./docker-compose.yml_http ./docker-compose.yml


    elif [ $1 == "https" ]
    then
        cp ./nginx-conf/nginx.conf_https ./nginx-conf/nginx.conf
        cp ./docker-compose.yml_http ./docker-compose.yml

    else
        echoR "Unsupported target: $1"
        exit 1
    fi

    sed -i "s/domain_name/${DOMAINNAME}/" ./nginx-conf/nginx.conf
    sed -i "s/domain_name_www/${DOMAINNAME_WWW}/" ./nginx-conf/nginx.conf

    sed -i "s/domain_name/${DOMAINNAME}/" ./docker-compose.yml
    sed -i "s/domain_name_www/${DOMAINNAME_WWW}/" ./docker-compose.yml

    sed -i "s/email_addr/${EMAIL_ADDR}/" ./docker-compose.yml
    
    sed -i "s/path_certbot-etc/${CERTBOT_ETC_DATA_PATH}/" ./docker-compose.yml
    sed -i "s/path_wordpress/${WORDPRESS_DATA_PATH}/" ./docker-compose.yml
    sed -i "s/path_dbdata/${DBDATA_DATA_PATH}/" ./docker-compose.yml

    curl -sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf

    echoG "Configuration have been done."

    echoY "Please config your user name and password for database in ${INSTALL_PATH}/.env before starting!"
    echo ""

    popd
}

start_server_func()
{
    if [ ! -d ${INSTALL_DIR} ]
    then
        echoR "WordPress have been installed in ${INSTALL_PATH}!"
        exit 1
    fi

    pushd ${INSTALL_PATH}

    if [ $1 == "http" ]
    then
        docker-compose up -d
        docker ps -a
        docker exec webserver ls -la /etc/letsencrypt/live
    elif [ $1 == "https" ]
    then
        docker-compose up -d
        docker ps -a
    else
        echoR "Unsupported target: $1"
        exit 1
    fi

    popd
}

stop_server_func()
{
    if [ ! -d ${INSTALL_DIR} ]
    then
        echoR "WordPress have been installed in ${INSTALL_PATH}!"
        exit 1
    fi

    pushd ${INSTALL_PATH}
    docker-compose down
    popd
}

usage_func()
{
    echoY "./run.sh <cmd> <target>"
    echo ""
    echoY "Supported cmd:"
    echo "[ install, cfg, start, stop ]"
    echoY "Supported targets:"
    echo "[ http, https ]"

}

[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
	install)
        if [ -d ${INSTALL_PATH} ]
        then 
            echoR "WordPress have been installed in ${INSTALL_PATH}!"
            exit 1
        else
            echoG "WordPress is going to be installed in ${INSTALL_PATH}..."

            sudo mkdir -p ${INSTALL_ROOT_PATH}
            sudo chown $(id -un):$(id -gn) ${INSTALL_ROOT_PATH}

            cp -a ./cfgs ${INSTALL_PATH}
            cp ./run.sh ${INSTALL_PATH}/
            echoG "WordPress has been installed in ${INSTALL_PATH}."
        fi
	;;
	cfg)
        if [ ! -d ${INSTALL_PATH} ]
        then
            echoR "Could not find WordPress installation in ${INSTALL_ROOT_PATH}!"
            exit 1
        else
            echoG "Configuring WordPress for $2"

            sudo mkdir -p ${DATAS_ROOT_PATH}
            sudo mkdir -p ${CERTBOT_ETC_DATA_PATH}
            sudo mkdir -p ${WORDPRESS_DATA_PATH}
            sudo mkdir -p ${DBDATA_DATA_PATH}
            sudo chown -hR $(id -un):$(id -gn) ${DATAS_ROOT_PATH}

            configure_wordpress_func $2
        fi
	;;
	start)
        start_server_func $2
	;;
	stop)
        stop_server_func
	;;
	*) echo "unknow cmd"
        usage_func
esac

