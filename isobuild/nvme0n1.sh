#!/bin/bash.sh
strDevice='nvme0n1'
strVolumeGroup='vg0'

sfdisk --delete /dev/${strDevice}
pvcreate /dev/${strDevice} -f
vgcreate ${strVolumeGroup} /dev/${strDevice}
lvcreate -l 100%FREE -n vm1 ${strVolumeGroup}
