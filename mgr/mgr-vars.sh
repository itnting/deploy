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
