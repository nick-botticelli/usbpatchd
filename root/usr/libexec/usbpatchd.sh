#!/bin/bash

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
# usbpatchd.sh v0.1.0
#

# Allow writing to System
/sbin/mount -o rw,union,update -t apfs /dev/disk0s1s1 /

# Unlock files
/usr/bin/chflags -R nouchg /private/var/mobile/Library/UserConfigurationProfiles

# Patch USB restriction
/usr/bin/plutil -key restrictedBool -key allowUSBRestrictedMode -dict -key value -0 /private/var/mobile/Library/UserConfigurationProfiles/EffectiveUserSettings.plist
/usr/bin/plutil -key restrictedBool -key allowUSBRestrictedMode -dict -key value -0 /private/var/mobile/Library/UserConfigurationProfiles/PublicInfo/PublicEffectiveUserSettings.plist

# Lock files to prevent modification of USB restriction settings
/usr/bin/chflags -R uchg /private/var/mobile/Library/UserConfigurationProfiles
