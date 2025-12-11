import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_edu_app/screen/student_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // 1. Cấu hình Animation Controller để điều khiển Lottie
    _controller = AnimationController(vsync: this);

    // 2. Bắt đầu quy trình kiểm tra
    _checkLoginAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Bắt đầu chạy Animation
    // Chúng ta không await ở đây để code bên dưới chạy song song
    
    // --- GIAI ĐOẠN 1: Tải tài nguyên & Kiểm tra User (Chạy ngầm) ---
    // Giả sử ta muốn Logo hiện ít nhất 2 giây cho đẹp, không bị nháy
    // Và tối đa là theo thời gian thực của việc load dữ liệu
    
    final minDisplayTime = Future.delayed(const Duration(seconds: 2)); // Chờ ít nhất 2s
    
    // Kiểm tra trạng thái User hiện tại từ Firebase (đã lưu trong máy)
    // Firebase tự động lưu cache, nên lệnh này rất nhanh
    final user = FirebaseAuth.instance.currentUser;
    
    // Nếu bạn cần load thêm dữ liệu nặng (ví dụ config từ server), hãy gọi ở đây
    // await _loadSettings(); 

    // --- GIAI ĐOẠN 2: Đợi cho đến khi thời gian tối thiểu kết thúc ---
    await minDisplayTime;

    // --- GIAI ĐOẠN 3: Chuyển hướng ---
    if (!mounted) return;

    // Dù có user hay không, ta đều vào StudentHomeScreen
    // Bên màn hình đó đã có logic check user để hiện thị giao diện rồi
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Lottie
            Lottie.asset(
              'assets/animations/loading.json',
              controller: _controller,
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                // Cài đặt thời gian chạy của Animation bằng đúng độ dài file json
                _controller.duration = composition.duration;
                _controller.forward(); // Bắt đầu chạy
              },
            ),
            
            // Text App (Optional)
            const SizedBox(height: 20),
            const Text(
              "EDU BETTER",
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Colors.blue
              ),
            ),
          ],
        ),
      ),
    );
  }
}