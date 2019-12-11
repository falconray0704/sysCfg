#!/bin/bash

set -o nounset
set -o errexit

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

install_DockerCompose_func()
{
    # Install required packages
    sudo apt update
    sudo apt install -y libssl-dev python python-pip libffi-dev python-backports.ssl-match-hostname

    # Install Docker Compose from pip
    # This might take a while
    sudo pip install docker-compose

    # check docker-compose
    docker-compose --version
}

install_DockerCompose_run_as_container_func()
{
    # refer to https://www.berthon.eu/2017/getting-docker-compose-on-raspberry-pi-arm-the-easy-way/
    local BuildRoot="/opt/github/docker"
    mkdir -p ${BuildRoot}
    pushd ${BuildRoot}
    git clone https://github.com/docker/compose.git
    pushd compose
    git checkout release
    docker build -t docker-compose:armhf -f Dockerfile .
    docker run --rm --entrypoint="script/build/linux-entrypoint" -v $(pwd)/dist:/code/dist -v $(pwd)/.git:/code/.git "docker-compose:armhf"
    popd
    popd
}

install_Docker_func()
{
    # refer to https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html
    # Install some required packages first
    sudo apt update
    sudo apt install -y \
         apt-transport-https \
         ca-certificates \
         curl \
         gnupg2 \
         software-properties-common

    # Get the Docker signing key for packages
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

    # Add the Docker official repos
    echo "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
         $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list

    # Install Docker
    # The aufs package, part of the "recommended" packages, won't install on Buster just yet, because of missing pre-compiled kernel modules.
    # We can work around that issue by using "--no-install-recommends"
    sudo apt update
    sudo apt install -y --no-install-recommends \
        docker-ce \
        cgroupfs-mount

    sudo systemctl enable docker
    sudo systemctl start docker

    # use Docker as a non-root user
    sudo usermod -aG docker pi

    sudo reboot
}

check_Docker_Env_func()
{
    docker info
    docker version
#    docker run -i -t resin/rpi-raspbian
    docker run --rm -it hello-world
}

print_usage_func()
{
    echoY "Usage: ./run.sh <cmd> <target>"
    echo ""
    echoY "Supported operations:"
    echo "[ install, check ]"
    echo ""
    echoY "Supported targets:"
    echo "[ docker, compose ]"
}

[ $# -lt 1 ] && print_usage_func && exit 1

case $1 in
    install) echoY "Installing $2..."
        is_root_func
        if [ $2 == "docker" ]
        then
            install_Docker_func
        elif [ $2 == "compose" ]
        then
#            install_DockerCompose_run_as_container_func
            install_DockerCompose_func
        else
            echoR "install command only support targets: [ docker, compose ]."
        fi
        ;;
    check) echoY "Checking docker env..."
        if [ $2 == "docker" ]
        then
            check_Docker_Env_func
        else
            echoR "check command only support targets: [ docker ]."
        fi
        ;;
    *) echoR "Unknown cmd: $1"
        print_usage_func
        ;;
esac


