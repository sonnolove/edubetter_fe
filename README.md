EduBetter - Mobile Application (Frontend)
Technical Stack
Du an su dung cac cong nghe va thu vien sau cho phan ung dung di dong:

Language: Dart

Core Framework: Flutter SDK

State Management: Provider

Authentication & Database: Firebase Auth, Cloud Firestore

Networking: HTTP

Security & Hardware: Local Auth (Sinh trac hoc - Van tay/FaceID)

UI & Animations: Lottie, Carousel Slider, Flutter Markdown

Video Player: Youtube Player Flutter

System Architecture
Luong xu ly du lieu (Data Flow) cua ung dung Client trong he thong Microservices:

User Interaction -> Flutter UI -> API Service -> Node.js Backend -> Python AI Service

Quy trinh xu ly chi tiet:

Client Layer: Ung dung Flutter chiu trach nhiem hien thi giao dien, xu ly thao tac nguoi dung (cham, vuot, nhap lieu).

Security Layer: Xu ly dang nhap, dang ky qua Firebase va xac thuc sinh trac hoc cuc bo tren thiet bi.

Data Layer:

Goi API den Node.js Backend de lay du lieu khoa hoc, bai giang.

Goi API Chatbot va Quiz Generator (thong qua Node.js Gateway) de tuong tac voi AI.

Dong bo tien do hoc tap thoi gian thuc voi Firestore.

Installation and Setup
ー Install Dependencies
Tai va cai dat cac thu vien can thiet duoc khai bao trong pubspec.yaml:

Bash

flutter pub get
ー Configuration
Truoc khi khoi chay, can dam bao cac cau hinh moi truong sau:

Firebase Configuration:

Tai file google-services.json tu Firebase Console.

Dat file vao thu muc: android/app/.

Android Manifest:

Dam bao file android/app/src/main/AndroidManifest.xml da duoc cap quyen Internet va Sinh trac hoc:

XML

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
Cho phep ket noi HTTP (Cleartext Traffic) de ket noi voi Localhost Server.

MainActivity Setup:

File MainActivity.kt phai ke thua tu FlutterFragmentActivity de ho tro local_auth.

ー API Configuration
Cap nhat dia chi IP cua Backend Server trong file lib/services/api_service.dart:

May ao Android (Emulator): Su dung http://10.0.2.2:3000

Thiet bi that: Su dung IP LAN cua may tinh (vi du: http://192.168.1.x:3000)

Execution Guide
De he thong hoat dong day du, dam bao rang Backend (Node.js) va AI Service (Python) da duoc khoi chay truoc.

Terminal: Mobile App
Ket noi thiet bi (May ao hoac May that) va chay lenh sau tai thu muc goc cua du an Flutter:

Bash

flutter run
Troubleshooting
Loi man hinh bi do/treo: Kiem tra lai ket noi Server Node.js va cau hinh IP trong api_service.dart.

Loi "Duplicate GlobalKey": Thuc hien Hot Restart hoac Stop han ung dung va chay lai lenh flutter run.

Loi Sinh trac hoc tren Emulator: Can vao Settings cua Emulator -> Security de thiet lap ma PIN va them Van tay gia lap truoc khi su dung.
