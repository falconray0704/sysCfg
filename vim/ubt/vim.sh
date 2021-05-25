#!/bin/bash

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

install_8.2_third_part_repo()
{
    
    sudo apt remove --purge vim vim-gtk

    # refer to: https://sourcedigit.com/24976-vim-8-2-released-how-to-install-vim-in-ubuntu-linux/
    sudo add-apt-repository ppa:jonathonf/vim
    sudo apt update
    sudo apt-get -y install vim

    # refer to: https://stackoverflow.com/questions/65284572/your-c-compiler-does-not-fully-support-c17
    sudo apt-get -y install gcc-8 g++-8 npm
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8

}

uninstall_8.2_third_part_repo()
{
    sudo apt install ppa-purge
    sudo ppa-purge ppa:jonathonf/vim
    sudo add-apt-repository --remove ppa:jonathonf/vim

}


install_from_repo()
{
    sudo apt-get -y install vim vim-gtk
    sudo apt-get -y install automake autogen autoconf build-essential cmake
    sudo apt-get -y install git wget curl tree
    sudo apt-get -y install python3-dev
}

install_from_src()
{
    sudo apt-get -y install automake autogen autoconf build-essential cmake
    sudo apt-get -y install git wget curl tree
    sudo apt-get -y install python3-dev

    sudo apt autoremove vim

    mkdir -p /opt/github/vim
    pushd /opt/github/vim
    wget -c https://github.com/vim/vim/archive/v8.1.0329.tar.gz
    tar -zxf v8.1.0329.tar.gz
    pushd vim-8.1.0329
    ./configure --prefix=/usr/local --enable-gui=gtk2 --with-features=huge --enable-luainterp=yes --enable-mzschemeinterp --enable-perlinterp=yes --enable-pythoninterp=yes --with-python-config-dir=/usr/lib/python2.7/config-arm-linux-gnueabihf --enable-python3interp=yes --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-arm-linux-gnueabihf --enable-tclinterp=yes --enable-rubyinterp=yes --enable-cscope
    make VIMRUNTIMEDIR=/usr/local/share/vim/vim81
    sudo make install
    popd
    popd
}

install_vim_color()
{
    mkdir -p downloads
    pushd downloads
    rm -rf vim-code-dark
    git clone https://github.com/tomasiser/vim-code-dark.git
    
    pushd vim-code-dark
    cp -a autoload base16 colors ~/.vim/
    popd
    popd
}

sudo apt-get -y install ctags git exuberant-ctags ncurses-term curl
pushd ~/
rm -rf .vimrc vim .vim generate.vim
mkdir -p ~/.vim
popd

#install_from_repo
install_8.2_third_part_repo
#install_from_src

install_vim_color

cp ./.vimrc* ~/
#curl 'https://vim-bootstrap.com/generate.vim' --data 'langs=c&langs=erlang&langs=go&langs=html&langs=javascript&langs=lua&langs=perl&langs=php&langs=python&editor=vim&frameworks=vuejs' > ~/.vimrc

#echo "Fetch generate.vim from http://www.vim-bootstrap.com/"
#echo "mv generate.vim ~/.vimrc"

echoY "exec following command manually:"
echo "vim +PlugInstall +qall"
echo "cd ~/.vim/plugged/YouCompleteMe/"
echo "git submodule update --init --recursive"
#echo "python3 install.py --clang-completer --go-completer"
echo "python3 install.py --all"

