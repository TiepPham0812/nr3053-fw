# Firmware SDMC NR3053 – ImmortalWrt chính hãng + USB

Bộ này dùng **ImageBuilder chính hãng của ImmortalWrt** để đóng firmware cho NR3053 đã mod USB.

- **Kernel là kernel chính hãng**: mọi gói `kmod-*` trong kho ImmortalWrt đều cài được bằng `apk add`, không phụ thuộc kho riêng của ai.
- **Chỉ thay cây thiết bị (DTB)** bằng bản của NR3053 đã bật USB (`dtb/nr3053-usb.dtb`).
- File ra là `.bin` cùng kiểu với bản diepkhoa, nạp được bằng U-Boot đang có trong máy.

## Có sẵn trong firmware

| Nhóm | Gói |
|---|---|
| USB | `kmod-usb3`, `kmod-usb-xhci-mtk`, `kmod-usb-storage`, `usbutils` |
| Android | `kmod-usb-net-rndis`, `kmod-usb-net-cdc-ether`, `kmod-usb-net-cdc-ncm` |
| iPhone | `kmod-usb-net-ipheth`, `usbmuxd`, `libimobiledevice` |
| Cấu hình sẵn | Múi giờ VN; interface `android` (usb0) và `iphone` (eth1) đã gắn vào vùng WAN |

## Cách build (trên GitHub, không cần máy Linux)

1. Đăng nhập GitHub → **New repository** → đặt tên (vd `nr3053-fw`) → **Public** → Create.
2. Bấm **uploading an existing file** → kéo **toàn bộ nội dung** thư mục này vào (gồm cả thư mục `.github`) → **Commit changes**.
   - Nếu trình duyệt không kéo được thư mục `.github`: bấm **Add file → Create new file**, gõ tên `.github/workflows/build-nr3053.yml`, dán nội dung file đó vào, Commit.
3. Vào tab **Actions** → nếu được hỏi thì bấm bật Actions → chọn **Build NR3053 - ImmortalWrt chinh hang + USB** → **Run workflow** → Run.
4. Chờ khoảng 5–15 phút. Dấu tích xanh là xong.
5. Tải file ở tab **Releases** (hoặc trong mục Artifacts của lần chạy):
   `immortalwrt-25.12.1-sdmc_nr3053-usb-squashfs-sysupgrade.bin`

Bước 7 của workflow tự kiểm tra: đúng board `sdmc_nr3053`, kernel là FIT của NR3053, có đủ driver USB. Sai là dừng, không xuất file.

## Cách nạp

**Lần đầu chuyển từ bản diepkhoa: KHÔNG giữ cấu hình.**

- Cách 1 (khuyên dùng): U-Boot → menu **Upgrade firmware** → TFTP → file `.bin` (giống lần nạp bản diepkhoa).
- Cách 2: U-Boot → **Start Web failsafe** → IP máy tính `192.168.1.2` → `http://192.168.1.1` → upload file.
- Cách 3: LuCI → System → Backup / Flash Firmware → bỏ tích **Keep settings**.

Sau khi lên, kiểm tra:

```
cat /etc/openwrt_release | grep -E "RELEASE|REVISION"
apk info kernel
cat /proc/device-tree/soc/usb-phy@11e10000/status; echo
lsmod | grep -E "xhci|rndis|ipheth"
```

`apk info kernel` phải ra mã kernel trùng mã thư mục kmods trên máy chủ ImmortalWrt (25.12.1: `b5b7729f...`). Sau đó `apk update && apk add <gói>` cài bình thường.

## Nếu không khởi động được

Bấm phím trong lúc bootmenu đếm ngược → **Upgrade firmware** → nạp lại
`nr3053-diepkhoa-v1.8-usb-sysupgrade.bin` (bản đang chạy ổn).
Driver cho bản đó đã được sao lưu trong `nr3053-diepkhoa-v1.8-kmods-c0119780.tar.gz`.

## Nâng cấp về sau

Khi ImmortalWrt ra bản mới (vd 25.12.2): **Run workflow**, nhập `25.12.2` vào ô phiên bản. Kernel và kho gói sẽ khớp bản mới.

## Ghi chú kỹ thuật

- ImageBuilder không tự biên dịch kernel/DTB cho thiết bị mới, nên workflow tự đóng FIT (kernel `Image` chính hãng + DTB NR3053), rồi đặt vào chỗ kernel của profile `jcg_q30-pro` được mượn để qua bước kiểm tra profile.
- Kernel nén LZMA giống hệt cách OpenWrt làm (`lc1 lp2 pb2`, có ghi kích thước thật trong header), load address `0x48000000`.
- Layout UBI: volume `kernel` + `rootfs` + `rootfs_data`, giống bản diepkhoa, tương thích U-Boot diepkhoa đang có.
- Không đụng phân vùng Factory, BL2, FIP.
