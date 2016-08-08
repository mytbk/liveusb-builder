# Support a new distro

## Global variables

- ``ROOTPATH``: root of a USB stick mountpoint  
- ``KERNELDIR``: the place to install the kernel  
- ``DATADIR``: the place to install other data files, e.g. squashfs, iso files  
- ``ISOMNT``: the mount point that the iso file is mounted to with ``mount_iso``  

## How to support

You can refer to [Arch Linux](distro/arch/). What you need is:

- ``install.sh``: a script file describing how to install the LiveCD to USB  
- ``isoinfo``: all info about the iso file, including where to download it, the hash checksum, and a mirror list  
- ``entry*`` files: an example is [Arch Linux x86\_64](distro/arch/entry1), for more detail, look into [mkgrubcfg.sh](mkgrubcfg.sh)

In ``isoinfo``, ``ISOURL`` is the relative path to a mirror that shows the URL of the Live ISO file. You can use ``SHA256``,``SHA1`` or ``MD5`` for iso file checksum. ``install_live`` in ``install.sh`` is the bash function that handles the install of the Live ISO to the USB stick.

