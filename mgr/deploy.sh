#!/bin/bash

#set env if not set already
if [ -z "${env}" ]; then
  env="ugl"
fi
echo "Environment is ${env}"
echo "Copy vars to running vars and get contents..."
cp ${env}-mgr-vars.sh mgr-running-vars.sh
chmod 755 mgr-running-vars.sh
echo "Add ${env} to running vars..."
echo "env=\"${env}\"" >> mgr-running-vars.sh
source mgr-running-vars.sh

echo "create seed ${isopath}/seed_drv.iso from ${path}/auto/ ..."
cloud-localds ${isopath}/seed_drv.iso ${path}/auto/user-data ${path}/auto/meta-data
#Check to see if the vm is running and build if it does not exist.
IFS=' '
result=$(virsh domstate ${vm})
state=$?
read -a result <<< ${result}

if [ ${state} -ne 0 ]
then
  echo "${vm} does not exist so lets build it..."
  echo "Deploy ${vm}..."
  echo "deploying..."
  virt-install \
  --name $vm \
  --os-variant ubuntu22.04 \
  --vcpus 2 \
  --memory 2048 \
  --disk pool=vm1-vms,size=40,bus=virtio \
  --disk path=${isopath}/seed_drv.iso,format=raw,cache=none,bus=virtio,perms=ro \
  --check path_in_use=off \
  --location ${isopath}/${isoimage},kernel=casper/vmlinuz,initrd=casper/initrd \
  --network network=LAN,model=virtio,mac=52:54:00:96:f7:00 \
  --sound none  \
  --graphics none \
  --noautoconsole \
  --extra-args 'console=tty0 console=ttyS0,115200n8 cmdline autoinstall'

  echo "wait till vm shutdown.."
  until $(virsh domstate $vm | grep -q 'shut off')
  do
    sleep 10
  done

  echo "remove seed drive..."
  virsh detach-disk --domain $vm ${isopath}/seed_drv.iso --config

  echo "start vm..."
  virsh start --domain $vm
  until $(virsh domstate $vm | grep -q 'running')
  do
    sleep 10
  done
else
  echo "${vm} does already exist so lets see whats its currently doing..."
  if [ $( echo "${result}" | grep "running" ) ]
  then
    echo "${vm} is running so sure lets assume its all built and fine..."
  elif [ $( echo "${result}" | grep "shut" ) ]
  then
    echo "${vm} is shut off so lets start it..."
    virsh start ${host}-${vm}
  else
     echo "Its all gone wrong, what have you done!"
     exit 1
  fi
fi
echo "Getting host ip..."
if [ -z "${hstip}" ]
then
  hstip=$(ip -f inet addr show ${hstnic} | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
  echo "hstip=\"${hstip}\"" >> ${path}/mgr-running-vars.sh
fi
echo "Host ip ${hstip}."

#wait for guest and getip to use
if [ -z "${guestip}" ]
then
  while [ -z "${guestip}" ]
  do
    guestip=$(virsh domifaddr --domain ${vm} --source agent | grep ${guestnic} | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}')  
    echo "Try again until guest agent responds..."
    sleep 5
  done
  echo "guestip=\"${guestip}\""
  sleep 5
fi

echo "removing ${guestip} from known hosts..."
ssh-keygen -f "/home/${user}/.ssh/known_hosts" -R "${guestip}"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "${guestip}"

echo "copy script to $guestip..."
scp -o StrictHostKeyChecking=accept-new mgr-config.sh ${user}@${guestip}:/tmp/config.sh
ssh ${user}@${guestip} "chmod +x /tmp/config.sh"

echo "Copy running vars to guest..."
scp mgr-running-vars.sh ${user}@${guestip}:/tmp

echo "running script on $guestip..."
ssh ${user}@${guestip} "/tmp/config.sh"
