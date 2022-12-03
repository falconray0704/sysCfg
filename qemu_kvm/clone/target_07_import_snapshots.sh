#!/bin/sh

. ./env_configs

#export Source_VM_Name="ubt220401_seeds"
#export Source_VM_Path="/mnt/hd1/kvms/${Source_VM_Name}"
#export Destination_VM_Name="ubt220401_clone"
#export Destination_VM_Path="/media/ray/mhd500/kvms/${Destination_VM_Name}"


#export Snapshots_Path="${Destination_VM_Path}/snapshots"
#export Snapshots_List="${Snapshots_Path}/${Source_VM_Name}_snapshots.list"


SNAPSHOT_NAMES=$(cat "${Snapshots_List}")

#echo ${SNAPSHOT_NAMES}
#exit 0

for Snapshot_Name in ${SNAPSHOT_NAMES}
do
	if [ ! -z ${Snapshot_Name} ]
	then
#		echo "Exporting snapshot: ${Snapshot_Name} "
		virsh snapshot-create ${Destination_VM_Name} ${Snapshots_Path}/${Snapshot_Name}.xml --redefine

		if [ $? -eq 0 ]
		then
			echo "[SUCCESS] Imported snapshot: ${Snapshots_Path}/${Snapshot_Name}.xml"
		else
			echo "[FAIL] Imported snapshot: ${Snapshots_Path}/${Snapshot_Name}.xml"
			exit 1
		fi
	else
		echo "[FAIL] Empty snapshot name is invalid!!!"
		exit 1
	fi
done

echo "[SUCCESS] Import new VM success!"
sudo systemctl restart libvirtd
virsh list --all

virsh snapshot-list ${Destination_VM_Name} --tree

