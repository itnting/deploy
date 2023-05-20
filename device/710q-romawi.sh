echo "Getting vars.."
source 710q-romawi-vars.sh

timedatectl set-timezone ${strTimeZone}

# Make sure user has sudo
echo "Configure sudo for ${strUser}
echo '${strUser} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_${strUser}_nopasswd

#Copy seed data
echo "Copying ${strPathSeed}${strPathVM} to ${strPathVM}..."
cp ${strPathSeed}${strPathVM}* ${strPathVM} -r

#clam AV local mirror
echo "Copying clamav seed from ${strPathSeedclamav} to ${stPathVM}/ ..."
rsync -av ${strPathSeedclamav} ${stPathVM}/
echo "Configure clamav..."
cp ${strPathVMclamav}/freshclam.conf /etc/clamav
cp ${strPathVMclamav}/usr.bin.freshclam /etc/apparmor.d
chown clamav:clamav /etc/clamav/freshclam.conf
chown clamav:clamav -R ${strPathVMclamav}
apparmor_parser -r /etc/apparmor.d/usr.bin.freshclam
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam

# this does not fit on test machine, also it might go on NAS anyway
# For now use a symlink
# cp /data/vm1/debmirror* /vm1/debmirror -r
echo Create symlink ${strPathVM}/debmirror to ${strPathSeed}/debmirror
ln -s ${strPathSeed}/debmirror ${strPathVM}/debmirror
echo Confiure debmirror sources...
cp ${strPathSeed}/debmirror/sources.list /etc/apt

# Setup Virtual network, storage from xmls
echo Define virtual network and storage...
virsh net-define ${strPathVMxml}/LAN.xml
virsh net-autostart LAN
virsh net-start LAN

virsh pool-define ${strPathVMxml}/vm1-vms.xml
virsh pool-autostart vm1-vms
virsh pool-start vm1-vms

virsh pool-define ${strPathVMxml}/isos.xml
virsh pool-autostart isos
virsh pool-start isos

# Export the VM path so other hosts can share, makes it easier to copy between hosts
echo "${strPathVM} *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
if [ ! "$(grep "${strPathVM}" /etc/exports)" ]; then
  echo "${strPathVM} *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
fi
if [ ! "$(grep "${strPathSeed}" /etc/exports)" ]; then
  echo "${strPathSeed} *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
fi
systemctl restart nfs-server

#configure forwarding and iptables
echo "Confiure Forwarding..."
if grep -qFx "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl net.ipv4.ip_forward=1

#Configure Git
#mkdir ${gitbase}
#mkdir ${gitdev}
#cp /data/git/*.pem /root/.ssh
#cp /data/git/root_config /root/.ssh/config
#chmod 600 /root/.ssh/*.pem

#cp /data/git/*.pem /home/${user}/.ssh
#cp /data/git/admin_config /home/${user}/.ssh/config
#chown ${user}:${user} /home/${user}/.ssh/*.pem
#chmod 600 /home/${user}/.ssh/*.pem

#DEBIAN_FRONTEND=noninteractive apt -y install git

#global user.email "registrations@fmcrr.com"
#git config --global core.editor "vim"
#git clone git@github:fmcrr/build ${gitdev}/build

# Update packages
echo "apt update and install common packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y mc vim p7zip virt-manager qemu tmux rsync chrony rsyslog cron nfs-kernel-server bridge-utils debmirror cloud-image-utils cockpit cockpit-machines clamav

echo "Configure vim..."
cat <<EOF > /root/.vimrc
colorscheme blue
syntax on
EOF

echo "Configure Netplans for ${strHostInterface} and bridge..."
#remove all other .yml 's
rm /etc/netplan/*
#create new netplans
#This is for the built in interface which was not being used
cat <<EOF > /etc/netplan/00-main.yaml
network:
  version: 2
  ethernets:
    ${strHostInterface}:
      dhcp4: false
EOF

cat <<EOF > /etc/netplan/01-br0.yaml
network:
  version: 2
  bridges:
    br0:
      interfaces: [${strHostInterface}]
      dhcp4: false
      dhcp6: false
      addresses:
        - ${strHostIP}/24
      nameservers:
        addresses: [${strHostDNS1}, ${strHostDNS2}]
      parameters:
        stp: false
        forward-delay: 4
EOF

cat <<EOF > /usr/lib/systemd/network/99-default.link
[Match]
OriginalName=*

[Link]
NamePolicy=keep kernel database onboard slot path
AlternativeNamesPolicy=database onboard slot path
MACAddressPolicy=none
EOF

echo Applying netplan...
netplan apply
sleep 5
