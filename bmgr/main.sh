# Note this script needs certain local dirs to be populated and ready
# ${bmgr-git_path} is the local source for the scripts that are being run, this will need to be populated beforehand
if [ -z "${env}" ]; then
  env="ugl"
fi

echo "Load vars and copy to running vars..."
source ${env}-bmgr-vars.sh
cp ${env}-bmgr-vars.sh bmgr-running-vars.sh
# This creates a copy of the vars to be used by scripts. Each script calls the running vars individually.
# Done that way so each script can be run by itself later

#echo "Configure local env..."
#source ${bmgr_git_path}/deploy-device-configure-localenv.sh

echo "Deploy ${vm} if needed..."
source ${bmgr_git_path}/deploy-vm.sh

#Get the host and guest ips and add to running vars
echo "Getting host ip..."
if [ -z "${hstip}" ]
then
  hstip=$(ip -f inet addr show ${hstnic} | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
fi
echo "Host ip ${hstip}."
echo "hstip=\"${hstip}\"" >> ${bmgr_git_path}/bmgr-running-vars.sh

echo "Getting guest ip...."
if [ -z "${guestip}" ]
then
  while [ -z "${guestip}" ]
  do
    guestip=$(virsh domifaddr --domain ${vm} --source agent | grep ${guestnic} | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}')
    echo "Try again until guest agent responds..."
    sleep 5
  done
fi
echo "Guest ip ${guestip}."
echo "guestip=\"${guestip}\"" >> ${bmgr_git_path}/bmgr-running-vars.sh

echo "Configure bmgr tftp and dhcp localally..."
source ${bmgr_git_path}/deploy-device-configure-bmgr.sh

ssh-keygen -f "/home/${user}/.ssh/known_hosts" -R "${guestip}"
ssh-keygen -f "~/.ssh/known_hosts" -R "${guestip}"
echo "Copy running vars to guest..."
scp ${bmgr_git_path}/bmgr-running-vars.sh ${user}@${guestip}:/tmp
echo "Copy config script to guest..."
scp ${bmgr_git_path}/bmgr-config.sh ${user}@${guestip}:/tmp
echo "run script on guest..."
ssh ${user}@${guestip} /tmp/bmgr-config.sh
