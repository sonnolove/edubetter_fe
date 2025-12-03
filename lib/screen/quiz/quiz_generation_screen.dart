import 'package:flutter/material.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/quiz/quiz_screen.dart'; // <--- QUAN TRỌNG: Phải import file này

class QuizGenerationScreen extends StatefulWidget {
  final List<Lesson> lessons;
  final String courseId;

  const QuizGenerationScreen({
    super.key,
    required this.lessons,
    required this.courseId,
  });

  @override
  State<QuizGenerationScreen> createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen> {
  final Set<String> _selectedLessonIds = {};
  final _titleController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = "Quiz ôn tập";
  }

  // --- HÀM QUAN TRỌNG NHẤT ---
  Future<void> _generateQuiz() async {
    // 1. Kiểm tra input
    if (_selectedLessonIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ít nhất 1 bài học!')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 2. Gọi API tạo Quiz
      final result = await _apiService.generateQuiz(
        _selectedLessonIds.toList(),
        _titleController.text,
      );

      if (!mounted) return;

      // 3. Xử lý kết quả & Điều hướng
      // Lấy phần 'quizData' từ JSON trả về của server
      final quizData = result['quizData'];

      // Chuyển sang màn hình làm bài Quiz
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(quizData: quizData),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Quiz AI")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên bài kiểm tra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chọn các bài học để AI tạo câu hỏi:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = widget.lessons[index];
                  final isSelected = _selectedLessonIds.contains(lesson.id);
                  return CheckboxListTile(
                    title: Text(lesson.title),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedLessonIds.add(lesson.id);
                        } else {
                          _selectedLessonIds.remove(lesson.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateQuiz,
                icon: _isGenerating
                    ? const SizedBox.shrink()
                    : const Icon(Icons.auto_awesome),
                label: _isGenerating
                    ? const Text("Đang tạo câu hỏi...")
                    : const Text("GENERATE QUIZ (AI)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}