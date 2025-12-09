import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart'; // Import để kiểm tra máy có hỗ trợ không

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _canCheckBiometrics = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkHardwareAndLoadSettings();
  }

  Future<void> _checkHardwareAndLoadSettings() async {
    // 1. Kiểm tra xem máy có hỗ trợ vân tay/faceID không
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics;
    } catch (e) {
      print(e);
    }

    // 2. Load cài đặt cũ từ bộ nhớ
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheck;
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt tài khoản"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Bảo mật",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),

          // --- NÚT BẬT TẮT VÂN TAY ---
          if (_canCheckBiometrics) // Chỉ hiện nếu máy có hỗ trợ
            SwitchListTile(
              title: const Text("Đăng nhập bằng sinh trắc học"),
              subtitle: const Text("Sử dụng Vân tay hoặc FaceID để đăng nhập nhanh"),
              secondary: const Icon(Icons.fingerprint, color: Colors.purple),
              value: _isBiometricEnabled,
              activeColor: Colors.blue,
              onChanged: (value) => _toggleBiometric(value),
            )
          else
            const ListTile(
              leading: Icon(Icons.error_outline, color: Colors.grey),
              title: Text("Thiết bị không hỗ trợ sinh trắc học"),
            ),

          const Divider(),
          
          // Bạn có thể thêm các cài đặt khác ở đây (Đổi mật khẩu, Xóa tài khoản...)
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Code chuyển sang trang đổi mật khẩu...
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
            },
          ),
        ],
      ),
    );
  }
}