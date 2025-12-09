import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart'; 
import 'package:my_edu_app/global_key.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/screen/chat/chat_history_screen.dart';
import 'package:my_edu_app/screen/subject_detail_screen.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/login_screen.dart';
import 'package:my_edu_app/screen/register_screen.dart';

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

  String _getSliderImage(String subjectName) {
    final name = subjectName.toLowerCase();
    
    // Tùy chỉnh ảnh banner cho từng môn tại đây
    if (name.contains('địa')) return 'assets/image/SLI_geo.png';
    if (name.contains('sử')) return 'assets/image/SLI_his.png';
    if (name.contains('pháp')) return 'assets/image/SLI_eco.png';
    
    // ... Thêm các môn khác tương tự ...
    
    // Ảnh mặc định nếu chưa có banner riêng, dùng tạm ảnh icon cũ
    // Hoặc bạn có thể tạo 1 file 'assets/images/default_banner.png'
    return 'assets/image/kt.jpg'; 
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double paddingTop = MediaQuery.of(context).padding.top;
    
    const double headerHeight = 240; 
    const double contentMarginTop = 210; 

    return Scaffold(
      appBar: null, 
      extendBodyBehindAppBar: true,

      // --- NÚT ROBOT ---
      floatingActionButton: user != null 
        ? Container(
            margin: const EdgeInsets.only(bottom: 20, right: 10),
            width: 100, height: 100, 
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen()));
              },
              backgroundColor: Colors.transparent, 
              elevation: 0, splashColor: Colors.transparent, 
              child: Transform.scale(
                scale: 1.7, // Phóng to hình ảnh lên 1.2 lần (20%)
                child: Lottie.asset(
                  'assets/animations/robot.json', 
                  fit: BoxFit.contain, // Hoặc thử đổi thành BoxFit.cover nếu robot bị bé quá
                  width: 160, // Tăng width của asset lên tương ứng
                ),
              ),
            ),
          )
        : null,

      body: Stack(
        children: [
          // --- LỚP 1: HEADER BACKGROUND ---
          Positioned(
            top: 0, left: 0, right: 0, height: headerHeight,
            child: Container(
              color: Colors.blueAccent,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Lottie.asset('assets/animations/header_bg.json', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- LỚP 2: NÚT MENU & LOGIN ---
          Positioned(
            top: paddingTop + 5, left: 10, right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () => homeScaffoldKey.currentState?.openDrawer(),
                ),
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
                          backgroundColor: Colors.white, foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          minimumSize: const Size(0, 30),
                        ),
                        child: const Text("Đăng ký", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                else const SizedBox(width: 40), 
              ],
            ),
          ),

          // --- LỚP 3: NỘI DUNG CHÍNH ---
          Positioned.fill(
            top: contentMarginTop, 
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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

                      return CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),

                          // 1. TIÊU ĐỀ SLIDE
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text("Tiến độ học tập", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                          ),

                          // 2. SLIDER CAROUSEL (Dùng ảnh Local)
                          SliverToBoxAdapter(
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 160.0, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.85,
                              ),
                              items: subjects.map((subject) {
                                double percent = (subject.totalLessons == 0) ? 0 : (subject.completedLessons / subject.totalLessons);
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                        // THAY ĐỔI Ở ĐÂY: Dùng AssetImage thay vì NetworkImage
                                        image: DecorationImage(
                                          // Gọi hàm _getSliderImage thay vì subject.imageAsset
                                          image: AssetImage(_getSliderImage(subject.name)), 
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(subject.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 5),
                                            LinearProgressIndicator(value: percent, backgroundColor: Colors.white30, valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent)),
                                            const SizedBox(height: 5),
                                            Text("Hoàn thành ${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 12))
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // 3. TIÊU ĐỀ DANH SÁCH
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
                              child: Text("Khám phá môn học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                          ),

                          // 4. GRID VIEW (Dùng ảnh Local)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, childAspectRatio: 1.0, crossAxisSpacing: 15, mainAxisSpacing: 15,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final subject = subjects[index];
                                  return InkWell(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject))),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                              // THAY ĐỔI Ở ĐÂY: Dùng AssetImage
                                              child: Image.asset(
                                                subject.imageAsset, // <-- Dùng getter từ Model
                                                fit: BoxFit.cover,
                                                errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(subject.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                childCount: subjects.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 100)),
                        ],
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