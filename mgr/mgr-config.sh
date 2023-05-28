echo "Getting vars ..."
source /tmp/mgr-running-vars.sh

echo "Set timezone ${timezone}..."
sudo timedatectl set-timezone ${timezone}

#copy git cert to folder
cat <<EOF >/home/${user}/.ssh/ansible-deploy-ed25519i.pem
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACDvtQ8x6rchHz/Skley3svVMTO5sLjPXKTRU+KVXATz6AAAAKC1H/+dtR//
nQAAAAtzc2gtZWQyNTUxOQAAACDvtQ8x6rchHz/Skley3svVMTO5sLjPXKTRU+KVXATz6A
AAAEBqowXGWyJRZR0qdL+K1i9R1fpi8BXXsDDp2ZiZ0mX8l++1DzHqtyEfP9KSV7Ley9Ux
M7mwuM9cpNFT4pVcBPPoAAAAF3JlZ2lzdHJhdGlvbnNAZm1jcnIuY29tAQIDBAUG
-----END OPENSSH PRIVATE KEY-----
EOF

#copy ugl cert to folder
cat <<EOF >/home/${user}/.ssh/ugl.pem
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtz
c2gtZWQyNTUxOQAAACCGJelmrKz9YcM94QVJ2BIdmQhXhdlknQQhnzavQz5bJQAA
AKAhkYIEIZGCBAAAAAtzc2gtZWQyNTUxOQAAACCGJelmrKz9YcM94QVJ2BIdmQhX
hdlknQQhnzavQz5bJQAAAEB2X7vAYhzs0hz8G2R0NuCkEolGETFsnoYl73+JSS3B
B4Yl6WasrP1hwz3hBUnYEh2ZCFeF2WSdBCGfNq9DPlslAAAAE2FkbWluaXN0cmF0
b3JAdWdsMDEBAgMEBQYHCAkK
-----END OPENSSH PRIVATE KEY-----
EOF

#copy config to .ssh
cat <<EOF >/home/${user}/.ssh/config
Host github
        Hostname github.com
        IdentityFile=/home/${user}/.ssh/ansible-deploy-ed25519i.pem

Host *
        IdentityFile=/home/${user}/.ssh/ugl.pem
        StrictHostKeyChecking=accept-new
EOF

cat <<EOF >/home/${user}/.vimrc
colorscheme blue
syntax on
EOF
sudo cp /home/${user}/.vimrc /root/.vimrc
sudo chown ${user}:${user} /home/${user}/.vimrc

sudo chmod 600 /home/${user}/.ssh/ansible-deploy-ed25519i.pem
sudo chmod 600 /home/${user}/.ssh/ugl.pem
sudo chown ${user}:${user} /home/${user}/.ssh/ansible-deploy-ed25519i.pem
sudo chown ${user}:${user} /home/${user}/.ssh/ugl.pem

#local repo
#sudo sh -c "echo \"${hstip}:/vm1 /vm1 nfs4 defaults,nofail 0 0\" >> /etc/fstab"
#sudo sh -c "echo \"${dhstip}:${debmirrorpath} ${debmirrorloc} nfs4 defaults,nofail 0 0\" >> /etc/fstab"

result=$(grep "${rootvol}" /etc/fstab)
if [ "${result}" ]; then
        echo " mount ${result} already exists."
else
        sudo sh -c "echo \"${hstip}:${rootvol} ${rootvol} nfs4 defaults,nofail 0 0\" >> /etc/fstab"
        sudo mkdir ${rootvol}
        sudo mount ${rootvol}
fi

#remove had to stick with one vol
#result=$(grep "${datavol}" /etc/fstab)
#if [ "${result}" ]; then
#        echo " mount ${result} already exists."
#else
#        sudo sh -c "echo \"${dhstip}:${debmirrorpath} ${debmirrorloc} nfs4 defaults,nofail 0 0\" >> /etc/fstab"
#        sudo mkdir -p ${debmirrorloc}
#        sudo mount ${debmirrorloc}
#fi

echo "Copy ${debmirrorloc}..."
sudo cp "${debmirrorloc}/sources.list" /etc/apt

echo "Updates..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo apt auto-remove -y

sudo DEBIAN_FRONTEND=noninteractive apt install nfs-common mc ansible -y
sudo mkdir ${gitbase}
sudo chown ${user}:${user} ${gitbase}
mkdir ${gitlive}
mkdir ${gitdev}

echo "Clone latest ansible git repo to ${gitdev}..."
git clone git@github:fmcrr/ansible-deploy.git ${gitdev}/ansible-deploy
git clone git@github:fmcrr/build.git ${gitdev}/build
git clone git@github:fmcrr/development.git ${gitdev}/development
git config --global core.editor "vim"
git config --global user.email "registrations@fmcrr.com"
git config --global user.name "fmcrr-admin"

# Install Cron task to run maintenance script every day

ctentry="0 3 * * *  ${user} ansible-playbook -i ${ansible_deploy}/${env}_hosts.yml ${ansible_deploy}/${maint_play} >> /var/log/ansible.log"
#allow user access to add to crontab
sudo chown ${user}:${user} ${crontab}
grep -Fx "$ctentry" "${crontab}"
found=$?
case $found in
  0)
    echo "Maintenance script is already present in ${crontab}!"
    ;;
  1)
    echo "Adding to ${crontab}: ${ctentry} ..."
    echo "${ctentry}" >> ${crontab}
    ;;
  *)
    echo "Something went wrong adding ${ctentry} to ${crontab} !"
    ;;
esac
#put permissions back
sudo chown root:root ${crontab}

#create the log file and set permissions
sudo touch /var/log/ansible.log
sudo chown ${user}:${user} /var/log/ansible.log
