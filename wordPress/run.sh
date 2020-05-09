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
DOMAINNAME="blog.doryhub.com"
DOMAINNAME_WWW="blog.doryhub.com"

DATAS_ROOT_PATH="${INSTALL_PATH}/datas"
CERTBOT_ETC_DATA_PATH="${DATAS_ROOT_PATH}/certbot-etc"
WORDPRESS_DATA_PATH="${DATAS_ROOT_PATH}/wordpress/wp-content"
DBDATA_DATA_PATH="${DATAS_ROOT_PATH}/dbdata"

sed_path()
{
	echo $(echo $1 | sed -e 's/\//\\\//g')
}

customize_nginx_func()
{
    sed -i "s/domain_name/${DOMAINNAME}/" ./nginx-conf/nginx.conf
    sed -i "s/domain_name_www/${DOMAINNAME_WWW}/" ./nginx-conf/nginx.conf
}

customize_docker_compose_func()
{
    sed -i "s/domain_name/${DOMAINNAME}/" ./docker-compose.yml
    sed -i "s/domain_name_www/${DOMAINNAME_WWW}/" ./docker-compose.yml

    sed -i "s/email_addr/${EMAIL_ADDR}/" ./docker-compose.yml
    
    #echo "$(sed_path ${CERTBOT_ETC_DATA_PATH})"
    sed -i "s/path_certbot-etc/$(sed_path ${CERTBOT_ETC_DATA_PATH})/" ./docker-compose.yml
    sed -i "s/path_wordpress/$(sed_path ${WORDPRESS_DATA_PATH})/" ./docker-compose.yml
    sed -i "s/path_dbdata/$(sed_path ${DBDATA_DATA_PATH})/" ./docker-compose.yml
}

configs_initialize_func()
{
    pushd ${INSTALL_PATH}

    cp ./nginx-conf/nginx.conf_http ./nginx-conf/nginx.conf
    customize_nginx_func

    cp ./docker-compose.yml_http ./docker-compose.yml
    customize_docker_compose_func

    popd
}

obtain_ssl_cert_func()
{
    pushd ${INSTALL_PATH}
    docker-compose up -d
    sleep 5
    docker-compose exec webserver ls -la /etc/letsencrypt/live

    sed -i "s/staging/force-renewal/" ./docker-compose.yml
    docker-compose up --force-recreate --no-deps certbot
    popd
}

enable_ssl_func()
{
    pushd ${INSTALL_PATH}
    docker-compose stop webserver

    curl -sSLo nginx-conf/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf

    cp ./nginx-conf/nginx.conf_https ./nginx-conf/nginx.conf
    customize_nginx_func

    sed -i '/"80:80"/a\      - \"443:443\"' ./docker-compose.yml

    docker-compose up -d --force-recreate --no-deps webserver
    docker-compose ps

    echo ""

    popd
}

start_server_func()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "WordPress have been installed in ${INSTALL_PATH}!"
        exit 1
    fi

    pushd ${INSTALL_PATH}
    docker-compose up -d
    docker ps -a

    popd
}

stop_server_func()
{
    if [ ! -d ${INSTALL_PATH} ]
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
    echo "[ server ]"
}

#cp ./cfgs/docker-compose.yml_http ./docker-compose.yml
#sed -i '/"80:80"/a\      - \"443:443\"' ./docker-compose.yml
#exit 0

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
            echoG "WordPress has been installed in ${INSTALL_PATH}."
            echoY "Please config your user name and password for database in ${INSTALL_PATH}/.env before server configuration!"
	    echo ""
        fi
	;;
	cfg)
        if [ ! -d ${INSTALL_PATH} ]
        then
            echoR "Could not find WordPress installation in ${INSTALL_ROOT_PATH}!"
            exit 1
        else
            # server configs initialize
            echoG "Initializing WordPress..."

            sudo mkdir -p ${DATAS_ROOT_PATH}
            sudo mkdir -p ${CERTBOT_ETC_DATA_PATH}
            sudo mkdir -p ${WORDPRESS_DATA_PATH}
            sudo mkdir -p ${DBDATA_DATA_PATH}
            sudo chown -hR $(id -un):$(id -gn) ${DATAS_ROOT_PATH}

            configs_initialize_func

            # Obtaining SSL Certificates and Credentials
            echoG "Obtaining SSL Certificates and Credentials..."
            obtain_ssl_cert_func

            # enable ssl 
            echoG "Enabling ssl.."
            enable_ssl_func
            echoG "Deploying is finished!"
        fi
	;;
	start)
        start_server_func
	;;
	stop)
        stop_server_func
	;;
	*) echo "unknow cmd"
        usage_func
esac

