#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#set -x

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

BoostVersion="1.59.0"
#BoostVersion="1.69.0"

tips_func()
{
    echo ""
    echo ""
    echo ""
    echo "Using tips:"
    echo "The following directory should be added to compiler include paths:"
    echo "  /opt/github/boostorg/boost_${BoostVersion}"
    echo "The following directory should be added to linker library paths:"
    echo "  /opt/github/boostorg/boost_${BoostVersion}/stage/lib"
    echo ""
    echo ""

}

install_numactl_func()
{
    local Version="2.0.12"

    pushd /opt/github

    mkdir -p numactl
    pushd numactl
    wget -O numactl-${Version}.tar.gz https://codeload.github.com/numactl/numactl/tar.gz/v${Version}
    rm -rf numactl-${Version}
    tar -zxf numactl-${Version}.tar.gz

    pushd numactl-${Version}
    ./autogen.sh
    ./configure
    make
    sudo make install
    popd

    popd

    popd
}

install_Latest_grpc()
{
    #sudo apt-get -y install build-essential autoconf libtool pkg-config
    #sudo apt-get -y install libgflags-dev libgtest-dev
    #sudo apt-get -y install clang libc++-dev

    pushd /opt/github
    #git clone https://github.com/grpc/grpc
    git clone -b $(curl -L https://grpc.io/release) https://github.com/grpc/grpc
    pushd grpc
    git submodule update --init
    make
    sudo make install

    # install protobuf
    pushd third_party/protobuf
    make
    sudo make install
    popd

    popd
    popd
}

build_boost_version_without_install_func()
{
    local Version=$1
    local VersionFile=$2
    local RootDir=/opt/github/boostorg
    #local RootDir=/opt/etmp/boostorg
    pushd ${RootDir}

    pushd boost_${VersionFile}
    ./bootstrap.sh --prefix=/usr/local/boost_${VersionFile}
	#user_configFile=`find $PWD -name user-config.jam`
	#echo "using mpi ;" >> $user_configFile
	local nCPU=$(nproc --all) # limit for low memory system
	#local nCPU=1
	echo "nCPU:${nCPU}"
	./b2 --prefix=/usr/local/boost_${VersionFile} --with=all -j${nCPU}
    popd
    popd

    echo ""
    echo ""
    echo ""
    echo "Using tips:"
    echo "The following directory should be added to compiler include paths:"
    echo "  /opt/github/boostorg/boost_${BoostVersion}"
    echo "The following directory should be added to linker library paths:"
    echo "  /opt/github/boostorg/boost_${BoostVersion}/stage/lib"
    echo ""
    echo ""

}

deploy_boost_1_59_0_without_install_func()
{
    local Version="1.59.0"
    local VersionFile="1_59_0"
    fetch_boost_src_func ${Version} ${VersionFile}
    build_boost_version_without_install_func ${Version} ${VersionFile}
}

deploy_boost_1_69_0_without_install_func()
{
    local Version="1.69.0"
    local VersionFile="1_69_0"
    fetch_boost_src_func ${Version} ${VersionFile}
    build_boost_version_without_install_func ${Version} ${VersionFile}
}

deploy_boost_without_install_func()
{
    if [ ${BoostVersion} == "1.59.0" ]
    then
        echo "Building boost ${BoostVersion}"
        deploy_boost_1_59_0_without_install_func
    elif [ ${BoostVersion} == "1.69.0" ]
    then
        echo "Building boost ${BoostVersion}"
        deploy_boost_1_69_0_without_install_func
    else
        echo "Unknow boost version: ${BoostVersion}"
    fi
}

build_boost_1_59_0_without_install_func()
{
    local Version="1.59.0"
    local VersionFile="1_59_0"
    build_boost_version_without_install_func ${Version} ${VersionFile}
}

build_boost_1_69_0_without_install_func()
{
    local Version="1.69.0"
    local VersionFile="1_69_0"
    build_boost_version_without_install_func ${Version} ${VersionFile}
}

build_boost_without_install_func()
{
    if [ ${BoostVersion} == "1.59.0" ]
    then
        echo "Building boost ${BoostVersion}"
        build_boost_1_59_0_without_install_func
    elif [ ${BoostVersion} == "1.69.0" ]
    then
        echo "Building boost ${BoostVersion}"
        build_boost_1_69_0_without_install_func
    else
        echo "Unknow boost version: ${BoostVersion}"
    fi
}

install_boost_version_func()
{
    local Version=$1
    local VersionFile=$2
    local RootDir=/opt/github/boostorg
    #local RootDir=/opt/etmp/boostorg
    pushd ${RootDir}

    pushd boost_${VersionFile}
    sudo mkdir -p /usr/local/boost_${VersionFile}
	sudo ./b2 --prefix=/usr/local/boost_${VersionFile} --with=all install

    #sudo sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf'
    #sudo ldconfig
    popd

    popd
}

install_boost_src_1_59_0_func()
{
    local Version="1.59.0"
    local VersionFile="1_59_0"

    install_boost_version_func ${Version} ${VersionFile}
}

install_boost_src_1_69_0_func()
{
    local Version="1.69.0"
    local VersionFile="1_69_0"

    install_boost_version_func ${Version} ${VersionFile}
}

install_boost_src_func()
{
    if [ ${BoostVersion} == "1.59.0" ]
    then
        echo "Installing boost ${BoostVersion}"
        install_boost_src_1_59_0_func
    elif [ ${BoostVersion} == "1.69.0" ]
    then
        echo "Installing boost ${BoostVersion}"
        install_boost_src_1_69_0_func
    else
        echo "Unknow boost version: ${BoostVersion}"
    fi
}

fetch_boost_src_1_59_0_func()
{
    local Version="1.59.0"
    local VersionFile="1_59_0"
    fetch_boost_src_func ${Version} ${VersionFile}
}

fetch_boost_src_1_69_0_func()
{
    local Version="1.69.0"
    local VersionFile="1_69_0"
    fetch_boost_src_func ${Version} ${VersionFile}
}

fetch_boost_func()
{
    if [ ${BoostVersion} == "1.59.0" ]
    then
        echo  "Fetching ${BoostVersion}"
        fetch_boost_src_1_59_0_func
    elif [ ${BoostVersion} == "1.69.0" ]
    then
        echo  "Fetching ${BoostVersion}"
        fetch_boost_src_1_69_0_func
    else
        echo  "Unknow ${BoostVersion}"
    fi

}

fetch_boost_src_func()
{
    local Version=$1
    local VersionFile=$2
    local RootDir=/opt/github/boostorg
    #local RootDir=/opt/etmp/boostorg
    mkdir -p ${RootDir}
    pushd ${RootDir}

    wget -c -O boost_${VersionFile}.tar.gz http://sourceforge.net/projects/boost/files/boost/${Version}/boost_${VersionFile}.tar.gz/download

    tar -zxf boost_${VersionFile}.tar.gz
	popd
}

deploy_general_repo_pkgs()
{
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y dist-upgrade
    sudo apt-get -y install pigz pbzip2 pxz
    sudo apt-get -y install git wget curl tree htop dnsutils
    sudo apt-get -y install automake autogen autoconf cmake zlib1g-dev gettext asciidoc pkg-config clang xmlto libev-dev libc-ares-dev
    sudo apt-get -y install build-essential g++ python-dev autotools-dev mecab mecab-ipadic
    sudo apt-get -y install libicu-dev libboost-all-dev libncurses5-dev libaio-dev libicu-dev libbz2-dev libssl-dev libpcre3 libpcre3-dev libtool libgflags-dev libgtest-dev libc++-dev

    #sudo apt-get -y install openssh-server

}

init_operation_dirs_func()
{
    sudo mkdir -p /opt/github
    sudo chown -R $(id -un):$(id -gn) /opt/github
    sudo mkdir -p /opt/etmp
    sudo chown -R $(id -un):$(id -gn) /opt/etmp

	mkdir -p /opt/github/falcon
}

usage_func()
{
    echoY "./general.sh <cmd> "
    echo ""
    echo "deployGenRepoPkgs"
    echo "install_libnuma"
    echo "grpc"
    echo "fetchBoost"
    echo "buildBoost"
    echo "installBoost"
    echo "deployBoost"
    echo "all"
    echo "tips"
}


[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

init_operation_dirs_func

case $1 in
    deployGenRepoPkgs) echoY "Deploy general repo pkgs ..."
        deploy_general_repo_pkgs
        ;;
    install_libnuma) echoY "Install libnuma ..."
        install_numactl_func
        ;;
    grpc) echoY "Deploy grpc ..."
        deploy_general_repo_pkgs
        install_Latest_grpc
        ;;
    grpcUpdate) echoY "Updating grpc ..."
        pushd /opt/github/grpc/third_party/protobuf
        sudo make uninstall
        popd
        pushd /opt/github
        sudo rm -rf grpc
        popd
        install_Latest_grpc
        ;;
    fetchBoost) echoY "Fetching boost ..."
        fetch_boost_func
        ;;
    buildBoost) echoY "Building boost ..."
        deploy_general_repo_pkgs
        build_boost_without_install_func
        ;;
    installBoost) echoY "Installing boost ..."
        install_boost_src_func
        ;;
    deployBoost) echoY "Deploying boost ..."
        deploy_general_repo_pkgs
        deploy_boost_without_install_func
        ;;
    all) echoY "Deploy all general packets ..."
        deploy_general_repo_pkgs
        install_Latest_grpc
		deploy_boost_1_59_0_without_install_func
        ;;
    tips)
        tips_func
        ;;
    *|-h) echoR "Unknow command: $1"
        usage_func
        ;;
esac













