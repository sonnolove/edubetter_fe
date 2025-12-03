import 'package:flutter/material.dart';
import 'package:my_edu_app/services/api_service.dart';

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

  void _changeRole(String uid, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'student' : 'admin';
    try {
      await _apiService.updateUserRole(uid, newRole);
      _refreshList();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã đổi quyền thành $newRole")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Người dùng")),
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
              final role = user['role'] ?? 'student';
              final isStudent = role == 'student';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isStudent ? Colors.green : Colors.red,
                  child: Icon(isStudent ? Icons.person : Icons.admin_panel_settings, color: Colors.white),
                ),
                title: Text(user['fullName'] ?? 'No Name'),
                subtitle: Text("${user['email']} • $role"),
                trailing: TextButton(
                  onPressed: () => _changeRole(user['uid'], role),
                  child: Text(isStudent ? "Thăng chức Admin" : "Hạ chức Student"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}