import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/home_screen.dart'; // Để quay về màn hình chính
import 'package:my_edu_app/screen/auth_gate.dart';

class AdminProfileDialog extends StatelessWidget {
  const AdminProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userInitial = (user?.displayName?.isNotEmpty == true) 
        ? user!.displayName![0].toUpperCase() 
        : "A"; // A cho Admin

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. HEADER ADMIN
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.orange.shade50,
                  child: Text(
                    userInitial,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? "Administrator",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "admin@system.com",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "QUẢN TRỊ VIÊN",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // 2. MENU CHỨC NĂNG
            
            // Nút chuyển về giao diện User (để Admin test thử app)
            _buildPopupItem(
              icon: Icons.school,
              text: "Vào App học tập (Xem thử)",
              color: Colors.blue,
              onTap: () {
                // Chuyển sang màn hình học tập nhưng vẫn giữ quyền Admin
                // (Cần chỉnh sửa HomeScreen để hỗ trợ việc này, 
                // tạm thời ta push sang màn hình StudentHomeScreen)
                Navigator.pop(context);
                // Lưu ý: Logic này phụ thuộc vào cách bạn tổ chức router
                // Ở đây ta đơn giản là đóng dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chức năng xem trước đang phát triển")),
                );
              },
            ),

            _buildPopupItem(
              icon: Icons.settings,
              text: "Cài đặt hệ thống",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cấu hình hệ thống...")),
                );
              },
            ),

            const Divider(),

            // 3. ĐĂNG XUẤT
            _buildPopupItem(
              icon: Icons.logout,
              text: "Đăng xuất",
              color: Colors.red,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                
                if (context.mounted) {
                  Navigator.pop(context); 
                  
                  // Chuyển về AuthGate để nó tự điều hướng về Login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}