#!/bin/bash

# refer to https://apt.kitware.com/

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

sudo apt-get -y update
sudo apt-get -y upgrade

install_from_repo()
{
    sudo apt remove --purge cmake

    sudo apt-get update
    sudo apt-get -y install apt-transport-https ca-certificates gnupg software-properties-common wget

    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null

    # For Ubuntu Bionic Beaver (18.04):
    sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
    sudo apt-get update

    sudo apt-get -y install kitware-archive-keyring
    sudo rm /etc/apt/trusted.gpg.d/kitware.gpg

    sudo apt-get -y install cmake

}

install_from_repo


