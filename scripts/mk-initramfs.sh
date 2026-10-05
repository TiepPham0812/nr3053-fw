#!/bin/bash
# Tao file FIT chay thu trong RAM: kernel + DTB + rootfs (cpio, khong nen).
# Kernel OpenWrt bat BLK_DEV_INITRD nhung tat moi kieu giai nen ramdisk,
# nen ramdisk phai la cpio KHONG NEN.
# Dung: mk-initramfs.sh <root.squashfs> <kernel.lzma> <board.dtb> <output.itb>
set -euo pipefail
SQ=$(readlink -f "$1"); KL=$(readlink -f "$2"); DTB=$(readlink -f "$3"); OUT=$(readlink -f -m "$4")
SUDO=""; [ "$(id -u)" = 0 ] || SUDO=sudo

W=$(mktemp -d)
trap '$SUDO rm -rf "$W"' EXIT
cd "$W"

$SUDO unsquashfs -q -d root "$SQ" >/dev/null

# /init giong het target/linux/generic/other-files/init cua OpenWrt:
# INITRAMFS=1 de preinit KHONG mount phan vung NAND.
$SUDO tee root/init >/dev/null <<'EOF'
#!/bin/sh
# Copyright (C) 2006 OpenWrt.org
export INITRAMFS=1

# switch to tmpfs to allow run daemons in jail on initramfs boot
DIRS=$(echo *)
NEW_ROOT=/new_root

mkdir -p $NEW_ROOT
mount -t tmpfs tmpfs $NEW_ROOT

cp -pr $DIRS $NEW_ROOT

exec switch_root $NEW_ROOT /sbin/init
EOF
$SUDO chmod 755 root/init
$SUDO mkdir -p root/dev
[ -e root/dev/console ] || $SUDO mknod -m 600 root/dev/console c 5 1

(cd root && $SUDO find . -mindepth 1 | LC_ALL=C sort | $SUDO cpio -o -H newc -R 0:0 --quiet) > initrd.cpio

cp "$KL" kernel.lzma
cp "$DTB" board.dtb
cat > rd.its <<'EOF'
/dts-v1/;
/ {
	description = "ARM64 ImmortalWrt FIT - SDMC NR3053 USB (RAM test)";
	#address-cells = <1>;
	images {
		kernel-1 {
			description = "ARM64 ImmortalWrt Linux (chinh hang)";
			data = /incbin/("kernel.lzma");
			type = "kernel";
			arch = "arm64";
			os = "linux";
			compression = "lzma";
			load = <0x48000000>;
			entry = <0x48000000>;
			hash-1 { algo = "crc32"; };
			hash-2 { algo = "sha1"; };
		};
		fdt-1 {
			description = "SDMC NR3053 device tree (USB enabled)";
			data = /incbin/("board.dtb");
			type = "flat_dt";
			arch = "arm64";
			compression = "none";
			hash-1 { algo = "crc32"; };
			hash-2 { algo = "sha1"; };
		};
		initrd-1 {
			description = "SDMC NR3053 rootfs (RAM)";
			data = /incbin/("initrd.cpio");
			type = "ramdisk";
			arch = "arm64";
			os = "linux";
			compression = "none";
			hash-1 { algo = "crc32"; };
			hash-2 { algo = "sha1"; };
		};
	};
	configurations {
		default = "config-1";
		config-1 {
			description = "SDMC NR3053 RAM test";
			kernel = "kernel-1";
			fdt = "fdt-1";
			ramdisk = "initrd-1";
		};
	};
};
EOF
mkimage -f rd.its "$OUT" >/dev/null
dumpimage -l "$OUT" | grep -E "Image|Type|Data Size|Default|Ramdisk"
echo "Kich thuoc: $(stat -c %s "$OUT") byte"
