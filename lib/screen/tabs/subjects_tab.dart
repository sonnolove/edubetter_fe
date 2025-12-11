import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Đảm bảo đường dẫn import đúng với dự án của bạn
import 'package:my_edu_app/global_key.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/screen/subject_detail_screen.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/login_screen.dart';
import 'package:my_edu_app/screen/register_screen.dart';
import 'package:my_edu_app/screen/chat/chat_history_screen.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _subjectsFuture;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // 1. Gọi API ngay lập tức khi mở màn hình (QUAN TRỌNG)
    _subjectsFuture = _apiService.getSubjects();

    // 2. Lắng nghe thay đổi đăng nhập để refresh lại nếu cần
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        // Gọi setState để build lại giao diện với trạng thái user mới
        // Đồng thời tải lại dữ liệu để cập nhật tiến độ học tập (nếu có)
        _handleRefresh();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _subjectsFuture = _apiService.getSubjects();
    });
  }

  String _getSliderImage(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('địa')) return 'assets/image/SLI_geo.png';
    if (name.contains('sử')) return 'assets/image/SLI_his.png';
    if (name.contains('pháp') || name.contains('gdcd')) return 'assets/image/SLI_eco.png';
    return 'assets/image/kt.jpg';
  }

  String _getGridImage(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('địa')) return 'assets/image/dia.png';
    if (name.contains('sử')) return 'assets/image/su.png';
    if (name.contains('pháp') || name.contains('gdcd')) return 'assets/image/gdcd.png';
    return 'assets/image/kt.jpg';
  }

  void _onSubjectTap(BuildContext context, Subject subject) async {
    final user = FirebaseAuth.instance.currentUser;
    // Logic: Khách vẫn xem được chi tiết, nhưng có thể bị giới hạn tính năng bên trong
    // Nếu bạn muốn bắt buộc đăng nhập mới được xem thì giữ nguyên logic cũ
    // Ở đây tôi cho phép xem chi tiết môn, nhưng nếu chưa login thì SubjectDetailScreen sẽ xử lý tiếp
    
    // Nếu muốn bắt buộc login ngay tại đây:
    if (user == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.lock_person_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text("Đăng nhập")
          ]),
          content: const Text("Bạn cần đăng nhập để truy cập bài học và làm bài tập."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Để sau", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Đăng nhập ngay"),
            ),
          ],
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject)),
      );
      if (mounted) _handleRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy user trực tiếp từ FirebaseAuth để UI cập nhật tức thì
    final user = FirebaseAuth.instance.currentUser;
    final double topPadding = MediaQuery.of(context).padding.top;
    const double headerHeight = 240;
    const double contentMarginTop = 210;

    return Scaffold(
      extendBodyBehindAppBar: true,
      
      floatingActionButton: user != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 20, right: 10),
              width: 100,
              height: 100,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen())),
                child: Transform.scale(
                  scale: 1.7,
                  child: Lottie.asset('assets/animations/robot.json', fit: BoxFit.contain, width: 160),
                ),
              ),
            )
          : null,

      body: Stack(
        children: [
          // LỚP 1: HEADER BACKGROUND
          Positioned(
            top: 0, left: 0, right: 0, height: headerHeight,
            child: Container(
              color: Colors.blueAccent,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Lottie.asset('assets/animations/header_bg.json', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.blueAccent)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LỚP 2: NỘI DUNG CHÍNH (Nằm dưới nút bấm nhưng trên header)
          Positioned.fill(
            top: contentMarginTop,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: Colors.blueAccent,
                  child: FutureBuilder<List<dynamic>>(
                    future: _subjectsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                      } 
                      
                      // Xử lý lỗi hoặc dữ liệu trống
                      if (snapshot.hasError) {
                        return Center(child: Text('Lỗi tải dữ liệu. Vui lòng thử lại.\n${snapshot.error}', textAlign: TextAlign.center));
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Chưa có môn học nào.'),
                              const SizedBox(height: 10),
                              ElevatedButton(onPressed: _handleRefresh, child: const Text("Tải lại"))
                            ],
                          ),
                        );
                      }

                      final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          // --- A. SLIDER ---
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Text("Tiến độ học tập", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: CarouselSlider(
                              options: CarouselOptions(height: 180.0, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.85),
                              items: subjects.map((subject) {
                                double percent = (subject.totalLessons == 0) ? 0 : (subject.completedLessons / subject.totalLessons);
                                String imagePath = _getSliderImage(subject.name);

                                return GestureDetector(
                                  onTap: () => _onSubjectTap(context, subject),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken)),
                                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(subject.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 8),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(value: percent, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent), minHeight: 6),
                                              ),
                                              const SizedBox(height: 6),
                                              Text("Đã hoàn thành ${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                        if (user == null)
                                          Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(50)), child: const Icon(Icons.lock_rounded, color: Colors.white, size: 18))),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // --- B. GRID VIEW 3 CỘT ---
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(24, 30, 24, 15),
                              child: Row(
                                children: [
                                  Icon(Icons.explore_rounded, color: Colors.blueAccent),
                                  SizedBox(width: 8),
                                  Text("Khám phá môn học", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                                ],
                              ),
                            ),
                          ),
                          
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, 
                                childAspectRatio: 1, 
                                crossAxisSpacing: 12, 
                                mainAxisSpacing: 12
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final subject = subjects[index];
                                  String imagePath = _getGridImage(subject.name);
                                  
                                  return SubjectCard(
                                    subject: subject,
                                    imagePath: imagePath,
                                    isLocked: user == null,
                                    onTap: () => _onSubjectTap(context, subject),
                                  );
                                },
                                childCount: subjects.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // LỚP 3: NÚT MENU & LOGIN (ĐẶT Ở CUỐI CÙNG ĐỂ NỔI LÊN TRÊN)
          Positioned(
            top: topPadding + 5, left: 10, right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 32),
                  onPressed: () {
                    // Dùng Key của cha để mở Drawer
                    // Cần đảm bảo StudentHomeScreen có key: homeScaffoldKey
                    try {
                      homeScaffoldKey.currentState?.openDrawer();
                    } catch (e) {
                      print("Lỗi mở drawer: $e");
                    }
                  },
                ),
                if (user == null)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text("Đăng nhập", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text("Đăng ký", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET CARD ---
class SubjectCard extends StatefulWidget {
  final Subject subject;
  final String imagePath;
  final bool isLocked;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.imagePath,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double scale = _isHovering ? 1.05 : _scaleAnimation.value;
            
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovering 
                          ? Colors.blueAccent.withOpacity(0.25)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: _isHovering ? 12 : 8,
                      offset: _isHovering ? const Offset(0, 6) : const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Ảnh
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(widget.imagePath, fit: BoxFit.cover),
                                Container(color: Colors.black.withOpacity(0.05)),
                              ],
                            ),
                          ),
                          // 2. Thông tin
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.subject.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12, 
                                    color: Colors.black87
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${widget.subject.totalLessons} bài",
                                    style: TextStyle(
                                      fontSize: 10, 
                                      color: Colors.blue.shade700, 
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      if (widget.isLocked)
                        Positioned(
                          top: 5, right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.lock, color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}