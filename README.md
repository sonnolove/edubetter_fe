# 🎓 EduBetter - Mobile Application

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-green?style=flat)

> Ứng dụng hỗ trợ học tập thông minh tích hợp **Trí tuệ nhân tạo (AI)** và **Sinh trắc học**, giúp cá nhân hóa trải nghiệm học tập và tương tác cho sinh viên.

---

## 📑 Mục Lục
- [Giới thiệu](#-giới-thiệu)
- [Tính năng chính](#-tính-năng-chính)
- [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
- [Yêu cầu & Cài đặt](#-yêu-cầu--cài-đặt)
- [Hướng dẫn chạy dự án](#-hướng-dẫn-chạy-dự-án)
- [Khắc phục lỗi thường gặp](#-khắc-phục-lỗi-thường-gặp)

---

## 🚀 Giới thiệu

**EduBetter** là giải pháp E-learning hiện đại trên thiết bị di động. Dự án kết hợp sức mạnh của **Flutter** (Frontend), **Node.js** (Backend API Gateway) và **Python** (AI Microservice) để cung cấp các tính năng tiên tiến như Chatbot gia sư ảo và tạo đề thi tự động.

---

## ⭐ Tính năng chính

| Phân hệ | Tính năng | Mô tả |
| :--- | :--- | :--- |
| **Bảo mật** | **Sinh trắc học** | Đăng nhập nhanh bằng Vân tay / FaceID (Local Auth). |
| | **Xác thực** | Đăng ký, Đăng nhập bảo mật qua Firebase Auth. |
| **Học tập** | **Bài giảng** | Xem video (Youtube Player) và nội dung bài học chi tiết (Markdown). |
| | **Tiến độ** | Theo dõi % hoàn thành khóa học theo thời gian thực. |
| **AI** | **Chatbot** | Hỏi đáp kiến thức với gia sư ảo (Google Gemini). |
| | **Quiz Generator** | Tự động sinh đề trắc nghiệm từ nội dung bài học. |
| **Quản trị** | **Dashboard** | Quản lý môn học, bài giảng và người dùng (Phân quyền Admin). |

---

## 🏗 Kiến trúc hệ thống

Dữ liệu được xử lý theo mô hình Microservices:

`User Interaction` -> `Flutter UI` -> `API Service` -> `Node.js Backend` -> `Python AI Service`

* **Client Layer:** Flutter App (UI/UX, Local Auth).
* **Security Layer:** Firebase Auth & Local Biometrics.
* **Data Layer:**
    * Node.js: API Gateway, Logic nghiệp vụ.
    * Python: Xử lý NLP, Gemini AI.
    * Firestore: Lưu trữ dữ liệu thời gian thực.

---

## 🛠 Yêu cầu & Cài đặt

### Technical Stack
* **Language:** Dart
* **Core Framework:** Flutter SDK
* **State Management:** Provider
* **Database:** Cloud Firestore
* **Libraries:** `http`, `local_auth`, `lottie`, `carousel_slider`, `flutter_markdown`...

### Yêu cầu môi trường
1.  **Flutter SDK:** Phiên bản Stable mới nhất.
2.  **Thiết bị:**
    * Máy ảo Android (Emulator) API 35+.
    * Thiết bị thật (Bật chế độ Developer).
3.  **Backend:** Node.js và Python service đang chạy (xem repo backend).

---

## 💻 Hướng dẫn chạy dự án

### Bước 1: Cài đặt thư viện
Tại thư mục gốc của dự án, chạy lệnh:
```bash
flutter pub get
```

### Bước 2: Cấu hình Firebase
1.  Tải file `google-services.json` từ Firebase Console.
2.  Đặt vào thư mục: `android/app/`.

### Bước 3: Cấu hình Android Manifest
Đảm bảo file `android/app/src/main/AndroidManifest.xml` có các quyền sau để kết nối mạng và dùng sinh trắc học:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<application android:usesCleartextTraffic="true" ... >
```

### Bước 4: Cấu hình API Endpoint
Cập nhật địa chỉ IP Backend trong file `lib/services/api_service.dart`:
* Emulator (Máy ảo): `http://10.0.2.2:3000`
* Máy thật: `http://<IP_LAN_MAY_TINH>:3000` (Ví dụ: 192.168.1.5:3000)


### Bước 5: Khởi chạy ứng dụng
Kết nối thiết bị và chạy lệnh:
```Bash
flutter run
```
