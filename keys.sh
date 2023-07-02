# fncWriteToFile <text> <file>
function fncWriteToFile {
  if [ -z "${1:+x}" ]; then
    echo "Need text parameter!"
  fi
  if [ -z "${2:+x}" ]; then
    echo "Need file parameter!"
  fi
  printf "Writing $1 to $2...\n"
  touch "$2"
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
    touch "$2"
    fncWriteToFile "$1" "$2"
  fi
}

sshKey_root=$(cat <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAdnbvdHFI98XtvjkqoW122Y8weTnbfsR+wLtH7wRiAugAAAJChmzw+oZs8
PgAAAAtzc2gtZWQyNTUxOQAAACAdnbvdHFI98XtvjkqoW122Y8weTnbfsR+wLtH7wRiAug
AAAEApoa3G/bHxuisT5KwX7hbjz5kYAr57ivMQgX/1DOnwAx2du90cUj3xe2+OSqhbXbZj
zB5Odt+xH7Au0fvBGIC6AAAAC3Jvb3RAbWlsdG9uAQI=
-----END OPENSSH PRIVATE KEY-----
EOF
)
sshPubKey_root=$(cat <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2du90cUj3xe2+OSqhbXbZjzB5Odt+xH7Au0fvBGIC6 root
EOF
)

sshKey_admin=$(cat <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACDsFOhoqNh/R9Y5clK3nTlscLJ7V0HoVEvpYyovLnDawwAAAJB78Ak+e/AJ
PgAAAAtzc2gtZWQyNTUxOQAAACDsFOhoqNh/R9Y5clK3nTlscLJ7V0HoVEvpYyovLnDaww
AAAECNof3QIx0mf9ICNc8BVfgbUlCVPLe0Ogl/CydOliSUAuwU6Gio2H9H1jlyUredOWxw
sntXQehUS+ljKi8ucNrDAAAAC3Jvb3RAbWlsdG9uAQI=
-----END OPENSSH PRIVATE KEY-----
EOF
)
sshPubKey_admin=$(cat <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwU6Gio2H9H1jlyUredOWxwsntXQehUS+ljKi8ucNrD admin
EOF
)

sshKey_dstote=$(cat <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCYgNnK+SwoOnI9zMC1rUZUbq+dZpy/yp9G4lwoXaOIUgAAAJC6nKu8upyr
vAAAAAtzc2gtZWQyNTUxOQAAACCYgNnK+SwoOnI9zMC1rUZUbq+dZpy/yp9G4lwoXaOIUg
AAAEDUVlfaIIWmhTslg4xY3Bt7NPgXjRAkX1ELXEbtB9h9EpiA2cr5LCg6cj3MwLWtRlRu
r51mnL/Kn0biXChdo4hSAAAAC3Jvb3RAbWlsdG9uAQI=
-----END OPENSSH PRIVATE KEY-----
EOF
)
sshPubKey_dstote=$(cat <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiA2cr5LCg6cj3MwLWtRlRur51mnL/Kn0biXChdo4hS dstote
EOF
)

# Create Keys
mkdir /home/dstote/.ssh
chown dstote:dstote /home/dstote/.ssh
chmod 700 /home/dstote/.ssh
fncWriteToFile "${sshPubKey_dstote}" "/home/dstote/.ssh/id_ed25519.pub"
chown dstote:dstote /home/dstote/.ssh/id_ed25519.pub
chmod 644 /home/dstote/.ssh/id_ed25519.pub
fncWriteToFile "${sshKey_dstote}" "/home/dstote/.ssh/id_ed25519"
chown dstote:dstote /home/dstote/.ssh/id_ed25519
chmod 600 /home/dstote/.ssh/id_ed25519

fncWriteToFile "${sshPubKey_admin}" "/home/administrator/.ssh/id_ed25519.pub"
chown administrator:administrator /home/administrator/.ssh/id_ed25519.pub
chmod 644 /home/administrator/.ssh/id_ed25519.pub
fncWriteToFile "${sshKey_admin}" "/home/administrator/.ssh/id_ed25519"
chown administrator:administrator /home/administrator/.ssh/id_ed25519
chmod 600 /home/administrator/.ssh/id_ed25519

fncWriteToFile "${sshPubKey_root}" "/root/.ssh/id_ed25519.pub"
chown root:root /root/.ssh/id_ed25519.pub
chmod 644 /root/.ssh/id_ed25519.pub
fncWriteToFile "${sshKey_root}" "/root/.ssh/id_ed25519"
chown root:root /root/.ssh/id_ed25519
chmod 600 /root/.ssh/id_ed25519

# Config Authorized Keys
fncWriteToFileIfNotIn "${sshPubKey_dstote}" "/root/.ssh/authorized_keys"
fncWriteToFileIfNotIn "${sshPubKey_admin}" "/root/.ssh/authorized_keys"
fncWriteToFileIfNotIn "${sshPubKey_root}" "/root/.ssh/authorized_keys"
