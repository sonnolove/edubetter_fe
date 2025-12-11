import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/login_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isBiometricEnabled = false;
  bool _canCheckBiometrics = false;
  final LocalAuthentication auth = LocalAuthentication();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkHardwareAndLoadSettings();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  // 1. Kiểm tra phần cứng và lấy trạng thái đã lưu
  Future<void> _checkHardwareAndLoadSettings() async {
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics;
    } catch (e) {
      print("Lỗi kiểm tra phần cứng: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheck;
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  // --- LOGIC MỚI: BẬT VÂN TAY CÓ XÁC THỰC ---
  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      // TRƯỜNG HỢP 1: MUỐN BẬT (ON)
      // Phải quét vân tay xác nhận chính chủ trước khi cho phép bật
      try {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Vui lòng quét vân tay để kích hoạt tính năng này',
          options: const AuthenticationOptions(
            stickyAuth: true, 
            biometricOnly: true
          ),
        );

        if (didAuthenticate) {
          // Nếu quét đúng -> Lưu trạng thái BẬT
          await prefs.setBool('biometric_enabled', true);
          setState(() => _isBiometricEnabled = true);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã kích hoạt đăng nhập bằng vân tay! ✅")),
            );
          }
        } else {
          // Nếu quét sai hoặc bấm hủy -> Giữ nguyên trạng thái TẮT (Switch tự bật lại false)
          setState(() => _isBiometricEnabled = false);
        }
      } catch (e) {
        // Lỗi phần cứng hoặc chưa cài vân tay trong máy
        setState(() => _isBiometricEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi: Hãy cài đặt vân tay trong máy điện thoại trước!")),
          );
        }
      }
    } else {
      // TRƯỜNG HỢP 2: MUỐN TẮT (OFF) -> Tắt luôn không cần hỏi
      await prefs.setBool('biometric_enabled', false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  // ... (Giữ nguyên các hàm _pickAndConvertImage và _showEditProfileDialog như cũ) ...
  Future<String?> _pickAndConvertImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 500);
      if (image == null) return null;
      final bytes = await File(image.path).readAsBytes();
      return "data:image/jpeg;base64,${base64Encode(bytes)}"; 
    } catch (e) { return null; }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _currentUser?.displayName ?? '');
    final emailController = TextEditingController(text: _currentUser?.email ?? '');
    ValueNotifier<String?> selectedImageNotifier = ValueNotifier<String?>(_currentUser?.photoURL);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Chỉnh sửa hồ sơ"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Stack(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: selectedImageNotifier,
                      builder: (context, imageUrl, child) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                          child: (imageUrl == null || imageUrl.isEmpty) ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: InkWell(
                        onTap: () async {
                          String? newBase64 = await _pickAndConvertImage();
                          if (newBase64 != null) selectedImageNotifier.value = newBase64;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Họ và tên", prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 10),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.updateMyProfile(fullName: nameController.text, email: emailController.text, avatarUrl: selectedImageNotifier.value);
                Navigator.pop(ctx);
                _loadCurrentUser();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
              }
            },
            child: const Text("Lưu thay đổi"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final passController = TextEditingController();
    final confirmPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu mới", prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 10),
            TextField(controller: confirmPassController, obscureText: true, decoration: const InputDecoration(labelText: "Nhập lại mật khẩu", prefixIcon: Icon(Icons.lock_outline))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (passController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu không khớp!")));
                return;
              }
              if (passController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu phải trên 6 ký tự!")));
                return;
              }
              try {
                await _apiService.changeMyPassword(passController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
              }
            },
            child: const Text("Đổi mật khẩu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt tài khoản"), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: (_currentUser?.photoURL != null && _currentUser!.photoURL!.isNotEmpty) ? NetworkImage(_currentUser!.photoURL!) : null,
                  child: (_currentUser?.photoURL == null || _currentUser!.photoURL!.isEmpty) ? const Icon(Icons.person, size: 50, color: Colors.blue) : null,
                ),
                const SizedBox(height: 10),
                Text(_currentUser?.displayName ?? "Chưa đặt tên", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_currentUser?.email ?? "", style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _showEditProfileDialog, icon: const Icon(Icons.edit_note), label: const Text("Chỉnh sửa thông tin")),
              ],
            ),
          ),
          const SizedBox(height: 30), const Divider(),
          const Text("Bảo mật", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          
          if (_canCheckBiometrics)
            SwitchListTile(
              title: const Text("Đăng nhập bằng sinh trắc học"),
              subtitle: const Text("Sử dụng Vân tay hoặc FaceID để đăng nhập lần sau"),
              secondary: const Icon(Icons.fingerprint, color: Colors.purple),
              value: _isBiometricEnabled,
              activeColor: Colors.blue,
              // GỌI HÀM TOGGLE MỚI TẠI ĐÂY
              onChanged: _toggleBiometric, 
            ),

          ListTile(leading: const Icon(Icons.lock_reset, color: Colors.redAccent), title: const Text("Đổi mật khẩu"), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: _showChangePasswordDialog),
          const Divider(),
          
          // NÚT ĐĂNG XUẤT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text("Đăng xuất"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                // Quay về màn hình Login và xóa hết lịch sử cũ để tránh lỗi back lại
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false
                );
              }
            },
          ),
        ],
      ),
    );
  }
}