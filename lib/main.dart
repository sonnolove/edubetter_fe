import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/firebase_options.dart';
// import 'package:my_edu_app/screen/auth_gate.dart'; // <-- Tạm thời không dùng AuthGate ở đây nữa
import 'package:my_edu_app/screen/splash_screen.dart'; // <-- Import file mới tạo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Edu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // ĐỔI TỪ AuthGate() SANG SplashScreen()
      home: const SplashScreen(), 
    );
  }
}