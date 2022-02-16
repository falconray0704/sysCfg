#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

# raspbian Debian 11 bullseye, install docker-ce refer to:
# https://www.linuxtechi.com/install-docker-engine-on-debian/
# but...Here we go, we install docker.io instead of docker-ce

#set -o
set -e
#set -x

export LIBSHELL_ROOT_PATH=$(cd ../libShell && pwd)
. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib

DOCKER_COMPOSE_VERSION=2.1.0

# Checking environment setup symbolic link and its file exists
if [ -L ".env_setup" ] && [ -f ".env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ./.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi

SUPPORTED_CMD="install,uninstall,cfg"
SUPPORTED_TARGETS="repo,docker,DockerCompose,utils,nvidia,root"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

uninstall_old_docker_apt()
{
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        sudo apt-get -y purge docker-ce docker-ce-cli containerd.io
        sudo apt-get -y purge docker.io docker-doc docker-clean
	sync
        sudo reboot
        exit 0
    elif [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ]
    then
        sudo apt-get -y purge docker.io docker-doc docker-clean
        sudo apt-get -y purge docker-ce docker-ce-cli containerd.io
	sync
        sudo reboot
	exit 0
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi
}

install_repo()
{
    echoY "Installing docker repo ..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then

        sudo apt-get update
        sudo apt-get -y install ca-certificates curl gnupg lsb-release
        
#        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#            ${OSENV_DIST_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        curl -fsSL https://download.docker.com/${OSENV_DOCKER_OS}/${OSENV_DOCKER_DIST_ID}/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/${OSENV_DOCKER_OS}/${OSENV_DOCKER_DIST_ID} \
            ${OSENV_DIST_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
    elif [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ]
    then

        sudo apt-get update
	sudo apt install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg2 \
		software-properties-common
        
        curl -fsSL https://download.docker.com/${OSENV_DOCKER_OS}/${OSENV_DOCKER_DIST_ID}/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/${OSENV_DOCKER_OS}/${OSENV_DOCKER_DIST_ID} \
            ${OSENV_DIST_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID} OSENV_DIST_CODENAME:${OSENV_DIST_CODENAME} ."
    fi

    echoG "Installed docker repo success!"
}

uninstall_repo()
{
    echoY "Uninstalling docker repo..."
    set +e
    which docker
    if [ $? == 0 ]
    then
        echoR "You must uninstall docker first!!!"
        exit 0
    fi
    set -e

    if ( [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ] ) || \
       ( [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ] )
    then
        set +e
        sudo rm -rf /usr/share/keyrings/docker-archive-keyring.gpg
        sudo rm -rf /etc/apt/sources.list.d/docker.list
        sudo apt autoremove -y
        sudo apt-get update

        set -e
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID} OSENV_DIST_CODENAME:${OSENV_DIST_CODENAME}."
    fi

    echoG "Uninstalled docker repo success!"
}

install_docker()
{
    echoY "Installing docker..."

    set +e
    which docker
    if [ $? == 0 ]
    then
        uninstall_old_docker_apt
    fi
    set -e

    uninstall_repo
    install_repo

    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        sudo apt-get -y install docker-ce docker-ce-cli containerd.io
        sudo usermod -aG docker $USER
    elif [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ]
    then
        sudo apt-get -y install docker.io docker-doc docker-clean
        sudo usermod -aG docker $USER
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi
    echoG "Installing docker successfully!"
    echoY "You must relogin or reboot system for docker group added of ${USER}."
}

uninstall_docker()
{
    echoY "Uninstalling docker..."
    echoY "Images, containers, volumes, or customized configuration files on your host are not automatically removed. To delete all images, containers, and volumes:"
    echoY "sudo rm -rf /var/lib/docker"
    echoY "sudo rm -rf /var/lib/containerd"
    uninstall_old_docker_apt
    echoG "Uninstalling docker successed!"
}

install_utils()
{
    echoY "Installing bridge-utils ..."
    if ( [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ] ) || \
       ( [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ] )
    then
        sudo apt-get install bridge-utils
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi
    echoG "bridge-utils installed successfully."

}

cfg_DataRoot()
{
    echoY "Docker data-root is going to change."    

    if [ -f /etc/docker/daemon.json ]
    then
        echoR "Docker file: /etc/docker/daemon.json already existed!"
    else
        sudo cp ./cfgs/daemon.json /etc/docker/
    fi
    echoY "Apply your path to /etc/docker/daemon.json manually:"
    echo "{"
    echo "  \"data-root\": \"/var/lib/docker\""
    echo "}"
    echo ""

    echoY "Exec following command for applying changes."
    echo "sudo systemctl restart docker"
    echo ""
    echoY "and exec following command for cleaning old containers.(refer to: https://evodify.com/change-docker-storage-location/)"
    echo "docker system prune -a"
}

install_DockerCompose()
{
    echoY "Installing docker compose ..."

    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        sudo mkdir -p /usr/local/lib/docker/cli-plugins

        # refer to https://docs.docker.com/compose/install/#install-compose
        sudo curl -L https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-${OSENV_DOCKER_OS}-${OSENV_OS_CPU_ARCH} -o /usr/local/lib/docker/cli-plugins/docker-compose
        sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
	# check
        docker compose version
    elif [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ]
    then
        sudo apt-get -y install docker-compose
        docker-compose version
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi


    echoG "docker compose installed successfully!"
}

uninstall_DockerCompose()
{
    echoY "Uninstalling docker compose ..."

    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_DIST_CODENAME} == "bionic" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        sudo rm -rf /usr/local/lib/docker/cli-plugins/docker-compose
        echoG "docker compose uninstalled successfully!"
        sudo ls -al /usr/local/lib/docker/cli-plugins/
    elif [ ${OSENV_DIST_ID} == "Debian" ] && [ ${OSENV_DIST_CODENAME} == "bullseye" ] && [ ${OSENV_OS_CPU_ARCH} == "aarch64" ]
    then
        sudo apt-get -y purge docker-compose
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c install -l \"repo\""
    echoY "eg:\n./run.sh -c install -l \"docker\""
    echoY "eg:\n./run.sh -c cfg -l \"DataRoot\""
    echoY "eg:\n./run.sh -c install -l \"utils\""
    echoY "eg:\n./run.sh -c install -l \"DockerCompose\""
    echoY "eg:\n./run.sh -c uninstall -l \"DockerCompose\""
    echoY "eg:\n./run.sh -c uninstall -l \"docker\""
    echoY "eg:\n./run.sh -c uninstall -l \"repo\""

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
    "uninstall")
        uninstall_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "cfg")
        srcInstall_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    *)
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


