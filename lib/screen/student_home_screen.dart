import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/auth_gate.dart';
import 'package:my_edu_app/screen/chat/chat_history_screen.dart'; // Màn hình chat
import 'package:my_edu_app/screen/quiz/quiz_history_screen.dart'; // <--- Import màn hình Lịch sử Quiz
import 'package:my_edu_app/screen/tabs/subjects_tab.dart';
import 'package:my_edu_app/screen/tabs/profile_tab.dart'; 
import 'package:my_edu_app/screen/tabs/quiz_select_tab.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0; 

  // Danh sách các màn hình chức năng cho học viên
  final List<Widget> _pages = [
    const SubjectsTab(),        // Index 0
    const QuizSelectTab(),     // Index 1
    const ChatHistoryScreen(), // Index 2
    const QuizHistoryScreen(), // Index 3: <--- Màn hình Lịch sử Quiz mới
    const ProfileTab(),        // Index 4
  ];

  final List<String> _titles = [
    'Khóa học nổi bật',
    'Tạo Quiz AI',
    'Hỏi đáp thông minh',
    'Lịch sử làm bài', // Tiêu đề tương ứng
    'Hồ sơ cá nhân'
  ];

  void _onSelectItem(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Đóng Drawer sau khi chọn
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userInitial = (user?.displayName?.isNotEmpty == true) 
        ? user!.displayName![0].toUpperCase() 
        : "U";
    final String displayName = user?.displayName ?? "Học viên";
    final String email = user?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      
      // --- DRAWER NAVIGATION ---
      drawer: Drawer(
        child: Column(
          children: [
            // Header
            UserAccountsDrawerHeader(
              accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(userInitial, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                image: DecorationImage(
                  image: NetworkImage("https://placehold.co/600x200/000000/FFFFFF.png?text=STUDENT"),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
            ),

            // Body: Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(icon: Icons.school, text: 'Khóa học', index: 0),
                  _buildDrawerItem(icon: Icons.auto_awesome, text: 'Tạo Quiz AI', index: 1),
                  _buildDrawerItem(icon: Icons.chat_bubble, text: 'Hỏi đáp', index: 2),
                  
                  // --- MỤC MỚI THÊM VÀO ---
                  _buildDrawerItem(icon: Icons.history_edu, text: 'Lịch sử Quiz', index: 3),
                  // ------------------------

                  const Divider(),
                  _buildDrawerItem(icon: Icons.person, text: 'Hồ sơ cá nhân', index: 4),
                ],
              ),
            ),

            // Footer
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.power_settings_new, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required int index}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey[700]),
      title: Text(text, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      onTap: () => _onSelectItem(index),
    );
  }
}