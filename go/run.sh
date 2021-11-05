#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
#set -x

export LIBSHELL_ROOT_PATH=$(cd ../libShell && pwd)
. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib

# Checking environment setup symbolic link and its file exists
if [ -L ".env_setup" ] && [ -f ".env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ./.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi

SUPPORTED_CMD="install, srcInstall, upgrade"
SUPPORTED_TARGETS="dependence,goBootStrap,go"

GOVERSION="1.17.2"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

install_dependence()
{
    echoY "Installing dependence..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ]
    then
        sudo apt-get -y install gccgo-6
    else
        echoR "Unsupported OS:${OSENV_DIST_ID} ."
        exit 0
    fi
    echoG "Installing dependence successed!"
}

install_go()
{
    echoY "Installing go:${GOVERSION} from source..."
    if [ ${OSENV_DIST_ID} == "Ubuntu" ] && [ ${OSENV_OS_CPU_ARCH} == "x86_64" ]
    then
        pushd ~/
        if [ -f go${GOVERSION}.linux-amd64.tar.gz ]
        then
            echoY "go${GOVERSION}.linux-amd64.tar.gz already downloaded." 
        else
            wget -c https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz
        fi

        rm -rf go
        tar -zxf go${GOVERSION}.linux-amd64.tar.gz
        popd
    else
        echoR "Unsupported OSENV_OS_CPU_ARCH:${OSENV_OS_CPU_ARCH} OSENV_DIST_ID:${OSENV_DIST_ID}."
    fi

    echoG "Installed go:${GOVERSION} success..."
}

upgrade_go()
{
    install_go
}

srcInstall_goBootStrap()
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

srcInstall_go()
{
    echoY "Installing go:${GOVERSION} from source..."
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
    echoY "Installed go:${GOVERSION} success..."
}


usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c install -l \"go\""
    echoY "eg:\n./run.sh -c upgrade -l \"go\""
    echoY "eg:\n./run.sh -c install -l \"dependence\""
    echoY "eg:\n./run.sh -c srcInstall -l \"goBootStrap\""
    echoY "eg:\n./run.sh -c srcInstall -l \"go\""
    echoY "eg:\n./run.sh -c srcInstall -l \"goBootStrap,go\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
    echo ""
    echoY "Set go env:"
    echo 'export GOROOT=$HOME/go'
    echo 'export GOPATH=<path to your gopath>'
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin'
    echo "alias gw='cd \$GOPATH'"
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
    "srcInstall")
        srcInstall_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "upgrade")
        upgrade_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac




