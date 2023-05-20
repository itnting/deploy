# This code configures a base deployed machine as a host for deployment
# script is intended to be run as root
# The seed volume needs to be mounted before running

# device specific vars
strMachineType='710q'
strHostInterface='enp0s31f6'
strTimeZone='Australia/Brisbane'

# path vars
strPathSeed=/data
strPathGitRoot="/git"
strPathGitBranch="${strPathGitRoot}/dev"
strPathVM="/vm1"
strPathSeedclamav="${strPathSeed}/clamav"
strPathVMclamav="${srtPathVM}/clamav"
strPathVMxml="${strPathSeed}/xml"

strPathGitBase="/git"
strGitBranch="home"
strPathGitBranch="${strPathGitBase}/${strGitBranch}"

strUser="administrator"

# IP vars
strHostIP='192.168.30.4'
strHostDNS1='8.8.8.8'
strHostDNS2='8.8.4.4'
strHostDefaultRoute='192.168.30.1'
