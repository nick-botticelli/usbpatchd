#!/bin/zsh

# Copyright 2022, Nick Botticelli. <nick.s.botticelli@gmail.com>
#  
# This file is part of usbpatchd.
# 
# usbpatchd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# usbpatchd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with usbpatchd. If not, see <https://www.gnu.org/licenses/>.

#
# usbpatchd
# install-usbpatchd.sh v0.1.0
#

# Fail-fast
set -e



ORIGINALPATH="$(pwd)"
SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

SSH_PORT="4242"



function cleanup {
    cd "$ORIGINALPATH"
}

# $1 : SSH command
function SshCmd() {
    sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p $SSH_PORT root@localhost $1
}

# $1 : File/directory to send
# $2 : Remote path
function ScpUpload() {
    sshpass -p 'alpine' scp -rP $SSH_PORT -o StrictHostKeyChecking=no $1 root@localhost:$2
}



trap cleanup EXIT

cd "$SCRIPTPATH"

# Check dependencies
if ! [ -x "$(command -v sshpass)" ]
then
    echo 'sshpass is required but was not found, please install it (brew install esolitos/ipa/sshpass)!'
    exit -1
fi

if ! [ -x "$(command -v iproxy)" ]
then
    echo 'iproxy is required but was not found, please install it (brew install libusbmuxd)!'
    exit -1
fi

# Continue normal execution
echo 'You should now boot your SSH-capable ramdisk and mount the System (/dev/disk0s1s1)'
echo 'volume in /mnt1.'
echo "If you are using u/meowcat454\'s ramdisk, you should type \`bash /usr/bin/mount_root\`."
echo "After that, run iproxy with \`iproxy 4242 22\`. You may need to replace 22 with 44."

printf 'Press Enter to continue...'
head -n 1 > /dev/null

ScpUpload 'root/usr/bin/snappy' '/mnt1/usr/bin/'

SYSTEM_SNAPSHOT=$(SshCmd '/mnt1/usr/bin/snappy -s' | cut -d ' ' -f 3 | tr -d '\n')

if [[ "$SYSTEM_SNAPSHOT" == "com.apple.os.update"* ]]
then
    SshCmd '/mnt1/usr/bin/snappy -f /mnt1 -r "$SYSTEM_SNAPSHOT" -t orig-fs > /dev/null'
else
    SYSTEM_SNAPSHOT=$(SshCmd '/mnt1/usr/bin/snappy -f /mnt1 -l' | sed -n 2p | tr -d '\n')

    # If initial attempt failed, try this instead (should I just do this?)
    if [[ "$SYSTEM_SNAPSHOT" == "com.apple.os.update"* ]]
    then
        SshCmd '/mnt1/usr/bin/snappy -f /mnt1 -r "$SYSTEM_SNAPSHOT" -t orig-fs > /dev/null'
    else
        echo 'Unable to rename rootfs snapshot! Please file a bug report.'
        exit -1
    fi
fi


cd root
tar czf ../usbpatchd-install.tar.gz ./
cd ..

ScpUpload 'usbpatchd-install.tar.gz' '/mnt1/'

# TODO: Must have tar (and gzip?) installed on ramdisk
SshCmd 'cd /mnt1 && tar -xvzf usbpatchd-install.tar.gz && rm usbpatchd-install.tar.gz'

# echo 'Finished installing usbpatchd to System volume. One last step before rebooting'
# echo 'is to rename System snapshot to orig-fs. To do this, run'
# echo "\`/mnt1/usr/bin/snappy -f /mnt1 -l\`, then copy and paste the long string"
# echo '(com.apple.os.update...) and run'
# echo "\`/mnt1/usr/bin/snappy -f /mnt1 -r com.apple.os.update... -t orig-fs\`"
# echo ''
echo 'Finished installing usbpatchd.'
echo 'Now you can reboot and run checkra1n (either from CLI or from Recovery mode)'
echo 'to finish patching USB restriction. After that, SSH should now be accessible'
echo 'from the lock screen when using iproxy or tcprelay (`iproxy 2222 44`)!'
