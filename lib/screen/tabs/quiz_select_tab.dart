import 'package:flutter/material.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/screen/quiz/quiz_generation_screen.dart';
import 'package:my_edu_app/services/api_service.dart';

class QuizSelectTab extends StatefulWidget {
  const QuizSelectTab({super.key});

  @override
  State<QuizSelectTab> createState() => _QuizSelectTabState();
}

class _QuizSelectTabState extends State<QuizSelectTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _apiService.getSubjects();
  }

  // --- 1. HÀM CHỌN ẢNH DỰA TRÊN TÊN MÔN ---
  String _getSubjectImage(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('địa')) return 'assets/image/dia.png';
    if (name.contains('sử')) return 'assets/image/su.png';
    // Môn GDCD hoặc Pháp luật
    if (name.contains('gdcd') || name.contains('pháp')) return 'assets/image/gdcd.png';
    
    // Ảnh mặc định nếu không khớp tên (bạn có thể đổi thành ảnh khác)
    return 'assets/image/kt.jpg'; 
  }

  // --- 2. LOGIC CŨ (GIỮ NGUYÊN) ---
  Future<void> _onSubjectSelected(Subject subject) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final lessonsData = await _apiService.getLessons(subject.id);
      final lessons = lessonsData.map((json) => Lesson.fromJson(json)).toList();

      if (!mounted) return;
      Navigator.pop(context);

      if (lessons.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Môn học này chưa có bài học nào.")));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizGenerationScreen(lessons: lessons, courseId: subject.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải bài học: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền sáng nhẹ
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ĐẸP HƠN ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thư viện Đề thi",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Chọn môn học để tạo bài kiểm tra trắc nghiệm",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // --- DANH SÁCH MÔN HỌC ---
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _subjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text('Chưa có môn học nào.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final imagePath = _getSubjectImage(subject.name); // Lấy ảnh theo tên

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _onSubjectSelected(subject),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // --- HÌNH ẢNH MÔN HỌC ---
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: AssetImage(imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
                                    ]
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // --- THÔNG TIN MÔN ---
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Tạo Quiz ngay",
                                          style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // --- NÚT ARROW ---
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.blueAccent),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}