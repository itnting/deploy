echo "Getting vars ..."
source /tmp/mgr-running-vars.sh

echo "Set timezone ${timezone}..."
sudo timedatectl set-timezone ${timezone}


#copy certs to folder
echo "${sshKey_git}" > /home/${user}/.ssh/${keyName_git}
echo "${sshKey_ugl}" > /home/${user}/.ssh/${keyName_ugl}

#copy config to .ssh
echo "${sshConfig}" > /home/${user}/.ssh/config

sudo chmod 600 /home/${user}/.ssh/${keyName_git}
sudo chmod 600 /home/${user}/.ssh/${keyName_ugl}
sudo chown ${user}:${user} /home/${user}/.ssh/${keyName_git}
sudo chown ${user}:${user} /home/${user}/.ssh/${keyName_ugl}

cat <<EOF >/home/${user}/.vimrc
colorscheme blue
syntax on
EOF
sudo cp /home/${user}/.vimrc /root/.vimrc
sudo chown ${user}:${user} /home/${user}/.vimrc


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
