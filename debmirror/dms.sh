#!/bin/bash

## Setting variables with explanations.

#
# Don't touch the user's keyring, have our own instead
#
export GNUPGHOME=/vm1/debmirror/mirrorkeyring

# Arch=         -a      # Architecture. For Ubuntu can be i386, powerpc or amd64.
# sparc, only starts in dapper, it is only the later models of sparc.
# For multiple  architecture, use ",". like "i386,amd64"

arch=amd64

# Minimum Ubuntu system requires main, restricted
# Section=      -s      # Section (One of the following - main/restricted/universe/multiverse).
# You can add extra file with $Section/debian-installer. ex: main/debian-installer,universe/debian-installer,multiverse/debian-installer,restricted/debian-installer
#
section=main,restricted,universe,multiverse

# Release=      -d      # Release of the system (, focal ), and the -updates and -security ( -backports can be added if desired)
# List of updated releases in: https://wiki.ubuntu.com/Releases
# List of sort codenames used: http://archive.ubuntu.com/ubuntu/dists/

release=jammy,jammy-security,jammy-updates

# Server=       -h      # Server name, minus the protocol and the path at the end
# CHANGE "*" to equal the mirror you want to create your mirror from. au. in Australia  ca. in Canada.
# This can be found in your own /etc/apt/sources.list file, assuming you have Ubuntu installed.
#
#server=archive.ubuntu.com
server=mirror.internet.asn.au

# Dir=          -r      # Path from the main server, so http://my.web.server/$dir, Server dependant
#
inPath=/pub/ubuntu/archive

# Proto=        --method=       # Protocol to use for transfer (http, ftp, hftp, rsync)
# Choose one - http is most usual the service, and the service must be available on the server you point at.
# For some "rsync" may be faster.
proto=http

# Outpath=              # Directory to store the mirror in
# Make this a full path to where you want to mirror the material.
#
outPath=/vm1/debmirror/ubuntu-mirror

# The --nosource option only downloads debs and not deb-src's
# The --progress option shows files as they are downloaded
# --source \ in the place of --no-source \ if you want sources also.
# --nocleanup  Do not clean up the local mirror after mirroring is complete. Use this option to keep older repository
# Start script
#
echo "Starting mirror @ $(date)..." >> /var/log/debmirror
debmirror       -a $arch \
                --no-source \
                -s $section \
                -h $server \
                -d $release \
                -r $inPath \
                --progress \
                --method=$proto \
                --exclude-deb-section=games \
                $outPath
echo "Finished mirror @ $(date) with exit code $?." >> /var/log/debmirror
                
# removed these exclusions as to much was broken
#                --exclude-deb-section=electronics \
#                --exclude-deb-section=embeded \
#                --exclude-deb-section=gnome \
#                --exclude-deb-section=gnu-r \
#                --exclude-deb-section=gnustep \
#                --exclude-deb-section=graphics \
#                --exclude-deb-section=kde \
#                --exclude-deb-section=lisp \
#                --exclude-deb-section=science \
#                --exclude-deb-section=sound \
#                --exclude-deb-section=video \
#                --exclude-deb-section=xfce \
#                --exclude-deb-section=hamradio \
#                --exclude-deb-section=haskell \
#                --exclude-deb-section=newsgroups \
#                --exclude-deb-section=news \
#                --exclude-deb-section=zope \                

#### End script to automate building of Ubuntu mirror ####
