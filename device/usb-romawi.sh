# This script configure usb host basic settings that dont require other local paths
echo "Getting vars.."
source 710q-romawi-vars.sh

timedatectl set-timezone ${strTimeZone}

# Make sure user has sudo
echo "Configure sudo for ${strUser}"
echo "${strUser} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_${strUser}_nopasswd

#configure forwarding and iptables
echo "Confiure Forwarding..."
if grep -qFx "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl net.ipv4.ip_forward=1

# Update packages
echo "apt update and install common packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y wget mc vim p7zip virt-manager qemu tmux rsync chrony rsyslog cron nfs-common nfs-kernel-server bridge-utils debmirror cloud-image-utils cockpit cockpit-machines clamav

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
        addresses:
          - ${strHostDNS1}
          - ${strHostDNS2}
      routes:
        - to: default
          via: ${strHostDefaultRoute}
      mtu: 1500
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
