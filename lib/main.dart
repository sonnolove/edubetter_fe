import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/firebase_options.dart'; // File này do FlutterFire tạo ra
import 'package:my_edu_app/screen/auth_gate.dart';
// import 'package:provider/provider.dart'; // Bỏ comment nếu bạn dùng Provider
// import 'package:my_edu_app/services/api_service.dart';
// import 'package:my_edu_app/services/auth_service.dart';

void main() async {
  // Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- KẾT NỐI FIREBASE ---
  // Bước quan trọng nhất để kết nối ứng dụng Flutter của bạn với Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Sử dụng file firebase_options.dart
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Nếu bạn dùng Provider để quản lý state (ví dụ: ApiService, AuthService)
    // bạn có thể bọc MaterialApp trong MultiProvider ở đây.
    
    // return MultiProvider(
    //   providers: [
    //     Provider<AuthService>(create: (_) => AuthService()),
    //     Provider<ApiService>(create: (_) => ApiService()),
    //   ],
    //   child: MaterialApp( ... )
    // );
    
    return MaterialApp(
      title: 'My Edu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Nền xám nhẹ
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
      // AuthGate sẽ quyết định hiển thị màn hình Login hay Home
      home: const AuthGate(),
    );
  }
}