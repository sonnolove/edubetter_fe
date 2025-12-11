import 'package:flutter/material.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/screen/lesson_detail_screen.dart';
import 'package:my_edu_app/screen/quiz/quiz_generation_screen.dart';
import 'package:my_edu_app/services/api_service.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final ApiService _apiService = ApiService();
  
  // Biến chứa danh sách bài học (sẽ được load từ API)
  late Future<List<dynamic>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    // [QUAN TRỌNG] Gọi API ngay khi mở màn hình để lấy trạng thái mới nhất
    _loadLessons();
  }

  // Hàm tải dữ liệu (tách ra để dùng cho cả lúc mới vào và lúc quay lại)
  void _loadLessons() {
    _lessonsFuture = _apiService.getLessons(widget.subject.id);
  }

  // Helper: Lấy ảnh theo tên môn (để hiển thị trên Header)
  String _getSubjectImage(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('địa')) return 'assets/image/SLI_geo.png';
    if (name.contains('sử')) return 'assets/image/SLI_his.png';
    if (name.contains('pháp') || name.contains('gdcd')) return 'assets/image/SLI_eco.png';
    return 'assets/image/kt.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<dynamic>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          // 1. ĐANG TẢI
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          // 2. LỖI
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text('Lỗi: ${snapshot.error}'),
                  TextButton(
                    onPressed: () => setState(() => _loadLessons()),
                    child: const Text("Thử lại"),
                  )
                ],
              ),
            );
          }

          // 3. CÓ DỮ LIỆU -> HIỂN THỊ DANH SÁCH
          final lessons = snapshot.data!.map((json) => Lesson.fromJson(json)).toList();

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // --- HEADER ẢNH BÌA ---
                    SliverAppBar(
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.blueAccent,
                      leading: IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.arrow_back, color: Colors.white)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(widget.subject.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(_getSubjectImage(widget.subject.name), fit: BoxFit.cover),
                            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
                          ],
                        ),
                      ),
                    ),

                    // --- DANH SÁCH BÀI HỌC ---
                    if (lessons.isEmpty)
                      const SliverFillRemaining(child: Center(child: Text("Chưa có bài học nào.", style: TextStyle(color: Colors.grey))))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final lesson = lessons[index];
                              
                              // [MẤU CHỐT] Kiểm tra bài này đã học chưa ngay từ dữ liệu API
                              final bool isDone = lesson.isCompleted; 

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  // Nếu xong rồi thì viền xanh, chưa thì thôi
                                  border: isDone ? Border.all(color: Colors.green.shade200, width: 1) : null,
                                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () async {
                                      // Chuyển sang màn hình học
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LessonDetailScreen(
                                            lesson: lesson,
                                            subjectId: widget.subject.id,
                                          ),
                                        ),
                                      );
                                      // [QUAN TRỌNG] Khi quay về -> Load lại API ngay lập tức để cập nhật dấu tích
                                      if (mounted) {
                                        setState(() {
                                          _loadLessons();
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          // --- CỘT 1: TRẠNG THÁI (SỐ HOẶC TÍCH XANH) ---
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              // Xanh lá nếu xong, Xanh dương nếu chưa
                                              color: isDone ? Colors.green.shade50 : Colors.blue.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            // [LOGIC HIỂN THỊ]
                                            child: isDone
                                                ? const Icon(Icons.check_rounded, color: Colors.green, size: 24) // Đã học -> Hiện tích
                                                : Text('${index + 1}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 16)), // Chưa học -> Hiện số
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // --- CỘT 2: THÔNG TIN BÀI HỌC ---
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lesson.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: isDone ? Colors.black54 : Colors.black87, // Đã học thì chữ mờ đi xíu
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  isDone ? "Đã hoàn thành" : "Nhấn để bắt đầu học",
                                                  style: TextStyle(
                                                    color: isDone ? Colors.green : Colors.grey, // Đã học thì chữ xanh lá
                                                    fontSize: 12,
                                                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // --- CỘT 3: NÚT PLAY ---
                                          Icon(
                                            isDone ? Icons.replay_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                            color: isDone ? Colors.green : Colors.blueAccent,
                                            size: 32,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: lessons.length,
                          ),
                        ),
                      ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),

              // --- NÚT TẠO QUIZ DƯỚI CÙNG ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => QuizGenerationScreen(lessons: lessons, courseId: widget.subject.id)));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      icon: const Icon(Icons.auto_awesome, size: 22),
                      label: const Text("TẠO QUIZ TỪ MÔN HỌC", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}