# DigitalVAR

This repository's main purpose is to hold and document modifications done to Clonezilla (Live/SE).
These modifications were specifically targeted for our production needs.
The motivation behind such changes were done so to speed up the process 
of rebooting a server, to fix broken basic GUI features, to add basic IT functions.
Additionally, I've added a lot of scripts and basic C programs in [beast/](beast) which are used to 
automate many of our production needs for SSDs/HDDs & USBs.
 
## rebuild.sh
The following is the synopsis:

rebuild.sh OPTION

OPTION:
--beast, beast                   - Rebuild for imaging beast
--beast-chroot, beast-chroot     - Chroot into beast's rootfs
--server, server                 - Rebuild for imaging servers
--server-chroot, server-chroot   - Chroot into server's rootfs
--test-initrd, test-initrd       - Test Clonezilla-Live initrd with qemu
--initrd, initrd                 - Rebuild initrd.img for Clonezilla-Live.initrd.img

### --test-initrd, test-initrd
You will need [qemu](https://www.qemu.org/) installed in your system.

## beast

### Packages
I only had to install curl (which is included as well as its dependencies)
You could reproduce this by unsquashing and chrooting (./rebuild.sh beast-chroot)

### rc.local
 

### motd.txt
motd.txt will give you a synopsis of all the scripts and C programs
I wrote. This txt file is displayed on every tty login instance.

## server

### Linux Kernel
Will we did download the stable release (2.5.1-16). The kernel that was
shipped it with (4.9.0-2-amd64) was infact missing some entries in the 
modules.alias file for newer hardware. So I decided to update to the
latest (4.18.7 - as of 9/9/2018).
