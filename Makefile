VERSION=3.19.5
LINUX=linux-$(VERSION)

all::
	@echo
	@echo "This Makefile allows you to add and subtract packages from the OpenWRT"
	@echo "Chaos Calmer build for the EA3500."
	@echo
	@echo "Options:"
	@echo "make openwrt3500\tBuilds pri and alt OpenWRT firmware images for EA3500"
	@echo "make openwrt-kirkwood-ea3500-pri.ssa \tBuilds just the pri OpenWRT firmware image for EA3500"
	@echo

.openwrt_fetched:
	git clone git://git.openwrt.org/15.05/openwrt.git
	touch $@

.openwrt_luci: .openwrt_fetched
	cd openwrt && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci
	cd openwrt && patch -p1 < ../patches/openwrt-config.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500-config.patch
	cp openwrt/.config .config-before-menuconfig
	# Save this so if you want to redo the whole thing, without rebuilding the toolchain.
	cd openwrt && patch -p1 < ../patches/openwrt.patch
	cd openwrt && patch -p1 < ../patches/openwrt-3500.patch
	touch $@

openwrt-kirkwood-ea3500-pri.ssa: .openwrt_luci
	cd openwrt && patch -p1 < ../patches/openwrt-pri.patch
	cd openwrt && chmod 755 target/linux/kirkwood/base-files/etc/init.d/linksys_recovery
	cd openwrt && make target/linux/clean
	# The next few lines allow you to modify the packages built into the .ssa firmware image
	# to your preferences.
	cd openwrt && ./scripts/feeds update -a && ./scripts/feeds install -a
	cd openwrt && make menuconfig
	cp openwrt/.config .config 
	# Save the .config so if you want to load it from the menuconfig, so you don't have to 
	# repeat the changes you made since the last make clean.
	cd openwrt && make oldconfig && make -j8
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500.ssa openwrt-kirkwood-ea3500-pri.ssa
	cd openwrt && patch -p1 -R < ../patches/openwrt-pri.patch


openwrt3500: openwrt-kirkwood-ea3500-pri.ssa
	cd openwrt && patch -p1 < ../patches/openwrt-alt.patch
	cd openwrt && chmod 755 target/linux/kirkwood/base-files/etc/init.d/linksys_recovery
	cd openwrt && make target/linux/clean
	cd openwrt && make oldconfig && make -j8
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500.ssa openwrt-kirkwood-ea3500-alt.ssa
	cd openwrt && patch -p1 -R < ../patches/openwrt-alt.patch

openwrt-clean::
	rm -rf *.ssa
	cd openwrt && make clean

openwrt-distclean: openwrt-clean
	rm -rf openwrt/ .openwrt*

clean: openwrt-clean

distclean: openwrt-distclean

