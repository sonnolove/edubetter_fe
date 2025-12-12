import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; 
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/services/auth_service.dart';
import 'package:my_edu_app/utils/toast_helper.dart'; // Import tiện ích thông báo

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      // Thông báo khi form chưa hợp lệ
      ToastHelper.showWarning(context, "Vui lòng kiểm tra lại thông tin nhập.");
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      // 1. Đăng ký Firebase Auth
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Lưu tên vào Backend
      await _apiService.createProfile(
        _nameController.text.trim(),
        null, 
      );

      if (!mounted) return;
      
      // 3. Thông báo thành công & Quay về
      ToastHelper.showSuccess(context, "Đăng ký thành công! Đang đăng nhập...");
      
      // Đợi 1 chút cho người dùng đọc thông báo rồi mới chuyển trang
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.of(context).pop(); 
      
    } catch (e) {
      if (mounted) {
        // Xử lý lỗi đẹp hơn (AuthService đã trả về tiếng Việt)
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ToastHelper.showError(context, errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Nền xám
      appBar: AppBar(
        title: const Text("Tạo tài khoản mới"),
        backgroundColor: Colors.transparent, // Trong suốt
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black, // Chữ màu đen
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            
            // --- KHỐI CHỮ NHẬT NỔI ---
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
                  // --- LỚP 1: BACKGROUND JSON ---
                  Positioned.fill(
                    child: Transform.translate(
                      // Chỉnh độ tụt xuống y hệt màn hình Login
                      offset: const Offset(0, 210), 
                      
                      child: Transform(
                        alignment: Alignment.center,
                        // Kéo dãn chiều ngang để lấp đầy 2 bên sườn
                        transform: Matrix4.diagonal3Values(1.5, 2.2, 1.0), 
                        child: Lottie.asset(
                          'assets/animations/login_bg.json', // Dùng chung file nền Login
                          fit: BoxFit.contain, 
                        ),
                      ),
                    ),
                  ),

                  // --- LỚP 2: LỚP PHỦ MỜ (Overlay) ---
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.85), // Trắng mờ để chữ rõ
                    ),
                  ),

                  // --- LỚP 3: FORM ĐĂNG KÝ ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.person_add_alt_1, size: 60, color: Colors.blueAccent),
                          const SizedBox(height: 10),
                          const Text(
                            "ĐĂNG KÝ",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          const SizedBox(height: 24),
                          
                          // Tên đầy đủ
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Họ và tên',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) => !value!.contains('@') ? 'Email không hợp lệ' : null,
                          ),
                          const SizedBox(height: 16),

                          // Mật khẩu
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) => value!.length < 6 ? 'Mật khẩu phải trên 6 ký tự' : null,
                          ),
                          const SizedBox(height: 16),

                          // Nhập lại mật khẩu
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Xác nhận mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) return 'Mật khẩu không khớp';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Nút Đăng ký
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('ĐĂNG KÝ NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Đã có tài khoản?"),
                              TextButton(
                                onPressed: () => Navigator.pop(context), // Quay về login
                                child: const Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
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