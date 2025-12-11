import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Cần để check User

import 'package:my_edu_app/screen/register_screen.dart';
import 'package:my_edu_app/services/auth_service.dart';
import 'package:my_edu_app/screen/student_home_screen.dart';
import 'package:my_edu_app/services/api_service.dart'; 
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';

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
  final ApiService _apiService = ApiService();
  final LocalAuthentication auth = LocalAuthentication(); 

  @override
  void initState() {
    super.initState();
    // QUAN TRỌNG: Không gọi _checkBiometricLogin() ở đây nữa để tránh bị loop khi đăng xuất.
    // Nếu muốn tự động, phải kiểm tra kỹ hơn, nhưng tốt nhất là để người dùng tự bấm nút.
    _loadSavedEmail();
  }

  // Tiện ích: Tự điền email lần trước nếu có
  void _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  // --- LOGIC 1: ĐĂNG NHẬP THỦ CÔNG ---
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      
      // QUAN TRỌNG: Đăng nhập thành công thì Lưu thông tin vào máy để lần sau dùng vân tay
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim()); // Lưu pass để tái đăng nhập

      if (mounted) await _navigateToHome();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 2: ĐĂNG NHẬP VÂN TAY (SỬA LẠI HOÀN TOÀN) ---
  Future<void> _checkBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('biometric_enabled') ?? false;

    // 1. Kiểm tra xem người dùng đã bật tính năng này chưa
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bạn chưa bật tính năng này trong Cài đặt.")));
      return;
    }

    // 2. Kiểm tra xem đã có thông tin đăng nhập lưu trong máy chưa
    String? email = prefs.getString('saved_email');
    String? password = prefs.getString('saved_password');

    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng đăng nhập bằng mật khẩu lần đầu tiên.")));
      return;
    }

    try {
      bool canCheck = await auth.canCheckBiometrics;
      if (canCheck) {
        // 3. Quét vân tay
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Xác thực để đăng nhập',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );

        if (didAuthenticate && mounted) {
           setState(() => _isLoading = true);
           
           // 4. QUAN TRỌNG: Lấy Pass đã lưu để Đăng nhập Firebase thật sự
           try {
             await _authService.signIn(email, password);
             // Đăng nhập xong mới chuyển trang
             await _navigateToHome();
           } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thông tin lưu trữ đã cũ, vui lòng nhập lại mật khẩu.")));
           } finally {
             if (mounted) setState(() => _isLoading = false);
           }
        }
      }
    } catch (e) {
      debugPrint("Lỗi xác thực: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thiết bị không hỗ trợ hoặc chưa cài đặt vân tay.")));
    }
  }

  // --- HÀM ĐIỀU HƯỚNG ---
  Future<void> _navigateToHome() async {
    // Vì lúc này Firebase đã có user (do login thủ công hoặc login ngầm qua vân tay)
    // Nên ta check quyền bình thường
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool isAdmin = await _apiService.isAdmin();
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading

      if (isAdmin) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminDashboard()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const StudentHomeScreen()), (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        // Fallback về trang user nếu check lỗi
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const StudentHomeScreen()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView( // Thêm scroll để tránh bị che phím
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
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
              
              // Nút này bây giờ sẽ hoạt động đúng logic: Quét -> Lấy Pass cũ -> Login Firebase
              TextButton.icon(
                onPressed: _isLoading ? null : _checkBiometricLogin,
                icon: const Icon(Icons.fingerprint, size: 28),
                label: const Text("Đăng nhập nhanh bằng vân tay"),
                style: TextButton.styleFrom(foregroundColor: Colors.purple),
              ),

              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text("Chưa có tài khoản? Đăng ký ngay"),
              )
            ],
          ),
        ),
      ),
    );
  }
}