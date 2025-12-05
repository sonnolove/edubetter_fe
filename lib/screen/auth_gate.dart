import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/home_screen.dart';
import 'package:my_edu_app/screen/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang kiểm tra trạng thái
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Nếu có user -> Vào Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Nếu không có user (chưa login hoặc vừa logout) -> Về Login
        return const LoginScreen();
      },
    );
  }
}