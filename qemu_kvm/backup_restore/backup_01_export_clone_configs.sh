#!/bin/bash

. ./env_configs

mkdir -p ${Source_VM_Backup_Path}

#echo "${Destination_VM_Path}/${Destination_VM_Name}"


# 1. Generate VM xml
virsh dumpxml ${Source_VM_Name} > ${Source_VM_Backup_Path}/${Source_VM_Name}.xml
    
tree -ah ${Source_VM_Backup_Path}
ls -al ${Source_VM_Backup_Path}

