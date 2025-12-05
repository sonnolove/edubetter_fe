import 'dart:convert'; // Để chuyển đổi Base64
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Cần thêm thư viện này

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _usersFuture = _apiService.getAllUsers();
    });
  }

  // --- LOGIC CHUYỂN ẢNH SANG BASE64 ---
  // Thay vì upload, ta nén ảnh và chuyển thành chuỗi ký tự
  Future<String?> _convertImageToBase64(XFile? imageFile) async {
    if (imageFile == null) return null;

    try {
      // 1. Đọc dữ liệu ảnh
      final bytes = await imageFile.readAsBytes();

      // 2. Nén ảnh (Quan trọng: Firestore chỉ cho phép document < 1MB)
      // Base64 làm tăng kích thước file lên khoảng 30%, nên cần nén kỹ.
      // Dùng thư viện flutter_image_compress hoặc nén đơn giản bằng cách resize.
      // Ở đây ta dùng cách đơn giản nhất là không nén sâu nhưng khuyến cáo ảnh input nhỏ.
      // Nếu ảnh quá lớn, hàm này có thể trả về chuỗi rất dài gây lỗi Firestore.
      
      // Chuyển sang Base64
      String base64String = base64Encode(bytes);
      
      // Thêm header để hiển thị được trong thẻ Image.memory hoặc Image.network (dạng data:image...)
      return "data:image/jpeg;base64,$base64String";
    } catch (e) {
      print("Lỗi chuyển đổi ảnh: $e");
      return null;
    }
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final isEditing = user != null;
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final nameController = TextEditingController(text: user?['fullName'] ?? '');
    final passwordController = TextEditingController();
    String role = user?['role'] ?? 'student';
    
    XFile? pickedImage;
    Uint8List? webImageBytes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          
          Future<void> pickImage() async {
            final ImagePicker picker = ImagePicker();
            // Cho phép chọn ảnh và giảm chất lượng ngay lúc chọn để nhẹ file
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 50, // Giảm chất lượng xuống 50%
              maxWidth: 400,    // Giới hạn chiều rộng 400px
            );
            
            if (image != null) {
              var f = await image.readAsBytes();
              setStateDialog(() {
                pickedImage = image;
                webImageBytes = f;
              });
            }
          }

          return AlertDialog(
            title: Text(isEditing ? "Sửa User" : "Tạo User Mới"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _getAvatarProvider(
                            webImageBytes, 
                            user?['avatarUrl']
                          ),
                          child: (webImageBytes == null && (user?['avatarUrl'] == null || user!['avatarUrl'] == ""))
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                    enabled: !isEditing, 
                  ),
                  if (!isEditing) 
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Mật khẩu", prefixIcon: Icon(Icons.lock)),
                      obscureText: true,
                    ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Họ tên", prefixIcon: Icon(Icons.badge)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: "Vai trò", prefixIcon: Icon(Icons.security)),
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text("Học viên (Student)")),
                      DropdownMenuItem(value: 'admin', child: Text("Quản trị (Admin)")),
                    ],
                    onChanged: (val) => setStateDialog(() => role = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    String finalAvatarUrl = user?['avatarUrl'] ?? "";

                    // Nếu có chọn ảnh mới -> Chuyển sang Base64
                    if (pickedImage != null) {
                      final base64Img = await _convertImageToBase64(pickedImage);
                      if (base64Img != null) finalAvatarUrl = base64Img;
                    }

                    final data = {
                      "email": emailController.text,
                      "fullName": nameController.text,
                      "role": role,
                      "avatarUrl": finalAvatarUrl, // Chuỗi Base64 rất dài sẽ được lưu vào đây
                    };

                    if (isEditing) {
                      await _apiService.updateUser(user!['uid'], data);
                    } else {
                      data["password"] = passwordController.text;
                      await _apiService.createUser(data);
                    }

                    if (context.mounted) {
                      Navigator.pop(context); // Tắt loading
                      Navigator.pop(ctx);     // Tắt form
                      _refreshList();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thành công!")));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                    }
                  }
                },
                child: const Text("Lưu"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Hàm helper để hiển thị ảnh (xử lý cả URL mạng và Base64)
  ImageProvider? _getAvatarProvider(Uint8List? newBytes, String? oldUrl) {
    if (newBytes != null) {
      return MemoryImage(newBytes);
    }
    if (oldUrl != null && oldUrl.isNotEmpty) {
      // Kiểm tra nếu là Base64 (bắt đầu bằng data:image)
      if (oldUrl.startsWith('data:image')) {
        try {
          // Tách phần header "data:image/jpeg;base64," ra để lấy phần code
          final base64Code = oldUrl.split(',').last;
          return MemoryImage(base64Decode(base64Code));
        } catch (e) {
          return null;
        }
      }
      // Nếu là URL thường (http...)
      return NetworkImage(oldUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Người dùng")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(), 
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isStudent = user['role'] == 'student';
              final avatarUrl = user['avatarUrl'] as String?;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isStudent ? Colors.green : Colors.orange,
                  backgroundImage: _getAvatarProvider(null, avatarUrl),
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(isStudent ? Icons.person : Icons.security, color: Colors.white)
                      : null,
                ),
                title: Text(user['fullName'] ?? 'No Name'),
                subtitle: Text("${user['email']} • ${user['role']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showUserDialog(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}