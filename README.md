# Candyhouse Routers
## Build a Custom OpenWRT Firmware for the EA3500

_Candyhouse_ is the codename for the Cisco board that powers the Cisco/Linksys EA4500, E4200v2, and EA3500 WiFi routers.  This is presently only for the EA3500 router.
# Building OpenWRT SSAs

```bash
$ make openwrt
```

The included [Makefile](Makefile) will clone OpenWRT, patch it as appropriate, and build SSAs for the EA3500.  Note: this takes about 8GB of space.

```bash
$ make openwrt3500
```

For more info and disucssion about OpenWRT on Candyhouse routers, please visit:

[http://www.wolfteck.com/projects/candyhouse/openwrt/](http://www.wolfteck.com/projects/candyhouse/openwrt/)

## Returning to the stock firmware for reflashing

Candyhouse routers have two seperate partitions for firmware and a failed boot counter that acts as a safety mechanism. After three failed boots, the bootloader automatically stops trying to boot the failing firmware image and switches to the other partition set -- the "last known good". This build of OpenWRT will reset it to 0 on a successful boot. Since firmware flashing is currently not possible from this OpenWRT build we need to return to the stock firmware to flash new OpenWRT builds.

You can switch firmware by convincing the router it has three bad boots, either by powering off the router 5 seconds after it starts repeatedly - 3 times in succession.

Or switch by disabling the boot counter reset in OpenWRT and doing three normal reboots. You can disable the reset by ssh'ing into the router: `ssh root@192.168.1.1` and removing executable permissions for the reset script 'chmod 644 /etc/init.d/linksys_recovery'. 


# Building / Installing Modules

The specific purpose of this fork of [https://github.com/cilynx/Candyhouse-Linux/] is to allow you to add modules and programs to the build.  Especially kernel modules are specific to the built kernel version, and so it is not possible to install them from opkg unless you can find them built for your kernel version.  This builds the latest snapshot, so that may not be easy.  It also gives you a way to make .ssa firmware with your custom packages installed already.
# Cleaning Up

```bash
$ make clean
```

This will remove all of the status files, the patchlog, the uImage, the downloaded kernel source and its extracted tree.  It leaves the toolchain, so you don't have to recompile that again.

```bash
$ make distclean
```
This will also remove all the toolchain, and in fact the whole openwrt directory.
