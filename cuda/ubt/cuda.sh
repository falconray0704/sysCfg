#!/bin/bash


set -o nounset
set -o errexit

#set -x

. ../../../libShell/echo_color.lib
#. ../../../libShell/sysEnv.lib
. ../../../libShell/network.lib

#CUDA_MAIN_VERSION="10.2"
#REPO_VERSION="${CUDA_MAIN_VERSION}.89-1"

CUDA_MAIN_VERSION="11.0.3"
REPO_VERSION="${CUDA_MAIN_VERSION}-450.51.06-1"

install_cuda_func()
{
    # refer to: https://tutorialforlinux.com/2018/12/10/how-to-install-cuda-10-in-elementary-os-64-bit-step-by-step/"

    wget -c http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_${REPO_VERSION}_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu1804_${REPO_VERSION}_amd64.deb
    sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo apt-get update
    sudo apt-get install cuda
#    echo 'export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}' >> $HOME/.bashrc
    echo "export PATH=/usr/local/cuda-${CUDA_MAIN_VERSION}/bin\${PATH:+:\${PATH}}" >> $HOME/.bashrc

}

install_cuda_new_func()
{
    ${DOWNLOAD_RESOURCE} https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
    sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
    ${DOWNLOAD_RESOURCE} https://developer.download.nvidia.com/compute/cuda/${CUDA_MAIN_VERSION}/local_installers/cuda-repo-ubuntu1804-11-0-local_${REPO_VERSION}_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu1804-11-0-local_${REPO_VERSION}_amd64.deb
    sudo apt-key add /var/cuda-repo-ubuntu1804-11-0-local/7fa2af80.pub
    sudo apt-get update
    sudo apt-get -y install cuda
}

usage_func()
{
    
    echoY "./cuda.sh <cmd> "
    echo ""
    echoY "Supported functionalities:"
    echo "[install]"
    echo ""
}

[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
    install) echoY "Installing CUDA ${REPO_VERSION} ..."
        install_cuda_new_func
        ;;
    *) echoR "Unknown cmd: $1"
        usage_func
esac


