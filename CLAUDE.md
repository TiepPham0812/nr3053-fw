# Quy tắc dự án nr3053-fw

## Mục tiêu
- Firmware ImmortalWrt **chính hãng** cho router SDMC NR3053 (Viettel) đã mod USB.
- Router này là **máy dự phòng** cho router chính → ưu tiên **ổn định lâu dài**, không chạy theo tính năng mới.

## Cách build
- Dùng ImageBuilder chính hãng của ImmortalWrt (không tự biên dịch kernel).
- Chỉ thay cây thiết bị: `dtb/nr3053-usb.dtb` và `dtb/nr3053-usb2only.dtb`.
- Workflow `.github/workflows/build-nr3053.yml` mượn profile `jcg_q30-pro` để qua bước kiểm tra, rồi đổi thành NR3053 (layout UBI kernel + rootfs).
- Bước 7 của workflow là bước kiểm tra an toàn (BOARD, FIT kernel, metadata, driver USB, không có `default-settings-chn`). **Không được nới lỏng hay xoá các kiểm tra này để build qua.**

## Những điều KHÔNG được làm
- Không bật WED.
- Không chuyển sang driver/SDK MTK đóng hoặc kho gói của bên thứ ba.
- Không đụng phân vùng Factory, BL2, FIP; không đổi layout UBI.
- Không thêm `default-settings-chn` (đổi kho sang mirror Trung Quốc, múi giờ Thượng Hải).
- Không push thẳng vào nhánh chính, không tự merge PR.

## Khi sửa lỗi build
- Lỗi mạng/mirror/timeout → chỉ báo cáo và đề nghị chạy lại, không sửa code.
- Sửa ở mức tối thiểu, giải thích rõ nguyên nhân bằng tiếng Việt.
- Script trong `files/etc/` phải là LF và có quyền chạy (workflow tự xử lý ở bước 6).

## Ngôn ngữ
- Trả lời, mô tả Issue/PR bằng tiếng Việt.
