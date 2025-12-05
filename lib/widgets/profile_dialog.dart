import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/screen/quiz/quiz_history_screen.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/auth_gate.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  bool _isAdmin = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  void _checkAdminRole() async {
    final isAdmin = await _apiService.isAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao vừa đủ nội dung
          children: [
            // 1. AVATAR & INFO
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    user?.displayName?.isNotEmpty == true
                        ? user!.displayName![0].toUpperCase()
                        : "U",
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                if (_isAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? "Người dùng",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // 2. MENU CHỨC NĂNG
            if (_isAdmin)
              _buildPopupItem(
                icon: Icons.dashboard,
                text: "Trang Quản trị",
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context); // Đóng popup trước khi chuyển trang
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
                },
              ),

            _buildPopupItem(
              icon: Icons.history_edu,
              text: "Lịch sử Quiz",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHistoryScreen()));
              },
            ),

            _buildPopupItem(
              icon: Icons.bar_chart,
              text: "Tiến độ học tập",
              onTap: () {
                // Placeholder
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang phát triển...")));
              },
            ),

            const Divider(),

            // 3. ĐĂNG XUẤT
            _buildPopupItem(
              icon: Icons.logout,
              text: "Đăng xuất",
              color: Colors.red,
              onTap: () async {
                // 1. Đăng xuất khỏi Firebase
                await FirebaseAuth.instance.signOut();
                
                if (context.mounted) {
                  // 2. Đóng Dialog
                  Navigator.pop(context); 
                  
                  // 3. Xóa sạch lịch sử điều hướng và về trang gốc (AuthGate sẽ lo phần còn lại)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false, // Xóa hết các màn hình trước đó
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