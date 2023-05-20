# This code configures a base deployed machine as a host for deployment
# device specific vars
strMachineType='710q'
strHostInterface='enp0s31f6'

# path vars
strPathSeed=/data

strPathGitRoot=/git
strPathGitBranch=${strPathGitRoot}/dev
strPathVM=/vm1
strPathSeedclamav=${strPathSeed}/clamav
strPathVMclamav=${srtPathVM}/clamav
strPathVMxml=${strPathSeed}/xml

strUser=dstote

# IP vars
strHostIP='192.168.30.4'
strHostDNS1='8.8.8.8'
strHostDNS2='8.8.4.4'
strHostDefaultRoute='192.168.30.1'

#clam AV local mirror
echo "Copying clamav seed..."
rsync -av ${strPathSeedclamav} ${stPathVM}/
cp ${strPathVMclamav}/freshclam.conf /etc/clamav
cp ${strPathVMclamav}/usr.bin.freshclam /etc/apparmor.d
chown clamav:clamav /etc/clamav/freshclam.conf
chown clamav:clamav -R ${strPathVMclamav}
apparmor_parser -r /etc/apparmor.d/usr.bin.freshclam
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam

# visrh
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
systemctl restart nfs-server

git config --global core.editor "vim"

#configure forwarding and iptables
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl net.ipv4.ip_forward=1
echo Copying /data/vm1 to /vm1
# folder is now created in deployment as part of disk layout
# mkdir /vm1 

mkdir ${gitbase}
mkdir ${gitlive}
mkdir ${gitdev}

