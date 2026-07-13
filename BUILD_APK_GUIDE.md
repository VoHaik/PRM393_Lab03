# Hướng Dẫn Đóng Gói Ứng Dụng (Build APK Guide)

Tài liệu này hướng dẫn chi tiết các bước chuẩn bị, cấu hình và lệnh đóng gói ứng dụng **Journal Trend Analyzer** thành tệp cài đặt **`.apk`** trên thiết bị Android, bao gồm cả các lưu ý sửa lỗi biên dịch đặc thù trên môi trường Windows.

---

## 📋 1. Chuẩn Bị Trước Khi Build

1.  **Flutter SDK**: Đảm bảo máy tính đã cài đặt Flutter (phiên bản khuyến nghị: `3.22.0` trở lên, máy hiện tại đang chạy `3.44.2`).
2.  **Android SDK**: Cài đặt đầy đủ Android SDK Platform và Build-tools (thông qua Android Studio).
3.  **Đường dẫn Flutter**: Nếu terminal chưa nhận diện lệnh `flutter`, hãy thay thế bằng đường dẫn tuyệt đối đến tệp thực thi của Flutter trên máy của bạn (Ví dụ: `D:\flutter\bin\flutter.bat`).

---

## 🛠️ 2. Luồng Cấu Hình Tối Ưu Hệ Thống (Đã Tích Hợp)

Để tệp APK build ra chạy ổn định và không gặp lỗi, các cấu hình sau đã được thiết lập sẵn trong mã nguồn:

### A. Cấp quyền mạng (Fix lỗi mất kết nối `Failed host lookup`)
Ở chế độ Release, Android chặn kết nối Internet theo mặc định. Quyền truy cập mạng đã được khai báo tại dòng 2 tệp [AndroidManifest.xml](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### B. Tắt biên dịch gia tốc Kotlin (Fix lỗi build liên ổ đĩa `different roots`)
Do dự án đặt ở ổ `D:\` và bộ nhớ đệm Flutter ở ổ `C:\`, trình biên dịch gia tốc Kotlin sẽ báo lỗi relative path. Cấu hình sau đã được thiết lập trong [gradle.properties](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/android/gradle.properties):
```properties
kotlin.incremental=false
ksp.incremental=false
```

### C. Đồng bộ Icon và Thư viện mới (Fix lỗi `IconData` final class)
Thư viện hiển thị biểu tượng đã được nâng cấp lên `font_awesome_flutter: ^11.0.0` trong [pubspec.yaml](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/pubspec.yaml) để tương thích hoàn toàn với Flutter SDK mới.

---

## 🚀 3. Quy Trình Chạy Lệnh Build APK

Mở cửa sổ dòng lệnh (Terminal) tại thư mục gốc của dự án (`D:\PRM_CP2\Journal-Trend-Analysis-Mobile-Application`) và chạy tuần tự các lệnh sau:

### Bước 3.1: Dọn dẹp bộ nhớ đệm cũ (Clean Build)
Xóa bỏ hoàn toàn các file biên dịch trung gian bị lỗi trước đó:
```powershell
D:\flutter\bin\flutter.bat clean
```

### Bước 3.2: Tải lại danh sách thư viện (Pub get)
Đồng bộ hóa lại toàn bộ thư viện cần thiết dựa trên cấu hình mới:
```powershell
D:\flutter\bin\flutter.bat pub get
```

### Bước 3.3: Tiến hành đóng gói APK Release
Kích hoạt tiến trình biên dịch tối ưu hóa mã nguồn và nén thành tệp cài đặt Release APK:
```powershell
D:\flutter\bin\flutter.bat build apk --release
```

---

## 📦 4. Kết Quả Biên Dịch & Cài Đặt

Sau khi lệnh ở **Bước 3.3** báo biên dịch thành công (`√ Built build\app\outputs\flutter-apk\app-release.apk`), bạn hãy thực hiện:

1.  **Lấy tệp cài đặt**: Mở thư mục đầu ra chứa tệp APK cài đặt chính thức:
    *   Đường dẫn: [build/app/outputs/flutter-apk/app-release.apk](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/build/app/outputs/flutter-apk/app-release.apk)
2.  **Cài đặt lên điện thoại**:
    *   Kết nối điện thoại với máy tính và sao chép tệp `app-release.apk` vào bộ nhớ điện thoại.
    *   Mở trình quản lý tệp trên điện thoại, chọn tệp APK này để cài đặt (nhớ cấp quyền cài đặt ứng dụng từ nguồn không xác định nếu hệ điều hành Android yêu cầu).
3.  **Nộp bài**: Bạn có thể sử dụng trực tiếp tệp APK này để đính kèm vào phần thư mục nộp bài Lab 2.
