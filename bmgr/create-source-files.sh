# This runs on the deployment device as part of main.sh it creates all source files needed for the build manager server
# tftp, dhcp and grub need info with IP, that will happen after deployment and using deploy-device-configure-bmgr.sh

# get the vars needed
source bmgr-running-vars.sh

#clean known_hosts
rm ~/.ssh/known_hosts

#Maybe should move this to be done dureing host config under device!
#copy git cert to folder
echo "${sshKey_git}" > /home/${user}/.ssh/${keyName_git}

#copy ugl cert to folder
echo "${sshKey_ugl}" > /home/${user}/.ssh/${keyName_ugl}

#copy config to .ssh
echo "${sshConfig}" > /home/${user}/.ssh/config

sudo chmod 600 /home/${user}/.ssh/${keyName_git}
sudo chmod 600 /home/${user}/.ssh/${keyName_ugl}

echo "Check required packages are installed..."
sudo DEBIAN_FRONTEND=noninteractive apt install mc vim cloud-image-utils git

echo "Create TFTP ${tftp} folders..."
sudo mkdir ${tftp}
sudo mkdir ${tftp}${uefipath}
sudo mkdir ${tftp}/{images,kernels,BIOS,UEFI,grub}
sudo chmod +w -R ${tftp}
sudo mkdir ${tftp}/kernels/${ver}
sudo mkdir ${tftp}/images/${ver}

echo "Update autoinstall data ready..."
sudo mkdir -p ${tmp_auto}
sudo cp ${hsts_auto}/* ${tmp_auto}/.
sudo cp ${rootvol}/auto/* ${tftp}/images/${ver}

echo "Copy ${iso} files from ${cdrom_path}..."
sudo mount -o loop ${cdrom_path} /mnt
sudo rsync -av /mnt/. ${tftp}/images/${ver}

echo "Copy additional files..."
sudo cp -av /mnt/casper/{initrd,vmlinuz} ${tftp}/kernels/${ver}

echo "Get main uefi stuff..."
# new uefi stuff
# get packages
apt-get download shim.signed -y
apt-get download grub-efi-amd64-signed
apt-get download grub-common
#extract relevant files
dpkg-deb --fsys-tarfile shim-signed*deb | tar x ./usr/lib/shim/shimx64.efi.signed.latest -O > ${tftp}/bootx64.efi
dpkg-deb --fsys-tarfile grub-efi-amd64-signed*deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O > ${tftp}/grubx64.efi
dpkg-deb --fsys-tarfile grub-common*deb | tar x ./usr/share/grub/unicode.pf2 -O > ${tftp}/unicode.pf2

#for now copy to new uefi location
sudo cp -av /mnt/casper/{initrd,vmlinuz} ${tftp}${uefipath}
#for now copy iso to same path
if [ ! -f "${tftp}${uefipath}/${cdrom}" ]; then
  sudo cp -av ${cdrom_path} ${tftp}${uefipath}
fi
#need to get autoinstall files
sudo cp -av ${git_build}/hsts/auto/user-data ${tftp}${uefipath}
sudo cp -av ${git_build}/hsts/auto/meta-data ${tftp}${uefipath}

echo "Create syslinux path..."
sudo mkdir ${syslinux_path}
echo "Getting syslinux..."
sudo wget -q -O ${syslinux_path}/${syslinux_out}.zip  ${syslinux}

echo "Expand and copy required efi files..."
#efi
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/com32/elflink/ldlinux/ldlinux.e64
sudo cp ${syslinux_path}/efi64/com32/elflink/ldlinux/ldlinux.e64 ${tftp}/UEFI
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/com32/libutil/libutil.c32
sudo cp ${syslinux_path}/efi64/com32/libutil/libutil.c32 ${tftp}/UEFI
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/com32/menu/menu.c32
sudo cp ${syslinux_path}/efi64/com32/menu/menu.c32 ${tftp}/UEFI
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/com32/menu/vesamenu.c32
sudo cp ${syslinux_path}/efi64/com32/menu/vesamenu.c32 ${tftp}/UEFI
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/efi/syslinux.efi
sudo cp ${syslinux_path}/efi64/efi/syslinux.efi ${tftp}/UEFI
#local boot
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/com32/chain/chain.c32
sudo cp ${syslinux_path}/bios/com32/chain/chain.c32 ${tftp}/BIOS
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} efi64/com32/lib/libcom32.c32
sudo cp ${syslinux_path}/bios/com32/lib/libcom32.c32 ${tftp}/BIOS

echo "Expand and copy required BIOS files..."
#BIOS
#core
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/core/pxelinux.0
sudo cp ${syslinux_path}/bios/core/pxelinux.0 ${tftp}/BIOS
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/memdisk/memdisk
sudo cp ${syslinux_path}/bios/memdisk/memdisk ${tftp}/kernels
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/com32/elflink/ldlinux/ldlinux.c32
sudo cp ${syslinux_path}/bios/com32/elflink/ldlinux/ldlinux.c32 ${tftp}/BIOS
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/com32/libutil/libutil.c32
sudo cp ${syslinux_path}/bios/com32/libutil/libutil.c32 ${tftp}/BIOS
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/com32/menu/menu.c32
sudo cp ${syslinux_path}/bios/com32/menu/menu.c32 ${tftp}/BIOS
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/com32/menu/vesamenu.c32
sudo cp ${syslinux_path}/bios/com32/menu/vesamenu.c32 ${tftp}/BIOS
#local boot
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/com32/chain/chain.c32
sudo cp ${syslinux_path}/bios/com32/chain/chain.c32 ${tftp}/BIOS
sudo unzip -o ${syslinux_path}/${syslinux_out}.zip -d ${syslinux_path} bios/com32/lib/libcom32.c32
sudo cp ${syslinux_path}/bios/com32/lib/libcom32.c32 ${tftp}/BIOS

echo "Unmount iso..."
sudo umount /mnt