#copy git not required anymore
#cp /data/git/* /git -r
cp /data/vm1/* /vm1 -r

# this does not fit on test machine, also it might go on NAS anyway
#cp /data/vm1/debmirror* /vm1/debmirror -r

cp /data/git/*.pem /root/.ssh
cp /data/git/root_config /root/.ssh/config
chmod 600 /root/.ssh/*.pem

cp /data/git/*.pem /home/${user}/.ssh
cp /data/git/admin_config /home/${user}/.ssh/config
chown ${user}:${user} /home/${user}/.ssh/*.pem
chown ${user}:lobal user.email "registrations@fmcrr.com"
git clone git@github:fmcrr/build ${gitdev}/build
git clone git@github:fmcrr/ansible-deploy ${gitdev}/ansible-deploy

echo Applying netplan...
netplan apply
sleep 5

#This script configures a new host to be kvm server
#need to create /vm1 and /vm1/vms /vm1/isos

# not needed done on autoinstall
# echo 'administrator ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_admin_nopasswd

#clam AV local mirror
echo "Copying clamav seed..."
rsync -av /data/clamav /vm1/
cp /vm1/clamav/freshclam.conf /etc/clamav
cp /vm1/clamav/usr.bin.freshclam /etc/apparmor.d
chown clamav:clamav /etc/clamav/freshclam.conf
chown clamav:clamav -R /vm1/clamav
apparmor_parser -r /etc/apparmor.d/usr.bin.freshclam
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam

# visrh
xml="/data/build/hsts/xml"
virsh net-define ${xml}/LAN.xml
virsh net-autostart LAN
virsh net-start LAN

virsh pool-define ${xml}/vm1-vms.xml
virsh pool-autostart vm1-vms
virsh pool-start vm1-vms

virsh pool-define ${xml}/isos.xml
virsh pool-autostart isos
virsh pool-start isos

echo "/vm1 *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
systemctl restart nfs-server

git config --global core.editor "vim"

#configure forwarding and iptables
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl net.ipv4.ip_forward=1${user} /home/${user}/.ssh/config
chmod 600 /home/${user}/.ssh/*.pem

# ln /data/debmirror for now, will need to copy over debmirror at somepoint if local though!
echo "apt update and install common packages..."
ln -s /data/debmirror /vm1/debmirror
cp /data/debmirror/sources.list /etc/apt
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y mc vim p7zip virt-manager qemu tmux rsync chrony rsyslog cron nfs-kernel-server bridge-utils debmirror cloud-image-utils cockpit cockpit-machines clamav

cat <<EOF > /root/.vimrc
colorscheme blue
syntax on
EOF

#remove all other .yml 's
rm /etc/netplan/*
#create new netplans
#This is for the built in interface which was not being used
cat <<EOF > /etc/netplan/00-main.yaml
network:
  version: 2
  ethernets:
    ${hostint}:
      dhcp4: false
EOFlobal user.email "registrations@fmcrr.com"
git clone git@github:fmcrr/build ${gitdev}/build
git clone git@github:fmcrr/ansible-deploy ${gitdev}/ansible-deploy

echo Applying netplan...
netplan apply
sleep 5

#This script configures a new host to be kvm server
#need to create /vm1 and /vm1/vms /vm1/isos

# not needed done on autoinstall
# echo 'administrator ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_admin_nopasswd

#clam AV local mirror
echo "Copying clamav seed..."
rsync -av /data/clamav /vm1/
cp /vm1/clamav/freshclam.conf /etc/clamav
cp /vm1/clamav/usr.bin.freshclam /etc/apparmor.d
chown clamav:clamav /etc/clamav/freshclam.conf
chown clamav:clamav -R /vm1/clamav
apparmor_parser -r /etc/apparmor.d/usr.bin.freshclam
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam

# visrh
xml="/data/build/hsts/xml"
virsh net-define ${xml}/LAN.xml
virsh net-autostart LAN
virsh net-start LAN

virsh pool-define ${xml}/vm1-vms.xml
virsh pool-autostart vm1-vms
virsh pool-start vm1-vms

virsh pool-define ${xml}/isos.xml
virsh pool-autostart isos
virsh pool-start isos

echo "/vm1 *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
systemctl restart nfs-server

git config --global core.editor "vim"

#configure forwarding and iptables
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl net.ipv4.ip_forward=1
cat <<EOF > /etc/netplan/01-br0.yaml
network:
  version: 2
  bridges:
    br0:
      interfaces: [${hostint}]
      parameters:
        stp: false
        forward-delay: 4
      dhcp4: true
      dhcp6: false
EOF

cat <<EOF > /usr/lib/systemd/network/99-default.link
[Match]
OriginalName=*

[Link]
NamePolicy=keep kernel database onboard slot path
AlternativeNamesPolicy=database onboard slot path
MACAddressPolicy=none
EOF

echo Check git install and get latest repos to ${gitdev}...
DEBIAN_FRONTEND=noninteractive apt -y install git
cd ${gitdev}
git config --global user.email "registrations@fmcrr.com"
git clone git@github:fmcrr/build ${gitdev}/build
git clone git@github:fmcrr/ansible-deploy ${gitdev}/ansible-deploy

echo Applying netplan...
netplan apply
sleep 5

#This script configures a new host to be kvm server
#need to create /vm1 and /vm1/vms /vm1/isos

# not needed done on autoinstall
# echo 'administrator ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_admin_nopasswd

#clam AV local mirror
echo "Copying clamav seed..."
rsync -av /data/clamav /vm1/
cp /vm1/clamav/freshclam.conf /etc/clamav
cp /vm1/clamav/usr.bin.freshclam /etc/apparmor.d
chown clamav:clamav /etc/clamav/freshclam.conf
chown clamav:clamav -R /vm1/clamav
apparmor_parser -r /etc/apparmor.d/usr.bin.freshclam
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam

# visrh
xml="/data/build/hsts/xml"
virsh net-define ${xml}/LAN.xml
virsh net-autostart LAN
virsh net-start LAN

virsh pool-define ${xml}/vm1-vms.xml
virsh pool-autostart vm1-vms
virsh pool-start vm1-vms

virsh pool-define ${xml}/isos.xml
virsh pool-autostart isos
virsh pool-start isos

echo "/vm1 *(rw,no_root_squash,no_subtree_check)" >> /etc/exports
systemctl restart nfs-server

git config --global core.editor "vim"

#configure forwarding and iptables
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl net.ipv4.ip_forward=1



