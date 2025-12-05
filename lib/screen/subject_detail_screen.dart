import 'package:flutter/material.dart';
import 'package:my_edu_app/models/subject.dart'; // Dùng Subject
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/screen/lesson_detail_screen.dart';
import 'package:my_edu_app/screen/quiz/quiz_generation_screen.dart';
import 'package:my_edu_app/services/api_service.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject; // Đổi từ Course sang Subject

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    // Lấy danh sách bài học theo subject.id
    _lessonsFuture = _apiService.getLessons(widget.subject.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subject.name)),
      body: FutureBuilder<List<dynamic>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final lessons = snapshot.data!
              .map((json) => Lesson.fromJson(json))
              .toList();

          if (lessons.isEmpty) {
            return const Center(child: Text("Chưa có bài học nào."));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(lesson.title),
                      subtitle: const Text("Bấm để học"),
                      trailing: const Icon(Icons.play_circle_fill, color: Colors.red),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonDetailScreen(
                              lesson: lesson,
                              subjectId: widget.subject.id, // <--- THÊM DÒNG NÀY
                            ),
                          ),
                        ).then((_) {
                           // Khi quay lại từ bài học, có thể reload lại trang chi tiết môn học 
                           // (nếu trang này cũng hiển thị trạng thái đã học của từng bài)
                        });
                      },
                    );
                  },
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.quiz),
                  label: const Text("TẠO QUIZ TỪ MÔN HỌC NÀY"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizGenerationScreen(
                          lessons: lessons, 
                          courseId: widget.subject.id
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}