#!/bin/bash

set -o nounset
set -o errexit

#set -x


tips_inspect_func()
{
    echo 'Example:'
    echo 'docker inspect <container name>'
    echo "docker inspect --format='{{.NetworkSettings.IPAddress}}' mytest"
    echo "docker inspect --format='{{.Config.Volumes}}' mytest"
    echo "docker inspect --format='{{.HostConfig.Binds}}' mytest"
}

tips_restart_func()
{
    echo 'Example:'
    echo 'sudo docker restart mytest'
}

tips_stop_func()
{
    echo 'Example:'
    echo 'sudo docker stop mytest'
    echo ''
    echo 'Stop containers with name prefix:'
    echo "docker ps --format '{{.Names}}' | grep \"^<container name>\" | awk '{print \$1}' | xargs -I {} docker stop {}"
}

tips_start_func()
{
    echo 'Example:'
    echo 'sudo docker start -ai mytest'
    echo 'Options:'
    echo '[-a] Attach STDOUT/STDERR and forward signals.'
    echo "[-i] Attach container\'s STDIN."
}

tips_rmi_func()
{
    echo 'Example:'
    echo 'sudo docker rmi ubuntu:latest'
}

tips_rm_func()
{
    echo 'Example:'
    echo 'sudo docker rm -fv mytest'
    echo 'Options:'
    echo '[-f] Force the removal of a running container (uses SIGKILL)'
    echo '[-l] Remove the specified link'
    echo '[-v] Remove the volumes associated with the container'
}

tips_image_func()
{
    echo ""
    echo "List image with formater:"
    echo 'docker image ls --format "{{.ID}}:\t{{.Repository}}"'
    echo 'docker image ls --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}"'
    echo "List image print table with formater:"
    echo 'docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"'
    echo ""
    echo 'Delete all images with filter:'
    echo 'docker image rm $(docker image ls -q redis)'
    echo 'docker image rm $(docker image ls -q -f before=mongo:3.2)'
    echo 'docker image rm $(docker image ls -q -f since=mongo:3.2)'
    echo ""
    echo 'Remove unused images:'
    echo 'sudo docker image prune'
}

tips_images_func()
{
    echo 'Example:'
    echo 'sudo docker images -a'
    echo 'Options:'
    echo '[-a] List all docker images.'
}

tips_ps_func()
{
    echo 'Example:'
    echo 'sudo docker ps -a'
    echo 'Options:'
    echo '[-a] List all docker containers.'
}

mount_host_path_func()
{
    echo ""
    echo "Mount host host path as volume:"
    echo 'docker run -itd --mount type=bind,source=<host path>,target=<container path> ubuntu:16.04 bash '
    echo 'docker run -itd --mount type=bind,source=<host path>,target=<container path>,readonly ubuntu:16.04 bash '
}

tips_run_func()
{
    echo 'Example:'
    echo 'sudo docker run -i -t --name mytest ubuntu:latest /bin/bash'
    echo 'sudo docker run -it --rm hello-world'
    echo 'The "--rm" option will clean the volumes of container and container.'
    echo 'Options:'
    echo '[-i] Interaction mode.'
    echo '[-t] Launch a terminal, use it with "-i" option.'
    echo '[-c] Assign cpu shares.'
    echo '[-m] Assign memory. Support:(B,K,M,G)'
    echo '[-v] Assign volume. Format: [host-dir]:[container-dir]:[rw|ro]'
    echo '[-p] Expose port from container. Format:[host-port]:[container-port]'
    mount_host_path_func
    echo ""
    echo "Map container's port on specific host IP:"
    echo "docker run -itd --name <container name> -p <host IP>:<host port>:<container's port>[/udp] <image name>"
    echo "docker run -itd --name <container name> -p <host IP>:<host port>:<container's port>[/tcp] <image name>"
    echo ""
    echo "Map container's port to any port on specific host IP:"
    echo "docker run -itd --name <container name> -p <host IP>::<container's port>[/udp] <image name>"
    echo "docker run -itd --name <container name> -p <host IP>::<container's port>[/tcp] <image name>"
    echo ""
    run_container_with_dns_func
    echo ""
}

