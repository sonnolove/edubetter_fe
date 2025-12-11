import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/auth_gate.dart';
import 'package:my_edu_app/screen/chat/chat_history_screen.dart';
import 'package:my_edu_app/screen/quiz/quiz_history_screen.dart';
import 'package:my_edu_app/screen/tabs/subjects_tab.dart';
import 'package:my_edu_app/screen/tabs/profile_tab.dart'; 
import 'package:my_edu_app/screen/tabs/quiz_select_tab.dart';
import 'package:my_edu_app/screen/login_screen.dart';
import 'package:my_edu_app/global_key.dart'; // Import Global Key

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0; 
  User? _currentUser; // Biến để lưu trạng thái user hiện tại

  // Danh sách các màn hình chức năng
  final List<Widget> _pages = [
    const SubjectsTab(),        // Index 0: Khách được xem
    const QuizSelectTab(),     // Index 1: Cần login
    const ChatHistoryScreen(), // Index 2: Cần login
    const QuizHistoryScreen(), // Index 3: Cần login
    const ProfileTab(),        // Index 4: Cần login
  ];

  final List<String> _titles = [
    'Khóa học nổi bật',
    'Tạo Quiz AI',
    'Hỏi đáp thông minh',
    'Lịch sử làm bài', 
    'Hồ sơ cá nhân'
  ];

  @override
  void initState() {
    super.initState();
    // Lấy thông tin user ngay khi mở màn hình
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // --- HÀM 1: Hiển thị yêu cầu đăng nhập ---
  void _showLoginRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yêu cầu đăng nhập"),
        content: const Text("Bạn cần đăng nhập để sử dụng tính năng nâng cao này."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Để sau"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              // Chuyển sang màn hình đăng nhập
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen())
              );
            },
            child: const Text("Đăng nhập ngay"),
          ),
        ],
      ),
    );
  }

  // --- HÀM 2: Xử lý chọn menu ---
  void _onSelectItem(int index) {
    // Nếu chọn tab khác trang chủ (index 0) VÀ chưa đăng nhập => Chặn lại
    if (index != 0 && _currentUser == null) {
      Navigator.pop(context); // Đóng drawer trước
      _showLoginRequest(context); // Hiện thông báo
      return; 
    }

    // Nếu đã đăng nhập hoặc chọn trang chủ => Cho phép chuyển
    setState(() => _selectedIndex = index);
    Navigator.pop(context); 
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()), // Hoặc về SplashScreen
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái login để hiển thị giao diện phù hợp
    final bool isLogin = _currentUser != null;
    
    // Setup hiển thị Header
    final String displayName = isLogin ? (_currentUser!.displayName ?? "Học viên") : "Khách tham quan";
    final String email = isLogin ? (_currentUser!.email ?? "") : "Chưa đăng nhập";
    final String userInitial = (isLogin && _currentUser!.displayName?.isNotEmpty == true) 
        ? _currentUser!.displayName![0].toUpperCase() 
        : "G"; // G for Guest

    return Scaffold(
      key: homeScaffoldKey, // <--- QUAN TRỌNG: Gắn Key vào đây để mở Drawer từ trang con
      
      appBar: _selectedIndex == 0 
          ? null // Trang chủ (SubjectsTab) tự vẽ Header nên ẩn AppBar này đi
          : AppBar(
              title: Text(_titles[_selectedIndex]),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
      
      drawer: Drawer(
        child: Column(
          children: [
            // --- HEADER: Thay đổi theo trạng thái Login ---
            UserAccountsDrawerHeader(
              accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: isLogin 
                  ? Text(userInitial, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue))
                  : const Icon(Icons.person_outline, size: 40, color: Colors.grey),
              ),
              decoration: BoxDecoration(
                color: isLogin ? Colors.blueAccent : Colors.grey, // Khách thì màu xám
                image: const DecorationImage(
                  image: NetworkImage("https://placehold.co/600x200/000000/FFFFFF.png?text=STUDENT"),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              )
            ),

            // --- BODY: Menu Items ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(icon: Icons.school, text: 'Khóa học', index: 0), // Ai cũng xem được
                  _buildDrawerItem(icon: Icons.auto_awesome, text: 'Tạo Quiz AI', index: 1), // Cần login
                  _buildDrawerItem(icon: Icons.chat_bubble, text: 'Hỏi đáp', index: 2), // Cần login
                  _buildDrawerItem(icon: Icons.history_edu, text: 'Lịch sử Quiz', index: 3), // Cần login
                  const Divider(),
                  _buildDrawerItem(icon: Icons.person, text: 'Hồ sơ cá nhân', index: 4), // Cần login
                ],
              ),
            ),

            // --- FOOTER: Đổi nút Logout thành Login nếu là khách ---
            const Divider(height: 1),
            isLogin 
            ? ListTile( // Nếu ĐÃ đăng nhập -> Hiện nút Đăng xuất
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _handleLogout,
              )
            : ListTile( // Nếu LÀ KHÁCH -> Hiện nút Đăng nhập
                leading: const Icon(Icons.login, color: Colors.green),
                title: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
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
    // Thêm icon khóa nếu item này cần login mà user chưa login
    final bool isLocked = (index != 0 && _currentUser == null);

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey[700]),
      title: Text(text, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isLocked ? const Icon(Icons.lock, size: 18, color: Colors.grey) : null, // Hiện ổ khóa
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      onTap: () => _onSelectItem(index),
    );
  }
}