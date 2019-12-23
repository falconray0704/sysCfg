#!/bin/bash

set -o nounset
set -o errexit

#set -x

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

DOCKER_COMPOSE_VERSION=1.25.0

install_DockerCompose_func()
{
    # refer to https://docs.docker.com/compose/install/#install-compose
    sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # https://docs.docker.com/compose/completion/#install-command-completion
    sudo curl -L https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

    # check
    docker-compose --version

}

uninstall_DockerCompose_func()
{
    sudo rm /usr/local/bin/docker-compose
}

install_Docker_func()
{
    # https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1
    sudo apt-get update
#    sudo apt-get install docker-ce
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo docker run hello-world

    # use Docker as a non-root user
    #echo "User:$USER"
    sudo usermod -aG docker $USER

    #sudo reboot
}

check_Docker_Env_func()
{
    docker info
    docker version

    docker run --rm hello-world
}

uninstall_old_versions_func()
{
    sudo apt-get remove docker docker-engine docker.io docker-ce docker-ce-cli
    sudo apt-get purge docker docker-engine docker.io docker-ce docker-ce-cli
    sudo rm -rf /var/lib/docker /var/lib/docker-engine
}

install_repo_func()
{
    sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo "Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"
    sudo apt-key fingerprint 0EBFCD88

    if [ $(os_distributor) == "LinuxMint" ] && [ $(os_distribution_number) == "19.3" ]
    then
        echoG "Linux Mint..."
        echo -e "\ndeb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" | sudo tee -a /etc/apt/sources.list
    else
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    fi

}

install_utils_func()
{
    sudo apt-get install bridge-utils
}

usage_func()
{
    
    echoY "./docker.sh <cmd> "
    echo ""
    echoY "Supported functionalities:"
    echo "[uninstallOldVersions]"
    echo "[installRepo]"
    echo "[installDocker]"
    echo "[checkDocker]"
    echo "[installDockerCompose]"
    echo "[uninstallDockerCompose]"
    echo "[installUtils]"
}

[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
    uninstallOldVersions) echoY "Unstalling old versions..."
        uninstall_old_versions_func
        ;;
    installRepo) echoY "Installing Repo for docker installation..."
        install_repo_func
        ;;
    installDocker) echoY "Installing Docker-ce ..."
        install_Docker_func
        ;;
    checkDocker) echoY "Checking docker env..."
        check_Docker_Env_func
        ;;
    installDockerCompose) echoY "Installing Docker Compose ..."
        install_DockerCompose_func
        ;;
    uninstallDockerCompose) echoY "Uninstalling Docker Compose ..."
        uninstall_DockerCompose_func
        ;;
    installUtils) echoY "Installing useful utils ..."
        install_utils_func
        ;;
    *) echoR "Unknown cmd: $1"
        usage_func
esac


