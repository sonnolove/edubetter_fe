import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/services/api_service.dart';

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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            // ... (Phần hiển thị thông tin user giữ nguyên) ...
            Text(
              user?.email ?? "",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            // --- NÚT ADMIN (Chỉ hiện nếu là Admin) ---
            if (_isAdmin)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text("TRANG QUẢN TRỊ (ADMIN)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboard()),
                    );
                  },
                ),
              ),

            // Nút Đăng xuất
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}