#This configures the host to use USB NIC to be used as the internet source
#This is Dell USB Int
strUSBInterface="enx9cebe82231ab"

cat <<EOF > /etc/netplan/00-dock.yaml
network:
  version: 2
  ethernets:
    ${strUSBInterface}:
      dhcp4: false
  bridges:
    br1:
      dhcp4: true
      dhcp6: false
      interfaces: [${strUSBInterface}]
      mtu: 1500
      parameters:
        stp: false
        forward-delay: 4
EOF

netplan apply
