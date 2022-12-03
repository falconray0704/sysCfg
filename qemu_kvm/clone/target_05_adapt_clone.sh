#!/bin/bash

. ./env_configs

#export Source_VM_Name="ubt220401_seeds"
#export Source_VM_Root_Path="/mnt/hd1/kvms"
#export Source_VM_Dir="${Source_VM_Name}"

#export Destination_VM_Name="ubt220401_clone"
#export Destination_VM_Root_Path="/media/ray/mhd500/kvms"
#export Destination_VM_Dir="${Destination_VM_Name}"


#export Source_VM_uuid=
#export Destination_VM_uuid=
export Source_VM_uuid="e9fa702a-f38a-4583-9443-17168965ab57"
export Destination_VM_uuid="b58c7cae-d7f3-4027-9e59-9d39fe78f388"

#export Source_VM_MAC=
#export Destination_VM_MAC=
export Source_VM_MAC='52:54:00:f0:b7:5d'
export Destination_VM_MAC="52:54:00:69:5c:c0"

SNAPSHOT_NAMES=$(cat "${Snapshots_List}")

get_sed_path()
{
	echo $(echo $1 | sed -e 's/\//\\\//g')
}


sed_file()
{
	local STR_SRC=$1
	local STR_DES=$2
	local FILE=$3

	sed -i "s/${STR_SRC}/${STR_DES}/g" ${FILE}

}

adapt_snapshot_config()
{
	local Snapshot_Name=$1
	local SED_STR_SRC=$2
	local SED_STR_DES=$3

#	set -x
	sed_file ${SED_STR_SRC} ${SED_STR_DES} "${Snapshots_Path}/${Snapshot_Name}.xml"
#	set +x
}

adapt_snapshots()
{
	local STR_SRC=$1
	local STR_DES=$2


	for Snapshot_Name in ${SNAPSHOT_NAMES}
	do
		if [ ! -z ${Snapshot_Name} ]
		then
			echo "Adapting: ${Snapshots_Path}/${Snapshot_Name}.xml"

			adapt_snapshot_config ${Snapshot_Name} ${STR_SRC} ${STR_DES}

			if [ $? -ne 0 ]
			then
				echo "STR_SRC: ${STR_SRC}"
				echo "STR_DES: ${STR_DES}"
				echo "Adapted fail: ${Snapshots_Path}/${Snapshot_Name}.xml"
			else
				echo "Adapted success: ${Snapshots_Path}/${Snapshot_Name}.xml"
			fi
		else
			echo "Empty snapshot name is invalid!!!"
		fi
	done
		
}

adapt_snapshot_vm_name()
{
	local SRC_VM_NAME=$1
	local DES_VM_NAME=$2

	adapt_snapshots ${SRC_VM_NAME} ${DES_VM_NAME}
}

adapt_snapshot_vm_uuid()
{
	local SRC_UUID=$1
	local DES_UUID=$2

	adapt_snapshots ${SRC_UUID} ${DES_UUID}
}

adapt_snapshot_vm_root_path()
{
	local SRC_ROOT_PATH=$1
	local DES_ROOT_PATH=$2

	local SED_SRC_ROOT_PATH=$(get_sed_path ${SRC_ROOT_PATH})
	local SED_DES_ROOT_PATH=$(get_sed_path ${DES_ROOT_PATH})

	adapt_snapshots ${SED_SRC_ROOT_PATH} ${SED_DES_ROOT_PATH}
}

adapt_snapshot_vm_dir()
{
	local SRC_VM_DIR=$1
	local DES_VM_DIR=$2

	adapt_snapshots ${SRC_VM_DIR} ${DES_VM_DIR}
}

adapt_snapshot_vm_mac_address()
{
	local SRC_MAC=$1
	local DES_MAC=$2

	adapt_snapshots ${SRC_MAC} ${DES_MAC}
}

if [ -z ${Source_VM_Name} ] || [ -z ${Destination_VM_Name} ]
then
	echo "VM_Name should not be empty!!!"
	echo "Source_VM_Name=${Source_VM_Name}"
	echo "Destination_VM_Name=${Destination_VM_Name}"
	exit 1
fi
adapt_snapshot_vm_name ${Source_VM_Name} ${Destination_VM_Name}

if [ -z ${Source_VM_uuid} ] || [ -z ${Destination_VM_uuid} ]
then
	echo "uuid should not be empty!!!"
	echo "Source_VM_uuid=${Source_VM_uuid}"
	echo "Destination_VM_uuid=${Destination_VM_uuid}"
	exit 1
fi
adapt_snapshot_vm_uuid ${Source_VM_uuid} ${Destination_VM_uuid}

if [ -z ${Source_VM_Root_Path} ] || [ -z ${Destination_VM_Root_Path} ]
then
	echo "VM root path should not be empty!!!"
	echo "Source_VM_Root_Path=${Source_VM_Root_Path}"
	echo "Destination_VM_Root_Path=${Destination_VM_Root_Path}"
	exit 1
fi
adapt_snapshot_vm_root_path ${Source_VM_Root_Path} ${Destination_VM_Root_Path}

if [ -z ${Source_VM_Dir} ] || [ -z ${Destination_VM_Dir} ]
then
	echo "VM_Dir should not be empty!!!"
	echo "Source_VM_Dir=${Source_VM_Dir}"
	echo "Destination_VM_Dir=${Destination_VM_Dir}"
	exit 1
fi
adapt_snapshot_vm_dir ${Source_VM_Dir} ${Destination_VM_Dir}

if [ -z ${Source_VM_MAC} ] || [ -z ${Destination_VM_MAC} ]
then
	echo "VM_MAC should not be empty!!!"
	echo "Source_VM_MAC=${Source_VM_MAC}"
	echo "Destination_VM_MAC=${Destination_VM_MAC}"
	exit 1
fi
adapt_snapshot_vm_mac_address ${Source_VM_MAC} ${Destination_VM_MAC}

