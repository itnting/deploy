#Check to see if the vm is running and build if it does not exist.
IFS=' '
result=$(virsh domstate ${vm})
state=$?
read -a result <<< ${result}

if [ $state -ne 0 ]
then
  echo "${vm} does not exist so lets build it..."
  echo "Deploy ${vm}..."

  echo "Create seed iso..."
  sudo cloud-localds ${bmgr_seed} ${bmgr_auto}/user-data ${bmgr_auto}/meta-data

  echo "Deploying ${vm}..."
  virt-install \
  --name $vm \
  --os-variant ubuntu22.04 \
  --vcpus 2 \
  --memory 2048 \
  --disk pool=vm1-vms,size=10,bus=virtio \
  --disk path=${bmgr_seed},format=raw,cache=none,bus=virtio,perms=ro \
  --location ${cdrom_path},kernel=casper/vmlinuz,initrd=casper/initrd \
  --check path_in_use=off \
  --network network=LAN,model=virtio \
  --sound none  \
  --graphics none \
  --noautoconsole \
  --extra-args 'console=tty0 console=ttyS0,115200n8 cmdline autoinstall'

  echo "Wait till vm shutdown.."
  until $(virsh domstate $vm | grep -q 'shut off')
  do
    sleep 10
  done

  echo "remove seed drive..."
  virsh detach-disk --domain $vm ${bmgr_seed} --config

  echo "start vm..."
  virsh start --domain $vm

else
  echo "${vm} does already exist so lets see whats its currently doing..."
  if [ $( echo "${result}" | grep "running" ) ]
  then
    echo "${vm} is running so sure lets assume its all built and fine..."
  elif [ $( echo "${result}" | grep "shut" ) ]
  then
    echo "${vm} is shut off so lets start it..."
    virsh start ${vm}
  else
     echo "Its all gone wrong, what have you done!"
     exit 1
  fi
fi

#wait for guest and getip to use
if [ -z "${guestip}" ]
then
  while [ -z "${guestip}" ]
  do
    guestip=$(virsh domifaddr --domain ${vm} --source agent | grep ${guestnic} | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}')  
    echo "Try again until guest agent responds..."
    sleep 5
  done
  echo "${vm} is running and has ip ${guestip}."
fi
