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

  Future<void> _onSubjectSelected(Subject subject) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurple.shade50,
          width: double.infinity,
          child: const Text(
            "Chọn một môn học để bắt đầu tạo bài kiểm tra",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _subjectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu.'));
              }

              final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    leading: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                        // SỬA ĐỔI TẠI ĐÂY: Dùng ảnh local
                        image: DecorationImage(
                          image: AssetImage(subject.imageAsset), 
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Bấm để tạo Quiz"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () => _onSubjectSelected(subject),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}