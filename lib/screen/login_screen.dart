import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // [QUAN TRỌNG] Nhớ import lottie
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_edu_app/screen/register_screen.dart';
import 'package:my_edu_app/services/auth_service.dart';
import 'package:my_edu_app/screen/student_home_screen.dart';

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
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

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
        if (didAuthenticate && mounted) _navigateToHome();
      }
    } catch (e) {
      debugPrint("Lỗi sinh trắc học: $e");
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      if (mounted) _navigateToHome();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[200], // Nền ngoài màu xám để khối nổi bật
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            // --- TẠO KHỐI CHỮ NHẬT ĐỨNG ---
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400), // Giới hạn chiều rộng cho đẹp trên máy tính bảng
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Bo góc khối
              // --- TẠO BÓNG ĐỔ (SHADOW) ---
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Màu bóng
                  blurRadius: 15, // Độ nhòe của bóng
                  offset: const Offset(0, 10), // Bóng đổ xuống dưới
                ),
              ],
            ),
            // Dùng ClipRRect để cắt file Lottie theo góc bo tròn của Container
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // --- LỚP 1: BACKGROUND JSON ---
                  Positioned.fill(
                    child: Transform.translate(
                      // [CHỈNH ĐỘ TỤT XUỐNG TẠI ĐÂY]
                      // Tham số thứ 1 (0): Không dịch chuyển trái phải
                      // Tham số thứ 2 (50): Dịch xuống 50px (Muốn xuống sâu hơn thì tăng lên 80, 100...)
                      offset: const Offset(0, 150), 
                      
                      child: Transform(
                        alignment: Alignment.center,
                        // Code cũ để kéo dãn chiều ngang (giữ nguyên để không bị hở sườn)
                        transform: Matrix4.diagonal3Values(1.5, 2.2, 10.0), 
                        child: Lottie.asset(
                          'assets/animations/login_bg.json',
                          fit: BoxFit.contain, 
                        ),
                      ),
                    ),
                  ),
                  // --- LỚP 2: LỚP PHỦ MỜ (Overlay) ---
                  // Giúp chữ dễ đọc hơn trên nền động
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.85), // Màu trắng mờ 85%
                    ),
                  ),

                  // --- LỚP 3: NỘI DUNG FORM ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Co gọn theo nội dung
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
                            fillColor: Colors.white, // Nền ô nhập trắng rõ
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
                              elevation: 5, // Bóng của nút
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Nút Vân tay & Đăng ký
                        TextButton.icon(
                          onPressed: _checkBiometricLogin,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text("Đăng nhập nhanh"),
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