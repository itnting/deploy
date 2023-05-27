#!/bin/bash.sh
strDevice='nvme0n1'
strVolumeGroup='vg0'

echo "Wipe /dev/${strDevice}..."
sfdisk --delete /dev/${strDevice}
echo "pvcreate /dev/${strDevice}..."
pvcreate /dev/${strDevice} -f
echo "vgcreate ${strVolumeGroup} /dev/${strDevice}"
vgcreate ${strVolumeGroup} /dev/${strDevice}
echo "lvcreate and mkfs vm1..."
lvcreate -l 100%FREE -n vm1 ${strVolumeGroup}
mkfs -t ext4 /dev/${strVolumeGroup}/vm1
echo "mount /dev/${strVolumeGroup}/vm1 and copy data..."
mount /dev/${strVolumeGroup}/vm1 /mnt
cp /vm1/* /mnt -r
umount /mnt
mount /dev/${strVolumeGroup}/vm1 /vm1
#add to fstab
echo "add to /etc/fstab..."
strFstabEntry="/dev/${strVolumeGroup}/vm1 /vm1 ext4 defaults,nofail 0 1"
if [ ! "$(grep "${strFstabEntry}" /etc/fstab)" ]; then
  echo "${strFstabEntry}" >> /etc/fstab
fi
