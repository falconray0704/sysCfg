#!/bin/bash

. ./env_configs

rm -rf ${Snapshots_Path}
mkdir -p ${Snapshots_Path}

SNAPSHOT_NAMES=$(virsh snapshot-list ${Source_VM_Name} --name)
#virsh snapshot-list ${Source_VM_Name} --name > ${Snapshots_List}

#echo "${SNAPSHOT_NAMES}" > ${Destination_VM_Path}/snapshot_${Source_VM_Name}.list

#SNAPSHOT_NAMES=$(cat "${Snapshots_List}")

for Snapshot_Name in ${SNAPSHOT_NAMES}
do
	if [ ! -z ${Snapshot_Name} ]
	then
#		echo "Exporting snapshot: ${Snapshot_Name} "
		virsh snapshot-dumpxml ${Source_VM_Name} ${Snapshot_Name} \
			--security-info > ${Snapshots_Path}/${Snapshot_Name}.xml
		if [ $? -eq 0 ]
		then
			echo "Exported snapshot: ${Snapshot_Name} to ${Snapshots_Path}/${Snapshot_Name}.xml success"
			echo "${Snapshot_Name}" >> ${Snapshots_List}
		else
			echo "Exported snapshot: ${Snapshot_Name} to ${Snapshots_Path}/${Snapshot_Name}.xml fail"
		fi
	else
		echo "Empty snapshot name is invalid!!!"
	fi
done
	
tree -a ${Snapshots_Path}

cat ${Snapshots_List}

