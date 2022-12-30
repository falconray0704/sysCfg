#!/bin/sh

. ./env_configs


SNAPSHOT_NAMES=$(cat "${Snapshots_List}")

#echo ${SNAPSHOT_NAMES}
#exit 0

for Snapshot_Name in ${SNAPSHOT_NAMES}
do
	if [ ! -z ${Snapshot_Name} ]
	then
#		echo "Exporting snapshot: ${Snapshot_Name} "
		virsh snapshot-create ${Source_VM_Name} ${Snapshots_Path}/${Snapshot_Name}.xml --redefine

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

virsh snapshot-list ${Source_VM_Name} --tree

