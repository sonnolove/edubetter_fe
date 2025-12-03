import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/admin/admin_dashboard.dart';
import 'package:my_edu_app/screen/tabs/Subjects_tab.dart';
import 'package:my_edu_app/screen/tabs/quiz_select_tab.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/widgets/profile_dialog.dart'; // <--- Import file mới

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isAdmin = await _apiService.isAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showProfilePopup() {
    showDialog(
      context: context,
      builder: (context) => const ProfileDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userInitial = (user?.displayName?.isNotEmpty == true) 
        ? user!.displayName![0].toUpperCase() 
        : "U";

    // --- DANH SÁCH MÀN HÌNH ---
    // (Bây giờ Admin hay Student đều dùng chung cấu trúc tab này, 
    // Admin chỉ khác là có thêm nút Dashboard trong Pop-up)
    final List<Widget> pages = [
      const SubjectsTab(),
      const QuizSelectTab(),
      const Center(child: Text("Hỏi đáp AI (Coming soon)")),
    ];

    final List<String> titles = [
      'Khóa học',
      'Tạo Quiz AI',
      'Hỏi đáp'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Nút Avatar mở Pop-up
          InkWell(
            onTap: _showProfilePopup, // <--- Bấm vào đây hiện Dialog
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: _isAdmin ? Colors.orange : Colors.blueAccent,
                radius: 18,
                child: Text(
                  userInitial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      
      body: pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Khóa học'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Tạo Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Hỏi đáp'),
          // Đã xóa Tab Cá nhân
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        onTap: _onItemTapped,
      ),
    );
  }
}