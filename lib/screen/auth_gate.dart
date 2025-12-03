import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/home_screen.dart'; // Màn hình chính (chưa tạo)
import 'package:my_edu_app/screen/login_screen.dart'; // Màn hình đăng nhập (chưa tạo)

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Lắng nghe sự thay đổi trạng thái đăng nhập (đăng nhập, đăng xuất)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Nếu chưa có kết quả (đang kiểm tra), hiển thị loading
        if (!snapshot.hasData) {
          // Bạn có thể tạo màn hình Splash Screen ở đây
          // return const SplashScreen(); 
          
          // Tạm thời, chúng ta sẽ hiển thị màn hình Login
          // (Lưu ý: bạn cần tạo file login_screen.dart)
          return const LoginScreen(); // GIẢ SỬ BẠN ĐÃ CÓ FILE NÀY
        }

        // Nếu đã đăng nhập (snapshot.hasData là true)
        // (Lưu ý: bạn cần tạo file home_screen.dart)
        return const HomeScreen(); // GIẢ SỬ BẠN ĐÃ CÓ FILE NÀY
      },
    );
  }
}

// --- TẠO FILE GIẢ LẬP ĐỂ TRÁNH LỖI COMPILE ---
// Bạn sẽ thay thế các file này bằng các màn hình thật sau
// (Tạo 2 file mới: lib/screens/home_screen.dart và lib/screens/login_screen.dart)

// --- File: lib/screens/home_screen.dart ---
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: Center(child: Text('Đã đăng nhập!')),
//     );
//   }
// }

// --- File: lib/screens/login_screen.dart ---
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Center(child: Text('Chưa đăng nhập')),
//     );
//   }
// }