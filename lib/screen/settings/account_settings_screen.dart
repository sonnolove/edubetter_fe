import 'dart:convert'; // Để chuyển ảnh sang Base64
import 'dart:io';      // Để xử lý file ảnh
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Import thư viện chọn ảnh
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_edu_app/services/api_service.dart';

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

  Future<void> _checkHardwareAndLoadSettings() async {
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics;
    } catch (e) {
      print(e);
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

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  // --- LOGIC CHỌN ẢNH TỪ THƯ VIỆN ---
  Future<String?> _pickAndConvertImage() async {
    try {
      // 1. Mở thư viện ảnh
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 50, // Giảm chất lượng xuống 50% để chuỗi Base64 không quá dài
        maxWidth: 500,    // Giới hạn chiều rộng ảnh
      );

      if (image == null) return null; // Người dùng hủy chọn

      // 2. Đọc file và chuyển sang Base64
      final bytes = await File(image.path).readAsBytes();
      String base64Image = base64Encode(bytes);
      
      // 3. Trả về chuỗi đúng định dạng để hiển thị được
      return "data:image/jpeg;base64,$base64Image"; 
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
      return null;
    }
  }

  // --- DIALOG CHỈNH SỬA THÔNG TIN (GIAO DIỆN MỚI) ---
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _currentUser?.displayName ?? '');
    final emailController = TextEditingController(text: _currentUser?.email ?? '');
    
    // Biến tạm để lưu ảnh vừa chọn (nhưng chưa lưu lên server)
    // Dùng ValueNotifier để cập nhật UI trong Dialog mà không cần setState toàn trang
    ValueNotifier<String?> selectedImageNotifier = ValueNotifier<String?>(_currentUser?.photoURL);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Chỉnh sửa hồ sơ"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- PHẦN CHỌN ẢNH ---
              Center(
                child: Stack(
                  children: [
                    // Hiển thị ảnh
                    ValueListenableBuilder<String?>(
                      valueListenable: selectedImageNotifier,
                      builder: (context, imageUrl, child) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                              ? NetworkImage(imageUrl) // NetworkImage cũng đọc được Base64 string
                              : null,
                          child: (imageUrl == null || imageUrl.isEmpty)
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        );
                      },
                    ),
                    // Nút Camera nhỏ để bấm chọn
                    Positioned(
                      bottom: 0, right: 0,
                      child: InkWell(
                        onTap: () async {
                          // Gọi hàm chọn ảnh
                          String? newBase64 = await _pickAndConvertImage();
                          if (newBase64 != null) {
                            selectedImageNotifier.value = newBase64; // Cập nhật preview
                          }
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

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Họ và tên", prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              try {
                // Gọi API cập nhật với ảnh Base64
                await _apiService.updateMyProfile(
                  fullName: nameController.text,
                  email: emailController.text,
                  avatarUrl: selectedImageNotifier.value, // Gửi chuỗi Base64 lên
                );
                
                Navigator.pop(ctx);
                _loadCurrentUser(); // Refresh UI bên ngoài
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

  // --- DIALOG ĐỔI MẬT KHẨU (GIỮ NGUYÊN) ---
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
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mật khẩu mới", prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nhập lại mật khẩu", prefixIcon: Icon(Icons.lock_outline)),
            ),
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
      appBar: AppBar(
        title: const Text("Cài đặt tài khoản"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  // Tự động nhận diện URL mạng hoặc Base64 string
                  backgroundImage: (_currentUser?.photoURL != null && _currentUser!.photoURL!.isNotEmpty)
                      ? NetworkImage(_currentUser!.photoURL!) 
                      : null,
                  child: (_currentUser?.photoURL == null || _currentUser!.photoURL!.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.blue)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _currentUser?.displayName ?? "Chưa đặt tên",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentUser?.email ?? "",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _showEditProfileDialog, // Gọi Dialog mới
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Chỉnh sửa thông tin"),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          const Divider(),

          const Text(
            "Bảo mật",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),

          if (_canCheckBiometrics)
            SwitchListTile(
              title: const Text("Đăng nhập bằng sinh trắc học"),
              subtitle: const Text("Sử dụng Vân tay hoặc FaceID"),
              secondary: const Icon(Icons.fingerprint, color: Colors.purple),
              value: _isBiometricEnabled,
              activeColor: Colors.blue,
              onChanged: (value) => _toggleBiometric(value),
            ),

          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.redAccent),
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showChangePasswordDialog,
          ),
          
          const Divider(),
          
         
        ],
      ),
    );
  }
}