#Host info
#will use these for DHCP and later to set them to static IP
#host_mac_list=("00:23:24:43:6a:eb" "00:23:24:43:6a:ff")
#host_mac_list=("6c:24:08:8f:dd:27")

#Origioanl UGL M70q's
#"6c:24:08:7e:ba:92" \
#"6c:24:08:8a:e8:84" \
#"6c:24:08:8a:e9:5b" \

#busways 720q's
#"98:fa:9b:69:16:42" \
#"98:fa:9b:69:1a:cc" \
#"98:fa:9b:63:57:4e" \

# Use space not a , !!
host_mac_list=( \
"98:fa:9b:69:16:42" \
"98:fa:9b:69:1a:cc" \
"98:fa:9b:63:57:4e" \
"52:54:00:96:f7:00" \
"52:54:00:96:f7:01" \
"52:54:00:96:f7:02" \
"52:54:00:96:f7:03" \
"52:54:00:96:f8:01" \
"52:54:00:96:f8:02" \
"52:54:00:96:f8:03" \
"52:54:00:96:f8:10" \
"52:54:00:96:f9:01" \
"52:54:00:96:f9:02" \
"52:54:00:96:f9:03" \
)

host_ip_list=( \
"10.30.1.11" \
"10.30.1.12" \
"10.30.1.13" \
"10.30.1.100" \
"10.30.1.111" \
"10.30.1.112" \
"10.30.1.113" \
"10.30.1.121" \
"10.30.1.122" \
"10.30.1.123" \
"10.30.1.101" \
"10.30.1.131" \
"10.30.1.132" \
"10.30.1.133" \
)

host_name_list=( \
"ugl01" \
"ugl02" \
"ugl03" \
"mgr" \
"ugl01-lb" \
"ugl01-cn" \
"ugl01-wn" \
"ugl02-lb" \
"ugl02-cn" \
"ugl02-wn" \
"ugl02-tele" \
"ugl03-lb" \
"ugl03-cn" \
"ugl03-wn" \
)


#names
pool='vm1-vms'
voltype='qcow2'
user='administrator'
vm='bmgr'
cdrom="ubuntu-22.04.2-live-server-amd64.iso"
ver="ubuntu"

# Note git live need to be populated, this can come from any sorce but in online scenario typically copied from /git/dev
# base git paths
gitbase="/git"

# These paths will be used for the live env on the bmgr vm these can be poulated from /data/git or the local /git/dev or /git/live on the host
gitlive="${gitbase}/home"
gitdev="${gitbase}/dev"

# These paths will be used locally only also need to be poulated before running the deployment script
git_build="${gitlive}/deploy"

# other paths
uefipath='/jammy-uefi'
rootvol="/vm1"
datavol="/data"
aptmirror="${rootvol}/debmirror"
isos="isos"
cdrom_path="${rootvol}/${isos}/${cdrom}"
tftp="${rootvol}/tftpboot"
bmgr_git_path="${git_build}/bmgr"
bmgr_auto="${bmgr_git_path}/auto"
bmgr_seed="${rootvol}/${isos}/seed_drv.iso"

#syslinux="https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.zip"
syslinux="https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/syslinux-6.04-pre1.zip"
syslinux_out="syslinux"
syslinux_path="${rootvol}/${syslinux_out}"

tmp_auto="${rootvol}/auto"
hsts_auto="${git_build}/hsts/auto"

# nics needed for ip detection
hstnic='br0'
guestnic='enp1s0'

#keys
sshKey_git=$(cat <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACDvtQ8x6rchHz/Skley3svVMTO5sLjPXKTRU+KVXATz6AAAAKC1H/+dtR//
nQAAAAtzc2gtZWQyNTUxOQAAACDvtQ8x6rchHz/Skley3svVMTO5sLjPXKTRU+KVXATz6A
AAAEBqowXGWyJRZR0qdL+K1i9R1fpi8BXXsDDp2ZiZ0mX8l++1DzHqtyEfP9KSV7Ley9Ux
M7mwuM9cpNFT4pVcBPPoAAAAF3JlZ2lzdHJhdGlvbnNAZm1jcnIuY29tAQIDBAUG
-----END OPENSSH PRIVATE KEY-----
EOF
)
keyName_git="git-ed25519.pem"

sshKey_ugl=$(cat <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtz
c2gtZWQyNTUxOQAAACCGJelmrKz9YcM94QVJ2BIdmQhXhdlknQQhnzavQz5bJQAA
AKAhkYIEIZGCBAAAAAtzc2gtZWQyNTUxOQAAACCGJelmrKz9YcM94QVJ2BIdmQhX
hdlknQQhnzavQz5bJQAAAEB2X7vAYhzs0hz8G2R0NuCkEolGETFsnoYl73+JSS3B
B4Yl6WasrP1hwz3hBUnYEh2ZCFeF2WSdBCGfNq9DPlslAAAAE2FkbWluaXN0cmF0
b3JAdWdsMDEBAgMEBQYHCAkK
-----END OPENSSH PRIVATE KEY-----
EOF
)
keyName_ugl="ugl.pem"

sshConfig=$(cat <<EOF
Host github
        Hostname github.com
        IdentityFile=/home/${user}/.ssh/${keyName_git}

Host *
        IdentityFile=/home/${user}/.ssh/${keyName_ugl}
        StrictHostKeyChecking=accept-new
EOF
)

#dhcp options pull host IP and guest IP
subnet="10.30.1.0"
netmask="255.255.255.0"
broadcast="10.30.1.255"
range="10.30.1.50 10.30.1.200"
nameservers="8.8.8.8,8.8.4.4"

#hstip and guestip related need to stay in script !!! Will be added below at run time.
