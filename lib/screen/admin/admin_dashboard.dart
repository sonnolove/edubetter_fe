import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/manage_subjects_screen.dart';
import 'package:my_edu_app/screen/admin/manage_users_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang Quản Trị"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            title: "Quản lý Môn học & Bài giảng",
            icon: Icons.library_books,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageSubjectsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: "Quản lý Người dùng",
            icon: Icons.people_alt,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
            ),
          ),
          // Có thể thêm Thống kê, Báo cáo...
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}