DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y xubuntu-desktop xrdp firefox udisks2-lvm2  filezilla tigervnc-viewer gparted remmina --ignore-missing 
DEBIAN_FRONTEND=noninteractive apt-get remove -y evolution* thunderbird gdm libreoffice*
DEBIAN_FRONTEND=noninteractive apt-get autoremove

#Add to ./ssh/config 
if [ -f "/root/.ssh/config" ]; then
  if [ ! "$(grep "FowardX11=yes" /root/.ssh/config)" ]; then
    echo "ForwardX11=yes" >> /root/.ssh/config
  fi
else
  echo "ForwardX11=yes" >> /root/.ssh/config
fi

update-alternatives --config x-session-manager 
#pick option 2
