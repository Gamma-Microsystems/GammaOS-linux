#!/bin/sh
# GammaOS Builder
# ===============
# Version: 1.0
# License: AGPLv3

KERNEL=linux
KMVER=6.x
KVER=6.6.48
ARCH=x86
QARCH=x86_64
MVER=1.2.5
VER=1.0
TMPROOT=sudo

mkdir bloat && cd bloat
wget https://cdn.kernel.org/pub/linux/kernel/v$KMVER/$KERNEL-$KVER.tar.xz
tar -xvf $KERNEL-$KVER.tar.xz
cp ../configs/$KVER/.config $KERNEL-$KVER/
cd $KERNEL-$KVER
make -j$(nproc)
cp arch/$ARCH/boot/bzImage ../../base/boot
cd ..
git clone --depth 1 git://git.sv.gnu.org/coreutils.git
cd coreutils/
./bootstrap
mkdir build && cd build
../configure
make -j$(nproc)
make DESTDIR=../../../base install
cd ../../
wget https://musl.libc.org/releases/musl-$MVER.tar.gz
tar -xvf musl-$MVER
cd musl-$MVER
mkdir build && cd build
../configure
make -j$(nproc)
make DESTDIR=../../../base install
git clone https://github.com/OpenRC/openrc.git
cd openrc
mkdir build && cd build
meson ..
ninja
mkdir ../../../base/bin
cp src/*/* ../../../base/bin
cd ../../
ln -s ../base/bin/openrc-init ../base/bin/init
ln -s ../base/bin ../base/sbin
truncate -s 64MB gamma-os-$VER.img
mkfs gamma-os-$VER.img
mkdir mnt
$TMPROOT mount gamma-os-$VER.img mnt
$TMPROOT extlinux -i mnt
$TMPROOT cp -r ../base/* mnt/
$TMPROOT mkdir mnt/var mnt/root mnt/tmp mnt/dev mnt/proc
$TMPROOT umount mnt
qemu-system-$QARCH gamma-os-$VER.img -vga cirrus