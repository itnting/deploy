# This code configures a base deployed machine as a host for deployment
# script is intended to be run as root
# The seed volume needs to be mounted before running

# device specific vars
strMachineType='710q'
strHostInterface='enp0s31f6'
strTimeZone='Australia/Brisbane'

# path vars
strPathSeed="/data"
strPathGitRoot="/git"
strPathGitBranch="${strPathGitRoot}/home"
strPathVM="/vm1"
strClamav="clamav"
strPathVMxml="${strPathSeed}/deploy/xml"

strPathGitBase="/git"
strGitBranch="home"
strPathGitBranch="${strPathGitBase}/${strGitBranch}"

strUser="administrator"

# IP vars
strHostIP='192.168.30.4'
strHostDNS1='8.8.8.8'
strHostDNS2='8.8.4.4'
strHostDefaultRoute='192.168.30.1'

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
