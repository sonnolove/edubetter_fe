import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/screen/tabs/subjects_tab.dart';
import 'package:my_edu_app/screen/tabs/profile_tab.dart';
import 'package:my_edu_app/screen/tabs/quiz_select_tab.dart';
import 'package:my_edu_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true; // Thêm trạng thái đang tải để check quyền
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  // Hàm kiểm tra quyền Admin
  Future<void> _checkRole() async {
    final isAdmin = await _apiService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    }
    debugPrint('Kết quả kiểm tra Admin: $_isAdmin');

  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Màn hình chờ khi đang kiểm tra quyền
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Cấu hình Menu cho ADMIN
    if (_isAdmin) {
      // Vì AdminDashboard đã có Scaffold & AppBar riêng, 
      // ta cần xử lý một chút để tránh bị lặp 2 cái AppBar.
      // Cách đơn giản nhất: Nếu đang ở tab Dashboard, ta ẩn AppBar của HomeScreen đi.
      
      final List<Widget> adminPages = [
        const AdminDashboard(), // Tab 0: Dashboard quản lý
        const ProfileTab(),     // Tab 1: Thông tin cá nhân
      ];

      final List<BottomNavigationBarItem> adminNavItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Quản trị',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ];

      return Scaffold(
        // Chỉ hiện AppBar của HomeScreen khi KHÔNG PHẢI là tab Dashboard
        // (Vì AdminDashboard đã có AppBar riêng của nó rồi)
        appBar: _selectedIndex == 0 
            ? null 
            : AppBar(title: const Text("Cá nhân"), centerTitle: true, elevation: 0),
        
        body: adminPages[_selectedIndex],
        
        bottomNavigationBar: BottomNavigationBar(
          items: adminNavItems,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange, // Màu cam cho Admin để dễ phân biệt
          onTap: _onItemTapped,
        ),
      );
    }

    // 3. Cấu hình Menu cho STUDENT (Học viên) - Giữ nguyên như cũ
    final List<String> studentTitles = [
      'Khóa học nổi bật',
      'Tạo Quiz AI',
      'Hỏi đáp',
      'Cá nhân'
    ];

    final List<Widget> studentPages = [
      const SubjectsTab(),
      const QuizSelectTab(),
      const Center(child: Text("Tính năng Hỏi đáp đang phát triển...")),
      const ProfileTab(),
    ];

    final List<BottomNavigationBarItem> studentNavItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Khóa học'),
      BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Tạo Quiz'),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Hỏi đáp'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(studentTitles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
      ),
      body: studentPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: studentNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}