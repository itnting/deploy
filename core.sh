# fncWriteToNewFile <text> <file> <mode> <user>
# mode defaults to 755 if not specified
# user defaults to the user the script is running as (root if sudo) if not specified
# Overwrites file if it exists
function fncWriteToNewFile {
  if [ -z "${1:+x}" ]; then
    echo "Need text parameter!"
  fi
  if [ -z "${2:+x}" ]; then
    echo "Need file parameter!"
  fi
  strMode="${3:-755}"
  strOwner="${4:-$(whoami)}"
  printf "Writing $1 to $2...\n"
  printf -- "$1\n" > "$2"
  echo "chmod ${strMode}..."
  chmod ${strMode} $2
  echo "chown ${strOwner}:${strOwner}..."
  chown ${strOwner}:${strOwner} $2
}

# fncWriteToFile <text> <file>
function fncWriteToFile {
  if [ -z "${1:+x}" ]; then
    echo "Need text parameter!"
  fi
  if [ -z "${2:+x}" ]; then
    echo "Need file parameter!"
  fi

  printf "Writing $1 to $2...\n"
  printf -- "$1\n" >> "$2"
}

# fncWriteToFileIfNotIn <text> <file>
function fncWriteToFileIfNotIn {
  if [ -z "${1:+x}" ]; then
    echo "Need text parameter!"
  fi
  if [ -z "${2:+x}" ]; then
    echo "Need file parameter!"
  fi
  # -q quiet -F not regex -x whole line
  if grep -qFx "$1" $2; then
    printf -- "$1 is already in $2!\n"
  else
    fncWriteToFile "$1" "$2"
  fi
}

# Creates a path to be used as mount with +i
function fncCreateMountPath {
  if [ -z "$1:+x" ]; then
    echo "fncCreateMountPath, missing parameters!"
  else
    if [ ! -d "$1" ]; then
      echo "Creating $1 with chattr +i..."
      mkdir $1
      chattr +i $1
    else
      echo "$1 already exists!"
    fi
  fi
}

# function to add an NFS mount to fstab, assume path and mount are same
# $3 specify defaults, will use defaults,nofail 0 0  otherwise
function fncAddNfsMountToFstab {
  if [ -z "$1:+x" ] || [ -z "$2:+x" ]; then
    echo "fncAddNfsMountToFstab, missing parameters!"
  else
    strDefaults=${3:-defaults,nofail 0 0}
    strFullMount="$1:$2 $2 nfs4 ${strDefaults}"
    if grep -qFx "${strFullMount}" /etc/fstab; then
      echo "Mount ${strFullMount} already exists!"
    else
      echo "Adding ${strFullMount} to /etc/fstab..."
      sh -c "echo \"${strFullMount}\" >> /etc/fstab"
    fi
  fi
}


