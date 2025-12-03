import 'package:flutter/material.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/services/auth_service.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Đăng ký với Firebase Auth
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Lưu tên người dùng vào Backend (Firestore)
      await _apiService.createProfile(
        _nameController.text.trim(),
        null, // avatarUrl để null hoặc thêm logic upload ảnh sau
      );

      if (!mounted) return;
      
      // 3. Thành công -> Quay lại màn hình Login hoặc để AuthGate tự chuyển
      // Vì đăng ký xong Firebase tự đăng nhập luôn, nên chỉ cần pop về là AuthGate sẽ lo
      Navigator.of(context).pop(); 
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1, size: 60, color: Colors.blue),
              const SizedBox(height: 24),
              
              // Tên đầy đủ
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) => 
                    !value!.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 16),

              // Mật khẩu
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => 
                    value!.length < 6 ? 'Mật khẩu phải trên 6 ký tự' : null,
              ),
              const SizedBox(height: 16),

              // Nhập lại mật khẩu
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng Ký', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}