#Configure Git
#Can source vars later
strPathGitBase="/git"
strGitBranch="home"
strPathGitBranch="${strPathGitBase}/${strGitBranch}"
strGitUserEmail="dstote@webnmail.net"
strGitAccount="git@git.itnting.com:itnting"
strUser="administrator"

mkdir ${strPathGitBase}
mkdir ${strPathGitBranch}

cp /data/git/*.pem /root/.ssh
cp /data/git/home_config /root/.ssh/config
chmod 600 /root/.ssh/*.pem

cp /data/git/*.pem /home/${strUser}/.ssh
cp /data/git/admin_config /home/${strUser}/.ssh/config
chown ${strUser}:${strUser} /home/${strUser}/.ssh/*.pem
chmod 600 /home/${strUser}/.ssh/*.pem

DEBIAN_FRONTEND=noninteractive apt -y install git
git config --global user.email "${strGitUserEmail}"
git config --global core.editor "vim"
git clone ${strGitAccount}/deploy ${strPathGitBranch}/deploy