tips_env_func()
{
    echo "docker info"
    echo "docker version"
}

tips_exec_func()
{
    echo "Enter container's bash:"
    echo 'docker exec -it <container name> bash'
}

tips_diff_func()
{
    echo "Show modifications in container's storage layers:"
    echo 'docker diff <container name>[:tag]'
}

tips_history_func()
{
    echo "Show modifications in image's storage layers:"
    echo 'docker history <image name>[:tag]'
}

tips_build_func()
{
    echo "Build image with Dockerfile"
    echo 'docker build -t <image name>[:tag] [-f <dockerfile>] <context>'
}

tips_volume_func()
{
    echo ""
    echo "Show volumes:"
    echo "docker volume ls"
    echo ""
    echo "Display detailed information on one or more volumes:"
    echo 'docker volume inspect <volume name>'
    echo ""
    echo "Create volume:"
    echo 'docker volume create <volume name>'
    echo ""
    echo "Mount volume:"
    echo 'docker run -itd --mount target=<container path> ubuntu:16.04 bash '
    echo 'docker run -itd --rm --mount target=<container path> ubuntu:16.04 bash '
    echo 'docker run -itd --mount source=<volume name>,target=<container path> ubuntu:16.04 bash '
    mount_host_path_func
    echo ""
    echo "Remove volume:"
    echo 'docker volume rm <volume name>'
    echo "Clean all unused volumes:"
    echo 'docker volume prune'
}

tips_port_func()
{
    echo ""
    echo "List port mappings or a specific mapping for the container:"
    echo "docker port <container name>"
}

tips_logs_func()
{
    echo ""
    echo "Fetch logs of a container:"
    echo "docker logs <container name>"
    echo "docker logs -f <container name>"
}

config_container_default_global_dns_func()
{
    echo 'Add following configurations into: /etc/docker/daemon.json'
    echo '{'
    echo '  "dns":'
    echo '  ['
    echo '      "114.114.114.114",'
    echo '      "8.8.8.8"'
    echo '  ]'
    echo '}'
    echo ""
    echo "Then use folloing command for configuration confirm:"
    echo "docker run -it --rm busybox cat etc/resolv.conf"
    echo ""
    echo ""
}

run_container_with_dns_func()
{
    echo "Run container with specific DNS:"
    echo 'docker run -it --rm --dns="2.2.2.2" <image name> cat etc/resolv.conf'
}

tips_network_func()
{
    echo ""
    echo "Create a bridge network:"
    echo 'docker network create -d bridge <name of network>'
    echo ""
    echo "Connect container to network:"
    echo 'docker run --rm --name <container name> --network <network name> <image name>[:tag]'
    echo ""
    echo "Config DNS on contaners\' default connecting network:"
    config_container_default_global_dns_func

}

tips_commit_func()
{
    echo ""
    echo "Commit container changes to image:"
    echo 'docker commit [operations] <container ID or name> [repo Name[:<tag name>]]'
    echo ""
    echo "eg:"
    echo 'docker commit --author "rayruan <falconray@yahoo.com>" --message "vim installed" vim ubuntu:vim'
}

tips_save_func()
{
    echo "Save one or more images to a tar archive (streamed to STDOUT by default)."
    echo "docker save [ -o output.tar ] IMAGE [IMAGE...]"
    echo ""
    echo "eg:"
    echo "docker save -o fedora-all.tar fedora"
    echo "docker save ubuntu:18.04 > ubuntu.tar"
    echo "docker save myimage:latest | gzip > myimage_latest.tar.gz"
    echo ""
    echo "Backup all images:"
    echo "docker save -o allinone.tar \$(docker images --format '{{.Repository}}:{{.Tag}}')"
    echo ""
}

tips_load_func()
{
    echo ""
    echo "Load images from tar archive:"
    echo "docker load [OPTIONS]"
    echo ""
    echo "eg:"
    echo "docker load -i <backup>.tar"
    echo "docker load < <backup>.tar.gz"
}

