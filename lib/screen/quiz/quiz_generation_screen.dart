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

  // --- LOGIC GIỮ NGUYÊN 100% ---
  Future<void> _generateQuiz() async {
    if (_selectedLessonIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy chọn ít nhất 1 bài học!')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final result = await _apiService.generateQuiz(
        _selectedLessonIds.toList(),
        _titleController.text,
        numberOfQuestions: _numberOfQuestions,
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
      backgroundColor: Colors.grey[50], // Nền xám nhẹ hiện đại
      appBar: AppBar(
        title: const Text("Tạo Quiz AI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- PHẦN 1: CẤU HÌNH (HEADER) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                // Tên bài kiểm tra
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Tên bài kiểm tra',
                    hintText: "Nhập tên bài kiểm tra...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.edit_note_rounded, color: Colors.deepPurple),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Chọn số lượng câu hỏi
                DropdownButtonFormField<int>(
                  value: _numberOfQuestions,
                  decoration: InputDecoration(
                    labelText: 'Số lượng câu hỏi',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.quiz_rounded, color: Colors.deepPurple),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- PHẦN 2: DANH SÁCH BÀI HỌC ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.library_books_rounded, size: 20, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Chọn nội dung ôn tập (${_selectedLessonIds.length}/${widget.lessons.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: widget.lessons.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final lesson = widget.lessons[index];
                final isSelected = _selectedLessonIds.contains(lesson.id);
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLessonIds.remove(lesson.id);
                      } else {
                        _selectedLessonIds.add(lesson.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        // Checkbox custom
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isSelected ? Colors.deepPurple : Colors.grey[400],
                            size: 28,
                          ),
                        ),
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isSelected ? Colors.deepPurple.shade900 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Bài số ${lesson.order}",
                                style: TextStyle(
                                  color: isSelected ? Colors.deepPurple.shade400 : Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- PHẦN 3: NÚT TẠO (BOTTOM BAR) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.deepPurple.shade200,
                    elevation: _isGenerating ? 0 : 8,
                    shadowColor: Colors.deepPurple.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            ),
                            SizedBox(width: 12),
                            Text("AI đang soạn đề...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.auto_awesome, size: 22),
                            SizedBox(width: 10),
                            Text("TẠO ĐỀ THI NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}