#!/bin/bash

# refer to:
# https://www.cnblogs.com/kevingrace/p/11753294.html
# https://edward0im.github.io/technology/2020/09/17/en-vim/

#set -o
set -e
#set -x

. ../../libShell/echo_color.lib

DOWNLOAD_DIR="downloads"

SUPPORTED_CMD="install,uninstall"
SUPPORTED_TARGETS="VIM,VundleVim"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

VIM_NAME="vim"

apt_install_pkg()
{
    sudo apt-get -y install $1
}

apt_uninstall_pkg()
{
    sudo apt remove --purge $1
}

install_color_one_dark()
{
    if [ ! -d vim-code-dark ]
    then
#    sudo rm -rf vim-code-dark
    git clone https://github.com/tomasiser/vim-code-dark.git
    fi

    pushd vim-code-dark
    mkdir -p ~/.vim
    cp -a autoload base16 colors ~/.vim/
    popd
}

install_vim_color()
{
    mkdir -p downloads
    pushd downloads

#    install_color_one_dark
#    install_color_vim-code-dark
#    install_color_oceanic-next

    popd
}

install_vim_extensions() {
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

note_after_VundleVim()
{
    echoY "After install VundleVim, exec following command manually:"
    echo "vim +BundleInstall +qall"
    echo "cd  ~/.vim/bundle/youcompleteme"

    echo "git submodule update --init --recursive"
    #echo "python3 install.py --clang-completer --go-completer"
    #echo "python3 install.py --all"
    echo "python3 install.py --all"
    # Copy .ycm_extra_conf.py to ~/.vim
    echo "cp  ${HOME}/.vim/bundle/youcompleteme/third_party/ycmd/.ycm_extra_conf.py  ${HOME}/.vim/"

}

install_VundleVim()
{
    # Make ~/.vim/bundle directory.
    mkdir -p ${HOME}/.vim/bundle
    cd ${HOME}/.vim/bundle
    git clone https://github.com/VundleVim/Vundle.vim 
    cd -

    # Move .vimrc to home folder.
    cp  configs/vimrc1_ycm  ${HOME}/.vimrc

    # Move codedark.vim to ~/.vim/colors folder.
    mkdir -p ${HOME}/.vim/colors
    cp  configs/codedark.vim  ${HOME}/.vim/colors

    sudo apt-get -y install build-essential cmake vim-nox python3-dev
    sudo apt-get -y install mono-complete nodejs openjdk-17-jdk openjdk-17-jre npm

    sudo apt-get -y install automake autogen autoconf build-essential cmake

    #sudo apt-get -y install composer npm

#    cd ${HOME}/.vim/bundle/YouCompleteMe
#    python3 install.py --all
#    cd -
    note_after_VundleVim

}

uninstall_VundleVim(){
    sudo rm -rf ${HOME}/.vim*
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
    echoY "eg:\n./run.sh -c install -l \"VIM,VundleVim\""
    echoY "eg:\n./run.sh -c uninstall -l \"VIM,VundleVim\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
    echo ""
    note_after_VundleVim
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


 
