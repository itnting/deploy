strPathOSiso="/vm1/isos/ubuntu-22.04.2-live-server-amd64.iso -osource-files"
strPathOutput="710q-ubuntu.iso"
strUserDataFile="710q-user-data"

echo Expanding iso...
#only do this if the directory source-files does not exist
if [ ! -d "source-files" ];
then
  echo "creating source-files"
  mkdir source-files
  7z -y x ${strPathOSiso}

  echo "Moving [BOOT]..."
  mkdir BOOT
  mv ./source-files/'[BOOT]'/* BOOT
  rmdir './source-files/[BOOT]'
fi

echo Coping autoinstall files...
mkdir source-files/server
cp ./${strUserDataFile} ./source-files/server/user-data
touch ./source-files/server/meta-data
cp ./grub.cfg ./source-files/boot/grub/grub.cfg

echo Create new iso...
xorriso -as mkisofs -r \
  -V 'Ubuntu 22.04 LTS AUTO (EFIBIOS)' \
  -o ./${strPathOutput} \
  --grub2-mbr ./BOOT/1-Boot-NoEmul.img \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ./BOOT/2-Boot-NoEmul.img \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
  -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot \
  ./source-files
