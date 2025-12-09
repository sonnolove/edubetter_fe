import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:my_edu_app/global_key.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/screen/subject_detail_screen.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/login_screen.dart';
import 'package:my_edu_app/screen/register_screen.dart';
import 'package:my_edu_app/screen/chat/chat_screen.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _subjectsFuture = _apiService.getSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Lấy chiều cao tai thỏ (status bar) để tránh nút bị che
    final double paddingTop = MediaQuery.of(context).padding.top;
    
    // CẤU HÌNH KÍCH THƯỚC
    const double headerHeight = 240; // Chiều cao ảnh nền
    const double contentMarginTop = 210; // Vị trí bắt đầu của danh sách

    return Scaffold(
      // Ẩn AppBar mặc định đi để tự vẽ custom cho đẹp
      appBar: null, 
      extendBodyBehindAppBar: true,

      // --- NÚT ROBOT CHAT (TO & KHÔNG NỀN) ---
      floatingActionButton: user != null 
        ? Container(
            margin: const EdgeInsets.only(bottom: 20, right: 10),
            // [CHỈNH SIZE ROBOT TẠI ĐÂY]
            width: 100, // Tăng lên 100 hoặc 120 tùy thích
            height: 100, 
            child: FloatingActionButton(
              onPressed: () {
                final String newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(sessionId: newSessionId, title: "Trợ lý AI")
                  )
                );
              },
              // [QUAN TRỌNG] Làm trong suốt nền
              backgroundColor: Colors.transparent, 
              elevation: 0, // Bỏ bóng đổ
              splashColor: Colors.transparent, // Bỏ hiệu ứng loang màu khi bấm
              child: Lottie.asset(
                'assets/animations/robot.json', 
                fit: BoxFit.contain,
                width: 120, // Ép hình Lottie to ra
              ),
            ),
          )
        : null,

      body: Stack(
        children: [
          // --- LỚP 1: HÌNH NỀN LOTTIE ---
          Positioned(
            top: 0, left: 0, right: 0,
            height: headerHeight,
            child: Container(
              color: Colors.blueAccent,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Lottie.asset('assets/animations/header_bg.json', fit: BoxFit.cover),
                  // Gradient đen mờ phía trên để nút trắng dễ nhìn
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- LỚP 2: CÁC NÚT ĐIỀU KHIỂN (HEADER CUSTOM) ---
          // Dùng Positioned để đặt sát mép trên
          Positioned(
            top: paddingTop + 5, // Cách tai thỏ 5px
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. NÚT MENU (Góc Trái)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () => homeScaffoldKey.currentState?.openDrawer(),
                ),

                // 3. NÚT LOGIN/REGISTER (Góc Phải)
                if (user == null) 
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text("Đăng nhập", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          minimumSize: const Size(0, 30),
                        ),
                        child: const Text("Đăng ký", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                else 
                  // Nếu đã login thì để trống hoặc hiện Avatar nhỏ
                  const SizedBox(width: 40), 
              ],
            ),
          ),

          // --- LỚP 3: DANH SÁCH NỘI DUNG (Bo góc, đè lên hình) ---
          Positioned.fill(
            top: contentMarginTop, 
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                child: RefreshIndicator(
                  onRefresh: () async => _refreshList(),
                  child: FutureBuilder<List<dynamic>>(
                    future: _subjectsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Chưa có môn học nào.'));
                      }

                      final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), // Padding dưới to để ko bị robot che
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 20),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      subject.thumbnailUrl, 
                                      height: 150, width: double.infinity, fit: BoxFit.cover,
                                      errorBuilder: (_,__,___)=> Container(height: 150, color: Colors.grey[200]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text("${subject.completedLessons}/${subject.totalLessons} bài học", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}