#!/bin/bash

# Trigger the script with root user or exit.
if [ ${UID} -ne 0 ]
then
  echo -e "[EXIT] - Run the script as root user or with sudo privilege..."
  exit 1
fi

. ./env_configs

# 3. Reset the configuration 

virt-sysprep -a ${Destination_VM_Path}/${Destination_VM_Name}.qcow2
    

tree -ah ${Destination_VM_Path}



