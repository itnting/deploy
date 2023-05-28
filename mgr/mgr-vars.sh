gitbase="/git"
gitdev="${gitbase}/dev"
gitlive="${gitbase}/live"

ansible_deploy="${gitlive}/ansible-deploy"
maint_script="maint_all_nodes"
maint_cron="/etc/cron.daily/${maint_script}"
maint_play="${maint_script}.yml"
crontab="/etc/crontab"

timezone="Australia/Brisbane"
rootvol="/vm1"
datavol="/data"
#path is the local path to the repo, this should of been downloaded and in /git/live
#this will need to be copied on the host first, either copy /data/git or /git/dev to /git/live
#in an offline scenario copy /data/git to /git/live
#in online scenario copy /git/dev /git/live

path="${gitlive}/build/mgr"
isopath="${rootvol}/isos"
isoimage="ubuntu-22.04.2-live-server-amd64.iso"

pool='vm1-vms'
voltype='qcow2'

host="${env}01"
hstnic='br0'
vm='mgr'
user='administrator'
guestnic='enp1s0'

# mgr-config.sh
#dhstip='10.30.1.2'
hstip='10.30.1.11'

debmirrorpath="${datavol}/debmirror"
debmirrorloc="${rootvol}/debmirror"

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
