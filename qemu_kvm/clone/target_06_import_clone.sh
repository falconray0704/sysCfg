#!/bin/bash

. ./env_configs

# 6. Import KVM Virtual Machine

virsh define --file ${Destination_VM_Path}/${Destination_VM_Name}.xml
    
if [ $? -eq 0 ]
then
	echo "[SUCCESS] Import new VM success!"
	sudo systemctl restart libvirtd
	virsh list --all
else
	echo "[FAIL] Import fail!!!"
fi

