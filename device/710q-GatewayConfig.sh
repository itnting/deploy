# Make sure forwarding is enabled
echo Enable forwarding and configure firewalld...
if grep -qFx "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl net.ipv4.ip_forward=1

# Configure Firewall
# configure external
firewall-cmd --permanent --zone=external --change-interface=br1
firewall-cmd --permanent --zone=external --add-masquerade
firewall-cmd --permanent --zone=external --add-service ssh

# configure internal
firewall-cmd --permanent --zone=internal --change-interface=br0
# allow everythin on this connection
firewall-cmd --permanent --zone=internal --set-target=ACCEPT
firewall-cmd --permanent --zone=internal --add-service ssh

# Allow traffic from internal out external
firewall-cmd --permanent --new-policy policy_int_to_ext
firewall-cmd --permanent --policy policy_int_to_ext --add-ingress-zone internal
firewall-cmd --permanent --policy policy_int_to_ext --add-egress-zone external
firewall-cmd --permanent --policy policy_int_to_ext --set-priority 100
firewall-cmd --permanent --policy policy_int_to_ext --set-target ACCEPT
firewall-cmd --reload
