#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace


. ../../libShell/echo_color.lib

source ./.env

renew_cert()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find Certbot installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else

        # Renewing SSL Certificates and Credentials
        echoG "Renewing SSL Certificates and Credentials..."
		docker run --rm --name certbot \
	        -p 80:80 \
		    -p 443:443 \
		    -v "${LETSENCRYPT_ETC_PATH}:/etc/letsencrypt" \
		    -v "${LETSENCRYPT_LIB_VAR_PATH}:/var/lib/letsencrypt" \
		    certbot/certbot \
		    renew
        echoG "Renew is finished!"
    fi
}

get_cert()
{
    if [ ! -d ${INSTALL_PATH} ]
    then
        echoR "Could not find Certbot installation in ${INSTALL_ROOT_PATH}!"
        exit 1
    else
        # server configs initialize
        echoG "Initializing Certbot..."
		echoY "DATAS_ROOT_PATH=${DATAS_ROOT_PATH}"
		echoY "LETSENCRYPT_ETC_PATH=${LETSENCRYPT_ETC_PATH}"
		echoY "LETSENCRYPT_LIB_VAR_PATH=${LETSENCRYPT_LIB_VAR_PATH}"

        sudo mkdir -p ${LETSENCRYPT_ETC_PATH}
        sudo mkdir -p ${LETSENCRYPT_LIB_VAR_PATH}

        # Obtaining SSL Certificates and Credentials
        echoG "Obtaining SSL Certificates and Credentials..."
		docker run --rm --name certbot \
	        -p 80:80 \
		    -p 443:443 \
		    -v "${LETSENCRYPT_ETC_PATH}:/etc/letsencrypt" \
		    -v "${LETSENCRYPT_LIB_VAR_PATH}:/var/lib/letsencrypt" \
		    certbot/certbot \
		    certonly --standalone --email ${EMAIL_ADDR} --agree-tos --no-eff-email -d ${DOMAINNAME_WWW} -d ${DOMAINNAME_BLOG}
        echoG "Deploying is finished!"
    fi

}

install_certbot()
{
        if [ -d ${INSTALL_PATH} ]
        then 
            echoR "Certbot have been installed in ${INSTALL_PATH}!"
            exit 1
        else
            echoG "Certbot is going to be installed in ${INSTALL_PATH}..."

            sudo mkdir -p ${INSTALL_ROOT_PATH}
            sudo chown $(id -un):$(id -gn) ${INSTALL_ROOT_PATH}

            cp -a ${PWD} ${INSTALL_ROOT_PATH}
            echoG "Certbot has been installed in ${INSTALL_PATH}."
            echoY "Please config your domain informations in ${INSTALL_PATH}/.env before certbot operations!"
	    echo ""
        fi
}

usage_func()
{
    echoY "Usage:"
    echoY "./run.sh -c install -t certbot"
    echoY "-c:Operating command."
    echoY "-t:Operating target."
    echo ""

    echoY "Supported commands:"
    echoY "[ install, get, renew ]"
    echo ""

    echoY "Supported targets for install command:"
    echoY "[ certbot ]"
    echo ""
    
    echoY "Supported targets for get command:"
    echoY "[ cert ]"
    echo ""
    
    echoY "Supported targets for renew command:"
    echoY "[ cert ]"
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

