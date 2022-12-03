#!/bin/bash

. ./env_configs

mkdir -p ${Destination_VM_Path}

#echo "${Destination_VM_Path}/${Destination_VM_Name}"


# 1. Generate VM xml
virt-clone --original ${Source_VM_Name} \
	--name ${Destination_VM_Name} \
    --file ${Destination_VM_Path}/${Destination_VM_Name}.qcow2 \
    --print-xml > ${Destination_VM_Path}/${Destination_VM_Name}.xml
    
tree -ah ${Destination_VM_Path}
ls -al ${Destination_VM_Path}

