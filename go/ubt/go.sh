#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

GOVERSION="1.16.4"

install_dependence_func()
{
    echo "Installing dependence..."
    sudo apt-get -y install gccgo-6
}

install_go_1_4_func()
{
    pushd ~/
    #export http_proxy=10.1.51.48:42581
    #export https_proxy=10.1.51.48:42581
    #export sock5_proxy=10.1.51.48:42581
    rm -rf go go1.4

    wget -c https://dl.google.com/go/go1.4-bootstrap-20171003.tar.gz
    tar -zxf go1.4-bootstrap-20171003.tar.gz
    mv go go1.4
    pushd ~/go1.4/src
    #sudo update-alternatives --set go /usr/bin/go-5
    GOROOT_BOOTSTRAP=/usr ./make.bash
    popd

    popd
}

install_latest_go_func()
{
    pushd ~/
    rm -rf go
    #git clone https://github.com/golang/go.git
    #wget https://storage.googleapis.com/golang/go1.8.src.tar.gz
    #wget -c https://storage.googleapis.com/golang/go1.9.1.src.tar.gz
    wget -c https://dl.google.com/go/go${GOVERSION}.src.tar.gz
    #tar -zxf go1.8.src.tar.gz
    tar -zxf go${GOVERSION}.src.tar.gz
    pushd go/src
    ./all.bash
    popd

    popd
}

usage_func()
{
    echoY "./go.sh <cmd> "
    echo ""
    echoY "Only support following commands:"
    echo "installGoBootStrap"
    echo "install"
    echo "update"
    echo ""
    echoY "Set go env:"
    echo 'export GOROOT=$HOME/go'
    echo 'export GOPATH=<path to your gopath>'
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin'
    echo "alias gw='cd \$GOPATH'"
}


[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1


case $1 in
    installGoBootStrap) echoY "Installing bootstrap go1.4..."
        install_dependence_func
        install_go_1_4_func
        ;;
    install) echoY "Installing Go:${GOVERSION}..."
        install_latest_go_func
        ;;
    update) echoY "Updating to Go:${GOVERSION}"
        install_latest_go_func
        ;;
    *) echoR "Unknow command: $1"
        usage_func
esac


