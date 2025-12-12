import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Giữ lại animation đẹp
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Cần để check User

import 'package:my_edu_app/screen/register_screen.dart';
import 'package:my_edu_app/services/auth_service.dart';
import 'package:my_edu_app/screen/student_home_screen.dart';
import 'package:my_edu_app/services/api_service.dart'; 
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/utils/toast_helper.dart'; // Dùng thông báo đẹp

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
    // Logic mới: Chỉ load email đã lưu, KHÔNG tự động quét vân tay để tránh loop khi logout
    _loadSavedEmail();
  }

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
      ToastHelper.showWarning(context, 'Vui lòng nhập đầy đủ Email và Mật khẩu');
      return;
    }
    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      
      // Lưu lại thông tin để dùng cho Vân tay lần sau
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim());

      if (mounted) {
        ToastHelper.showSuccess(context, "Đăng nhập thành công!");
        await _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        // Xử lý lỗi đẹp hơn
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ToastHelper.showError(context, errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 2: ĐĂNG NHẬP VÂN TAY (LOGIC MỚI) ---
  Future<void> _checkBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('biometric_enabled') ?? false;

    // 1. Kiểm tra đã bật chưa
    if (!isEnabled) {
      ToastHelper.showWarning(context, "Bạn chưa bật tính năng này trong Cài đặt.");
      return;
    }

    // 2. Kiểm tra có pass lưu chưa
    String? email = prefs.getString('saved_email');
    String? password = prefs.getString('saved_password');

    if (email == null || password == null) {
      ToastHelper.showWarning(context, "Vui lòng đăng nhập bằng mật khẩu lần đầu tiên.");
      return;
    }

    try {
      bool canCheck = await auth.canCheckBiometrics;
      if (canCheck) {
        // 3. Quét vân tay
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Xác thực vân tay để đăng nhập',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );

        if (didAuthenticate && mounted) {
           setState(() => _isLoading = true);
           
           // 4. Đăng nhập ngầm vào Firebase
           try {
             await _authService.signIn(email, password);
             ToastHelper.showSuccess(context, "Chào mừng trở lại, $email");
             await _navigateToHome();
           } catch (e) {
             ToastHelper.showError(context, "Thông tin lưu trữ đã cũ, vui lòng nhập lại mật khẩu.");
           } finally {
             if (mounted) setState(() => _isLoading = false);
           }
        }
      }
    } catch (e) {
      debugPrint("Lỗi xác thực: $e");
      ToastHelper.showError(context, "Thiết bị không hỗ trợ vân tay.");
    }
  }

  // --- HÀM ĐIỀU HƯỚNG ---
  Future<void> _navigateToHome() async {
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
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const StudentHomeScreen()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giữ nguyên giao diện đẹp của bạn
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            // KHỐI CHỮ NHẬT ĐỨNG
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // LỚP 1: BACKGROUND LOTTIE
                  Positioned.fill(
                    child: Transform.translate(
                      offset: const Offset(0, 150), 
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(1.5, 2.2, 10.0), 
                        child: Lottie.asset(
                          'assets/animations/login_bg.json',
                          fit: BoxFit.contain, 
                        ),
                      ),
                    ),
                  ),
                  
                  // LỚP 2: LỚP PHỦ MỜ
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),

                  // LỚP 3: NỘI DUNG FORM
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school, size: 70, color: Colors.blueAccent),
                        const SizedBox(height: 10),
                        const Text(
                          'EDU BETTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 30),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nút Đăng nhập
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Nút Vân tay & Đăng ký
                        TextButton.icon(
                          onPressed: _isLoading ? null : _checkBiometricLogin, // Gọi hàm vân tay mới
                          icon: const Icon(Icons.fingerprint, size: 28),
                          label: const Text("Đăng nhập nhanh", style: TextStyle(fontSize: 16)),
                          style: TextButton.styleFrom(foregroundColor: Colors.purple),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Chưa có tài khoản?"),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: const Text("Đăng ký ngay", style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}