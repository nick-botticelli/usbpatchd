# usbpatchd

Patch the USB restriction on iOS, which blocks USB accessories from accessing the device.
This can be used to provide SSH over USB (courtesy of dropbear) from a locked
iOS device.

This is a free alternative to "minaUSB patcher" that is not as buggy or malicious—there
have been numerous reports of "minaUSB patcher" deleting and hiding files it has no
right to.

Most files in this repository have been aligned similar to the checkra1n bootstrap
(/binpack); as such, the GPLv3 license applies as labelled in the [License section](#license)
to only the files that I have written (and therefore claim copyright on).

## Using
1. Boot into an SSH ramdisk capable of SSH and mounting the System volume
    * A ramdisk capable of such can be created through a free public tool
    created by u/meowcat454 which can be found
    [here](https://web.archive.org/web/20220812002341/https://www.reddit.com/r/setupapp/comments/w1irgx/how_to_boot_a_ssh_ramdisk_on_64bit_devices/)
    (instructions may not be provided, but it should be simple enough).
2. Run `install-usbpatchd.sh` from Terminal and follow any instructions.

## Notes
* You will have to run some manual commands. This shouldn't be too difficult.
I will try to improve this to let snappy run automatically in the future.
* This is a work in progress. Pull requests are encouraged.
* As this is a work in progress, stability should not be expected. This
script has been a little buggy, but the implementation itself is one
I created for my own personal use and have found it to work perfectly
to suit my needs (i.e. tested on A10 iOS 13 via macOS 12).

## TODO
* Fix renaming snapshots automatically
* Check for gzip on SSH ramdisk
* Provide ramdisk building capabilities (submodule?)
* Determine whether .bootstrapped file should be added

## License
`install-usbpatchd.sh`, `root/Library/LaunchDaemons/com.apple.usbpatchd.plist`,
and `root/usr/libexec/usbpatchd.sh` are my copyright and are licensed with the
[GNU General Public License Version 3](./LICENSE)
