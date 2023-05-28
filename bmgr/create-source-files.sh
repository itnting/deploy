# This runs on the deployment device as part of main.sh it creates all the files needed for the build manager server
# tftp, dhcp and grub need info with IP, that will happen after deployment and using deploy-device-configure-bmgr.sh

# get the vars needed
source bmgr-running-vars.sh

#This is part 1

#additional vars needed
isohttp="http://${guestip}/${isos}/${cdrom}"
#turns out that last / is rather important in the path as well.
surl="http://${guestip}/build/hsts/"
isonfs=${cdrom_path}
nfsroot="${hstip}:${tftp}/images/${ver}"
uefipath="/jammy-uefi"
httpiso="${hstip}:${tftp}${uefipath}/${cdrom}"

#clean known_hosts
rm ~/.ssh/known_hosts
#copy git cert to folder
echo "${gitkey}" > /home/${user}/.ssh/ansible-deploy-ed25519i.pem
#copy ugl cert to folder
echo "${uglkey}" > /home/${user}/.ssh/ugl.pem

echo "Copy config to .ssh..."
cat <<EOF >/home/${user}/.ssh/config
Host github
        Hostname github.com
        IdentityFile=/home/administrator/.ssh/ansible-deploy-ed25519i.pem
Host *
        IdentityFile=/home/administrator/.ssh/ugl.pem
        StrictHostKeyChecking=accept-new
EOF

sudo chmod 600 /home/${user}/.ssh/ansible-deploy-ed25519i.pem
sudo chmod 600 /home/${user}/.ssh/ugl.pem


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

# This is part 2

echo "Configuring grub menu..."
sudo bash -c "cat > ${tftp}/grub/grub.cfg" << EOF
loadfont unicode

Set color_normal=white/black
set menu_color_normal=white/blue
set menu_colorhighlight=black/light-gray

set default=nfsai  
set timeout=10

menuentry 'http' --id=httpai { 
  set gfxpayload=keep
  echo "Loading vmlinuz"
  linux /jammy-uefi/vmlinuz ip=dhcp url=${httpiso} autoinstall ds=nocloud-net\;s=${surl} root=/dev/ram0 ---
  initrd /jammy-uefi/initrd 
} 
 
menuentry 'nfs' --id=nfsai { 
  set gfxpayload=keep
  echo "Loading vmlinuz"
  linux /jammy-uefi/vmlinuz netboot=nfs boot=casper ip=dhcp rw nfsroot=${nfsroot} autoinstall ds=nocloud-net\;s=${surl} ---
  initrd /jammy-uefi/initrd
}
 
grub_platform
if [ "\$grub_platform" = "efi" ]; then
menuentry 'Boot from next volume' --id=localboot {
  exit 1
}
menuentry 'UEFI Firmware Settings' --id=uefi {
  fwsetup
}
else
menuentry 'Test memory' --id=test {
  linux16 /boot/memtest86+.bin
}
fi
EOF

echo "Configuring pxelinux..."
sudo mkdir ${tftp}/pxelinux.cfg/
sudo mkdir ${tftp}/BIOS/pxelinux.cfg/
#sudo mkdir ${tftp}/UEFI/pxelinux.cfg/
sudo bash -c "cat > ${tftp}/pxelinux.cfg/default" << EOF
PROMPT 0
TIMEOUT 100
DEFAULT menu.c32
ONTIMEOUT local

MENU TITLE ### PXE Boot ###
        
LABEL Ubuntu linux nfs
   MENU LABEL ^Install Ubuntu nfs
   kernel ../kernels/${ver}/vmlinuz
   append initrd=../kernels/${ver}/initrd \
   initrd=ubuntu/initrd.img netboot=nfs boot=casper ip=dhcp rw nfsroot=${nfsroot} autoinstall ds=nocloud-net;s=${surl} ---

LABEL Ubuntu linux http
   MENU LABEL ^Install Ubuntu http
   kernel ../kernels/${ver}/vmlinuz
   append initrd=../kernels/${ver}/initrd \
   ip=dhcp url=${isohttp} autoinstall ds=nocloud-net;s=${surl} cloud-config-url=/dev/null fsck.mode=skip ---

LABEL local
   MENU LABEL Boot local hard drive
   kernel chain.c32
   append hd0
     
LABEL memtest-console
  MENU LABEL Memtest86+ (serial console)
  KERNEL memtest
  APPEND console=ttyS1,115200n8

MENU END
EOF

sudo cp ${tftp}/pxelinux.cfg/default ${tftp}/BIOS/pxelinux.cfg/default

# While this is here, We are now doing UEFI using grub method
sudo cp ${tftp}/pxelinux.cfg/default ${tftp}/UEFI/pxelinux.cfg/default