tips_help_func()
{
    #echo "1) Fetch logs of the container:"
    #echo "docker logs -f peer0.org1.example.com"


    echo "Supported tips:"
    echo '001) [env]      Tips for getting docker Env infos.'
    echo '002) [run]      Tips for "run" command. Run container.'
    echo '003) [ps]       Tips for "ps" command. List containers.'
    echo '004) [image]    Tips for "image" command.'
    echo '005) [images]   Tips for "images" command.'
    echo '006) [rm]       Tips for "rm" command. Remove container.'
    echo '007) [rmi]      Tips for "rmi" command. Remove Image.'
    echo '008) [start]    Tips for "start" command. Start container.'
    echo '009) [stop]     Tips for "stop" command. Stop container.'
    echo '010) [restart]  Tips for "restart" command. Restart container.'
    echo '011) [inspect]  Tips for "inspect" command. Get informations about images or containers.'
    echo '012) [exec]     Tips for "exec" command.'
    echo '013) [diff]     Tips for "diff" command. Show modifications of the storage layers in container.'
    echo '014) [history]  Tips for "history" command. Show modification of the storage layers in image.'
    echo '015) [build]    Tips for "build" command. Build image.'
    echo '016) [volume]   Tips for "volume" command. Volume operations.'
    echo '017) [port]     Tips for "port" command. Port operations.'
    echo '018) [logs]     Tips for "logs" command. Show container logs.'
    echo '019) [network]  Tips for "network" command. Network operations.'
    echo '020) [commit]   Tips for "commit" command. Commit container changes to image.'
    echo '021) [save]     Tips for "save" command. Create a backup of images that can then be used with "docker load".'
    echo '022) [load]     Tips for "load" command. Load an image from a tar archive or STDIN.'
}

[ $# -lt 1 ] && tips_help_func && exit

case $1 in
    help) echo "Tips for docker manipulations:"
        tips_help_func
        ;;
    env) echo "001) [env] Tips for geting docker environment infos:"
        tips_env_func
        ;;
    run) echo '002) [run] Tips for "run" command.'
        tips_run_func
        ;;
    ps) echo '003) [ps]   Tips for "ps" command.'
        tips_ps_func
        ;;
    image) echo '004) [images]   Tips for "image" command.'
        tips_image_func
        ;;
    images) echo '005) [images]   Tips for "images" command.'
        tips_images_func
        ;;
    rm) echo '006) [rm]   Tips for "rm" command.'
        tips_rm_func
        ;;
    rmi) echo '007) [rmi]   Tips for "rmi" command.'
        tips_rmi_func
        ;;
    start) echo '008) [start]    Tips for "start" command. Start container.'
        tips_start_func
        ;;
    stop) echo '009) [stop]    Tips for "stop" command. Stop container.'
        tips_stop_func
        ;;
    restart) echo '010) [restart]     Tips for "restart" command. Restart container.'
        tips_restart_func
        ;;
    inspect) echo '011) [inspect]  Tips for "inspect" command. Get informations about images or containers.'
        tips_inspect_func
        ;;
    exec) echo  '012) [exec] Tips for "exec" command.'
        tips_exec_func
        ;;
    diff) echo '013) [diff] Tips for "diff" command'
        tips_diff_func
        ;;
    history) echo '014 [history] Tips for "history" command'
        tips_history_func
        ;;
    build) echo '015 [build] Tips for "build" command'
        tips_build_func
        ;;
    volume) echo '016 [volume] Tips for "volume" command'
        tips_volume_func
        ;;
    port) echo '017 [port] Tips for "port" command'
        tips_port_func
        ;;
    logs) echo '018 [logs] Tips for "logs" command'
        tips_logs_func
        ;;
    network) echo '019 [network] Tips for "network" command'
        tips_network_func
        ;;
    commit) echo '020 [commit] Tips for "commit" command'
        tips_commit_func
        ;;
    save) echo '021) [save]     Tips for "save" command. Create a backup of images that can then be used with "docker load".'
        tips_save_func
        ;;
    load) echo '022) [load]     Tips for "load" command. Load an image from a tar archive or STDIN.'
        tips_load_func
        ;;
    *) echo "Unknown cmd: $1"
esac


