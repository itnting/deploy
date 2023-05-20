DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y xubuntu-desktop xrdp firefox udisks2-lvm2  filezilla tigervnc-viewer gparted remmina --ignore-missing 
DEBIAN_FRONTEND=noninteractive apt-get remove -y *evolution thunderbird
DEBIAN_FRONTEND=noninteractive apt-get autoremove
update-alternatives --config x-session-manager 
#pick option 2 

#Add to ./ssh/config 
#ForwardX11=yes 
