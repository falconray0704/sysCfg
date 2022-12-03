#!/bin/bash

# Trigger the script with root user or exit.
if [ ${UID} -ne 0 ]
then
  echo -e "[EXIT] - Run the script as root user or with sudo privilege..."
  exit 1
fi

. ./env_configs

# 2. Copy the whole image
ls -al ${Source_VM_Path}/${Source_VM_Name}.qcow2 

cp ${Source_VM_Path}/${Source_VM_Name}.qcow2 ${Destination_VM_Path}/${Destination_VM_Name}.qcow2

ls -al ${Destination_VM_Path}/${Destination_VM_Name}.qcow2

tree -ah ${Destination_VM_Path}
ls -al ${Destination_VM_Path}



