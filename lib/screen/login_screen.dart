import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // Thư viện sinh trắc
import 'package:shared_preferences/shared_preferences.dart'; // Thư viện lưu trữ

import 'package:my_edu_app/screen/register_screen.dart';
import 'package:my_edu_app/services/auth_service.dart';
import 'package:my_edu_app/screen/student_home_screen.dart';

// --- IMPORT MỚI ---
import 'package:my_edu_app/services/api_service.dart'; 
import 'package:my_edu_app/screen/admin/admin_dashboard.dart'; // Đảm bảo đường dẫn đúng tới file AdminDashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService(); // Khởi tạo ApiService để check quyền
  final LocalAuthentication auth = LocalAuthentication(); 

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  // --- LOGIC SINH TRẮC HỌC ---
  Future<void> _checkBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (!isEnabled) return; 

    try {
      bool canCheck = await auth.canCheckBiometrics;
      if (canCheck) {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Xác thực để đăng nhập',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );

        if (didAuthenticate && mounted) {
           // Đăng nhập thành công -> Gọi hàm điều hướng thông minh
           _navigateToHome(); 
        }
      }
    } catch (e) {
      debugPrint("Lỗi xác thực: $e");
    }
  }
  // -----------------------------

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      if (mounted) {
        // Đăng nhập Firebase thành công -> Gọi hàm điều hướng để check quyền
        await _navigateToHome();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM ĐIỀU HƯỚNG THÔNG MINH (CHECK QUYỀN ADMIN) ---
  Future<void> _navigateToHome() async {
    // 1. Hiển thị Loading Dialog để người dùng biết đang xử lý
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Gọi API kiểm tra quyền Admin
      bool isAdmin = await _apiService.isAdmin();
      
      if (!mounted) return;
      Navigator.pop(context); // Tắt dialog loading

      // 3. Điều hướng dựa trên quyền
      if (isAdmin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Nếu lỗi mạng hoặc lỗi server khi check quyền -> Mặc định cho về trang Student (an toàn)
      // Hoặc bạn có thể hiện thông báo lỗi
      print("Lỗi check quyền: $e");
      if (mounted) {
        Navigator.pop(context); // Tắt dialog
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('My Edu App', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng Nhập', style: TextStyle(fontSize: 16)),
            ),
            
            const SizedBox(height: 16),
            
            TextButton.icon(
              onPressed: _checkBiometricLogin,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Đăng nhập bằng vân tay"),
            ),

            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Chưa có tài khoản? Đăng ký ngay"),
            )
          ],
        ),
      ),
    );
  }
}