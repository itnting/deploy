echo "Getting vars ..."
source /tmp/bmgr-running-vars.sh

#generate some other vars
gateway="${hstip}"
tftpip="${guestip}"
nfsip="${hstip}"

#copy git cert to folder
echo "${gitkey}" > /home/${user}/.ssh/${keyName_git}

#copy ugl cert to folder
echo "${uglkey}" > /home/${user}/.ssh/${keyName_ugl}

#copy config to .ssh
echo "${sshConfig}" > /home/${user}/.ssh/config

sudo chmod 600 /home/${user}/.ssh/git-ed25519.pem
sudo chmod 600 /home/${user}/.ssh/ugl.pem

cat <<EOF >/home/${user}/.vimrc
colorscheme blue
syntax on
EOF

echo "adding nfs mount to fstab and mounting..."
result=$(grep "/vm1" /etc/fstab)
if [ "${result}" ]; then
        echo " mount ${result} already exists."
else
        sudo su -c "echo '${hstip}:${rootvol} ${rootvol} nfs4 defaults,nofail 0 0' >> /etc/fstab"
        sudo mkdir ${rootvol}
        sudo mount ${rootvol}
fi
result=$(grep "/data" /etc/fstab)
if [ "${result}" ]; then
        echo " mount ${result} already exists."
else
        sudo su -c "echo '${hstip}:${datavol} ${datavol} nfs4 defaults,nofail 0 0' >> /etc/fstab"
        sudo mkdir ${datavol}
        sudo mount ${datavol}
fi

# create a symbolic link for now for debmirror
# eventually this needs to all be copied over unless we use NAS
# even then it will still need to be copied over but just to the one device!
sudo ln -s ${datavol}${aptmirror} ${rootvol}${aptmirror}

echo "Update and upgrade from repo {$aptmirror}..."
sudo cp ${aptmirror}/sources.list /etc/apt
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get auto-remove -y

echo "Install a few things..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install ansible git isc-dhcp-server tftpd-hpa -y

echo "clone repositorys, well just build at the moment..."
sudo mkdir ${gitbase}
sudo chown ${user}:${user} ${gitbase}

mkdir ${gitdev}
mkdir ${gitlive}

git config --global core.editor "vim"
git clone git@github:fmcrr/build.git ${gitlive}/build

echo "Configure dhcp..."
echo "Create host dhcp string..."
for i in ${!host_mac_list[@]};
do
  host_mac=${host_mac_list[${i}]}
  host_ip=${host_ip_list[${i}]}
  host_name=${host_name_list[${i}]}
  
  dhcp_hosts+=$(cat <<EOF
host ${host_name} {
  hardware ethernet ${host_mac};
  fixed-address ${host_ip};
  option host-name "${host_name}";
}

EOF
)
  dhcp_hosts+="\n"
  printf "${dhcp_hosts}" 
done
# sorts out all the new lines otherwise you get \n's in the dhcpd.conf file as cat does not seem to do this!
printf -v dhcp_hosts "${dhcp_hosts}"

sudo bash -c "cat > /etc/dhcp/dhcpd.conf" << EOF
ddns-update-style none;
default-lease-time 43200;
max-lease-time 86400;
allow booting;
allow bootp;

option arch code 93 = unsigned integer 16; # RFC4578
subnet ${subnet} netmask ${netmask} {
option routers ${gateway};
option broadcast-address ${broadcast};
option domain-name-servers ${nameservers};
range ${range};
next-server ${tftpip};
if option arch = 00:07 or option arch = 00:09 {
   filename "bootx64.efi";
}
#arm platform
#Note this URL path not exist yet
else if option arch = 00:0b {
  #this probably needs to be bootaa64.efi from ubuntu config
  filename "UEFI/aarch64/bootaa64.efi";
  }
  else {
    filename "BIOS/pxelinux.0";
  }
}
${dhcp_hosts}
EOF

echo "Configuring nginx, enabling and restarting..."
sudo rm /etc/nginx/sites-enabled/default
sudo bash -c "cat > /etc/nginx/conf.d/vm1.conf" << EOF
server {
  listen *:80;
  root /vm1;
  autoindex on;
  location /build {
    alias /data/build;
  }
}
EOF
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "Configuring tftp..."
sudo bash -c "cat > /etc/default/tftpd-hpa" << EOF
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"
INTERFACESv4="${guestnic}"
TFTP_DIRECTORY="${tftp}"
RUN_DAEMON="yes"
OPTIONS="-l -s ${tftp} -B 1468"
EOF

sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server
sudo systemctl restart tftpd-hpa
sudo systemctl enable tftpd-hpa
