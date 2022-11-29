#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html

#set -o
set -e
#set -x

. ../../libShell/echo_color.lib

DOWNLOAD_DIR="downloads"

SUPPORTED_CMD="install,uninstall"
SUPPORTED_TARGETS="VIM,VIM_BOOTSTRAP"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

VIM_NAME="vim"
VIM82_NAME="vim"
VIM_BOOTSTRAP_NAME="vim_bootstrap"

apt_install_pkg()
{
    sudo apt-get -y install $1
}

apt_uninstall_pkg()
{
    sudo apt remove --purge $1
}

install_color_vim-code-dark()
{
    if [ ! -d vim-code-dark ]
    then
#    sudo rm -rf vim-code-dark
    git clone https://github.com/tomasiser/vim-code-dark.git
    fi

    pushd vim-code-dark
    cp -a autoload base16 colors ~/.vim/
    popd
}

install_color_oceanic-next()
{
    if [ ! -d oceanic-next ]
    then
#    sudo rm -rf oceanic-next
    git clone https://github.com/mhartington/oceanic-next.git
    fi

    pushd oceanic-next
    cp -a after autoload colors estilo test ~/.vim/
    popd
}


install_vim_color()
{
    mkdir -p downloads
    pushd downloads

    install_color_vim-code-dark
    install_color_oceanic-next

    popd
}

install_vim_extensions() {
    #sudo apt-get -y install ctags git exuberant-ctags ncurses-term curl
    sudo apt-get -y install universal-ctags git ncurses-term curl
}

install_VIM()
{
    apt_install_pkg ${VIM_NAME}

    install_vim_extensions
    install_vim_color
}

uninstall_VIM()
{
    apt_uninstall_pkg ${VIM_NAME}
}

install_VIM82()
{
    exit 0
    apt_uninstall_pkg ${VIM_NAME}


    sudo apt-get -y install software-properties-common

    # refer to: https://sourcedigit.com/24976-vim-8-2-released-how-to-install-vim-in-ubuntu-linux/
    sudo add-apt-repository ppa:jonathonf/vim
    sudo apt update
    sudo apt-get -y install vim

    install_vim_extensions
}

uninstall_8.2_third_part_repo()
{
    exit 0
    sudo apt install ppa-purge
    sudo ppa-purge ppa:jonathonf/vim
    sudo add-apt-repository --remove ppa:jonathonf/vim
}

uninstall_VIM82()
{
    exit 0
    apt_uninstall_pkg ${VIM82_NAME}

    uninstall_8.2_third_part_repo
}

note_after_VIM_BOOTSTRAP()
{
    echoY "After install VIM_BOOTSTRAP, exec following command manually:"
    echo "vim +PlugInstall +qall"
    echo "cd ~/.vim/plugged/YouCompleteMe/"
    echo "git submodule update --init --recursive"
    #echo "python3 install.py --clang-completer --go-completer"
    #echo "python3 install.py --all"
    echo "python3 install.py --all"

}

install_VIM_BOOTSTRAP()
{
 
    sudo apt-get -y install automake autogen autoconf build-essential cmake
    sudo apt-get -y install git wget curl tree
    sudo apt-get -y install python3-dev
    sudo apt-get -y install default-jdk

    # refer to: https://stackoverflow.com/questions/65284572/your-c-compiler-does-not-fully-support-c17
    #sudo apt-get -y install gcc-8 g++-8 npm
    #sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
    #sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8
    
    sudo apt-get -y install composer npm

    pushd ~/
    sudo rm -rf .vimrc vim .vim generate.vim
    mkdir -p ~/.vim
    popd

    install_vim_color
    cp ./.vimrc* ~/
    
    note_after_VIM_BOOTSTRAP
}

uninstall_VIM_BOOTSTRAP(){
    echoY "Do nothing for uninstall: ${VIM_BOOTSTRAP_NAME}."
}

install_items_func()
{
    PKGS=${EXEC_ITEMS_LIST}
    #pushd ${DOWNLOAD_DIR}
    PKGS_NUM=`echo ${PKGS}|awk -F"," '{print NF}'`
    for ((i=1;i<=${PKGS_NUM};i++)); do
        eval pkg='`echo ${PKGS}|awk -F, "{ print $"$i" }"`'
        exec_name=install_${pkg}
        ${exec_name}
    done
    #popd
}

uninstall_items_func()
{
    PKGS=${EXEC_ITEMS_LIST}
    #pushd ${DOWNLOAD_DIR}
    PKGS_NUM=`echo ${PKGS}|awk -F"," '{print NF}'`
    for ((i=1;i<=${PKGS_NUM};i++)); do
        eval pkg='`echo ${PKGS}|awk -F, "{ print $"$i" }"`'
        exec_name=uninstall_${pkg}
        ${exec_name}
    done
    #popd
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    #echoY "eg:\n./run.sh -c install -l \"${SUPPORTED_TARGETS}\""
    #echoY "eg:\n./run.sh -c install -l \"VIM82,VIM_BOOTSTRAP\""
    #echoY "eg:\n./run.sh -c uninstall -l \"VIM82,VIM_BOOTSTRAP\""
    echoY "eg:\n./run.sh -c install -l \"VIM,VIM_BOOTSTRAP\""
    echoY "eg:\n./run.sh -c uninstall -l \"VIM,VIM_BOOTSTRAP\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
    echo ""
    note_after_VIM_BOOTSTRAP
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
        mkdir -p ${DOWNLOAD_DIR}
        install_items_func
        ;;
    "uninstall")
        mkdir -p ${DOWNLOAD_DIR}
        uninstall_items_func
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac


 
