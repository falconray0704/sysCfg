#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#set -o
set -e
#set -x

export LIBSHELL_ROOT_PATH=${PWD}/../libShell
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



SUPPORTED_CMD="install,uninstall,backup"
SUPPORTED_TARGETS="vscode,extensions,server_extensions"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

install_server_extensions()
{
    echoY "Installing vscode server extensions ..."

    cat ./vscode_server_extensions_list.txt | xargs -n 1 code-server --install-extension
}

uninstall_server_extensions()
{
    echoY "Cleaning vscode server extensions..."
    code --list-extensions | xargs -n 1 code-server --uninstall-extension
}

install_vscode()
{
    echoY "Installing vscode from: https://code.visualstudio.com/download"
}

install_extensions()
{
    echoY "Installing vscode extensions ..."

    cat ./vscode_extensions_list.txt | xargs -n 1 code --install-extension
}

uninstall_vscode()
{
    echoY "Uninstalling vscode ..."

    set +e
    which code

    if [ $? -eq 0 ]
    then
        sudo apt-get -y remove code
        sudo apt-get -y purge code

        rm -rf ~/.config/Code

        echoY "vscode uninstall finished!"
    else
        echoY "Can not find vscode installed."
    fi
    set -e
}

uninstall_extensions()
{
    echoY "Cleaning extensions..."
    code --list-extensions | xargs -n 1 code --uninstall-extension
}

backup_extensions()
{
    echoY "Backuping extensions..."
    code --list-extensions > ./vscode_extensions_list.txt_new
    echoC "Extensions list have been backup to ./vscode_extensions_list.txt_new,
    replace the ./vscode_extensions_list.txt for applying update manually."
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c backup -l \"extensions\""
    echoY "eg:\n./run.sh -c install -l \"vscode\""
    echoY "eg:\n./run.sh -c uninstall -l \"vscode\""
    echoY "eg:\n./run.sh -c install -l \"extensions\""
    echoY "eg:\n./run.sh -c uninstall -l \"extensions\""
    echoY "eg:\n./run.sh -c install -l \"server_extensions\""
    echoY "eg:\n./run.sh -c uninstall -l \"server_extensions\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
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
    "uninstall")
        uninstall_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "backup")
        backup_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac



