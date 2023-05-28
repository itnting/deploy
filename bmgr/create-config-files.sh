# This is the second local env configuration script, this creates configuration files that bmgr needs for tftp, dhcp and grub. 
# It needs IP information for some of the variables so happens later

source bmgr-running-vars.sh

isohttp="http://${guestip}/${isos}/${cdrom}"
#turns out that last / is rather important in the path as well.
surl="http://${guestip}/build/hsts/"
isonfs=${cdrom_path}
nfsroot="${hstip}:${tftp}/images/${ver}"
uefipath="/jammy-uefi"
httpiso="${hstip}:${tftp}${uefipath}/${cdrom}"


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
sudo mkdir ${tftp}/UEFI/pxelinux.cfg/
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
#dont need doing UEFI a new way
sudo cp ${tftp}/pxelinux.cfg/default ${tftp}/UEFI/pxelinux.cfg/default
