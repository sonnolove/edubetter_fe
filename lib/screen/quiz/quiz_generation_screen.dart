import 'package:flutter/material.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/screen/quiz/quiz_screen.dart';

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
  
  // Biến lưu số lượng câu hỏi, mặc định là 5
  int _numberOfQuestions = 5;

  @override
  void initState() {
    super.initState();
    _titleController.text = "Quiz ôn tập";
  }

  Future<void> _generateQuiz() async {
    if (_selectedLessonIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ít nhất 1 bài học!')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Gọi API với tham số số lượng câu hỏi
      final result = await _apiService.generateQuiz(
        _selectedLessonIds.toList(),
        _titleController.text,
        numberOfQuestions: _numberOfQuestions, // Truyền số lượng đã chọn
      );

      if (!mounted) return;

      final quizData = result['quizData'];

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tên bài kiểm tra
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên bài kiểm tra',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Chọn số lượng câu hỏi (Mới)
            DropdownButtonFormField<int>(
              value: _numberOfQuestions,
              decoration: const InputDecoration(
                labelText: 'Số lượng câu hỏi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text("5 câu (Nhanh)")),
                DropdownMenuItem(value: 10, child: Text("10 câu (Tiêu chuẩn)")),
                DropdownMenuItem(value: 15, child: Text("15 câu (Chi tiết)")),
                DropdownMenuItem(value: 20, child: Text("20 câu (Thử thách)")),
                DropdownMenuItem(value: 25, child: Text("25 câu (Tổng hợp)")),
              ],
              onChanged: (val) {
                setState(() {
                  _numberOfQuestions = val!;
                });
              },
            ),
            const SizedBox(height: 24),

            // 3. Danh sách bài học
            const Text(
              "Chọn bài học để ôn tập:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  itemCount: widget.lessons.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lesson = widget.lessons[index];
                    final isSelected = _selectedLessonIds.contains(lesson.id);
                    return CheckboxListTile(
                      title: Text(lesson.title),
                      subtitle: Text(
                        "Bài số ${lesson.order}", 
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      value: isSelected,
                      activeColor: Colors.deepPurple,
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
            ),
            const SizedBox(height: 16),

            // 4. Nút tạo
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateQuiz,
                icon: _isGenerating
                    ? const SizedBox.shrink()
                    : const Icon(Icons.auto_awesome),
                label: _isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          ),
                          SizedBox(width: 10),
                          Text("AI đang soạn đề..."),
                        ],
                      )
                    : const Text("TẠO ĐỀ THI NGAY"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}