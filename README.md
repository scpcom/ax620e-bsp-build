# AX620E BSP Build

Builds u-boot and linux kernel for Axera AX620E/AX630C based boards such as NanoKVM-Pro.

# Compiling and building yourself

If you do not want to use the prebuilt packages, you can compile yourself.

## download source

```
git clone https://github.com/scpcom/ax620e-bsp-build --depth=1
cd ax620e-bsp-build
git submodule update --init --recursive --depth=1
```
You can remove the --depth=1 parameter to get full history.

## host environment

- OS: Debian 11/Ubuntu 22.04 or higher is recommended
- CPU: AMD/Intel x86_64
- Memory: 8 GB RAM (Required to build opencv tests, all other can be complied with 4GB and below)
- Storage: 30GB free space minimum (plus optional 40GB to compile the toolchain)

On Debian/Ubuntu you can install required packages with:
```
./scripts/prepare-host.sh
```

## build it

```
./build.sh
```

# Running

Example how to run on NanoKVM-Pro.
Use at your own risk.

Replace the IP 192.168.1.234 with the address of your NanoKVM-Pro.

## transfer files to your device

```
scp -p install/nanokvm_pro_arm64_k419/*.tmp root@192.168.1.234:/root/
ssh root@192.168.1.234
```

## backup original binaries

```
dd if=/dev/mmcblk0p5 of=uboot.bin bs=4096
dd if=/dev/mmcblk0p14 of=kernel.bin bs=4096
dd if=/dev/mmcblk0p12 of=dtb.bin bs=4096
```

## insall our bsp binaries

```
dd if=uboot.bin.tmp of=/dev/mmcblk0p5 bs=4096
dd if=kernel.img.tmp of=/dev/mmcblk0p14 bs=4096
dd if=dtb.img.tmp of=/dev/mmcblk0p12 bs=4096
```

## restore original binaries

```
dd if=uboot.bin of=/dev/mmcblk0p5 bs=4096
dd if=kernel.bin of=/dev/mmcblk0p14 bs=4096
dd if=dtb.bin of=/dev/mmcblk0p12 bs=4096
```

