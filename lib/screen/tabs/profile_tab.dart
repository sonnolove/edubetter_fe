import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/services/api_service.dart';
// [QUAN TRỌNG] Import file màn hình cài đặt mới
import 'package:my_edu_app/screen/settings/account_settings_screen.dart'; 

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isAdmin = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  void _checkAdminRole() async {
    final isAdmin = await _apiService.isAdmin();
    if (mounted) {
      setState(() => _isAdmin = isAdmin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. PHẦN HEADER PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade50,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 60, color: Colors.blueAccent)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "Người dùng Demo",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "Chưa cập nhật email",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Badge hiển thị chức vụ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isAdmin ? Colors.orange.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isAdmin ? "QUẢN TRỊ VIÊN" : "HỌC VIÊN",
                      style: TextStyle(
                        color: _isAdmin ? Colors.orange.shade800 : Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. PHẦN MENU ĐIỀU HƯỚNG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ExpansionTile(
                      initiallyExpanded: true,
                      leading: const Icon(Icons.menu, color: Colors.blueAccent),
                      title: const Text(
                        "Menu Chức Năng",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: const Text("Bấm để mở rộng/thu gọn"),
                      children: [
                        
                        // Chức năng Admin
                        if (_isAdmin)
                          _buildMenuItem(
                            icon: Icons.dashboard_customize,
                            title: "Trang Quản Trị (Admin)",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminDashboard()),
                              );
                            },
                          ),

                        // --- [SỬA ĐỔI] NÚT CÀI ĐẶT TÀI KHOẢN ---
                        _buildMenuItem(
                          icon: Icons.settings,
                          title: "Cài đặt tài khoản",
                          onTap: () {
                            // Chuyển sang màn hình cài đặt mới
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                            );
                          },
                        ),
                        // ---------------------------------------



                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text(
              "Phiên bản 1.0.0",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}