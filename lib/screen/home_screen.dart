import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/screen/student_home_screen.dart'; // Màn hình mới của Student
import 'package:my_edu_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkRoleAndRedirect();
  }

  Future<void> _checkRoleAndRedirect() async {
    // 1. Kiểm tra quyền Admin từ API
    final isAdmin = await _apiService.isAdmin();
    
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // --- ĐIỀU HƯỚNG THEO ROLE ---
    
    if (_isAdmin) {
      // Nếu là Admin -> Vào thẳng Dashboard quản trị
      // (Không hiện tab khóa học, quiz...)
      return const AdminDashboard();
    } else {
      // Nếu là Student -> Vào màn hình học tập
      return const StudentHomeScreen();
    }
  }
}