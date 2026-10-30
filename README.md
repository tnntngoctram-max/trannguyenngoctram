# 🎓 Hệ thống Điểm danh Thông minh & Quản lý Học tập

Ứng dụng Flutter di động được thiết kế với phong cách cổ điển, trang nhã, kết nối đồng bộ hoàn toàn với ASP.NET Core Web API backend (`http://webapibaconca.somee.com/api`).

---

## ✨ Tính năng nổi bật & Kiến trúc hệ thống

### 1. Phân quyền & Quản lý theo Vai trò (Role-based Dashboards)
- **👨‍🎓 Sinh viên (Student)**:
  - Quét mã QR điểm danh (tích hợp định vị GPS & xác thực sinh trắc học vân tay/FaceID).
  - Xem lịch sử điểm danh cá nhân.
  - Xem thời khóa biểu cá nhân.
  - Quản lý và đăng ký môn học trực tuyến.
  - Chia sẻ & kiểm tra tọa độ vị trí GPS hiện tại.
- **👨‍🏫 Giảng viên (Teacher / Staff)**:
  - Tạo phiên điểm danh & hiển thị mã QR động thực tế với đồng hồ đếm ngược.
  - Quản lý chi tiết phiên (Làm mới mã QR, đóng phiên, theo dõi danh sách sinh viên đã điểm danh theo thời gian thực).
  - Đo tiếng ồn lớp học theo thời gian thực (Noise Measurement bằng Decibel Meter) và gửi dữ liệu lên server.
- **👑 Quản trị viên (Admin)**:
  - Xem thống kê tổng quan toàn hệ thống (Tổng số sinh viên, giảng viên, môn học, buổi học).
  - Thêm tài khoản Giảng viên và phân quyền.
  - Thêm môn học mới vào hệ thống.

### 2. Giao diện Cổ điển & Tùy chỉnh Cá nhân (Classic Theme & Settings)
- **Bảng màu cổ điển trang nhã (ColorHunt Palette)**: Tông màu ấm áp, trang trọng kết hợp terracotta và màu giấy da parchment.
- **Màn hình Cài đặt toàn diện**:
  - Xem thông tin chi tiết tài khoản (`/api/auth/me`).
  - Tùy chỉnh màu giao diện chủ đạo ngay lập tức (Terracotta, Classic Blue, Teal, Purple).
  - Tùy chỉnh cỡ chữ hiển thị (Font Scaling) từ Nhỏ đến Lớn.

---

## 🚀 Cấu hình & Kết nối Backend
- **API Base URL**: `http://webapibaconca.somee.com/api`
- **Authentication**: JWT Bearer Token lưu trữ an toàn bằng `flutter_secure_storage`.

---

## 🛠️ Công nghệ sử dụng
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Networking**: HTTP
- **Device Sensors & Features**:
  - `geolocator`: Định vị GPS.
  - `mobile_scanner`: Quét mã QR.
  - `qr_flutter`: Hiển thị mã QR động.
  - `noise_meter`: Đo cường độ âm thanh (Decibel).
  - `local_auth`: Xác thực sinh trắc học.
