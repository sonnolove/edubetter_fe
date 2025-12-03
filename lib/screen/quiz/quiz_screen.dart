import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizScreen({super.key, required this.quizData});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  
  // Lấy danh sách câu hỏi từ dữ liệu quizData
  List<dynamic> get _questions => widget.quizData['questions'] ?? [];

  void _answerQuestion(String answerKey) {
    if (_isAnswered) return; // Chặn bấm nhiều lần

    setState(() {
      _isAnswered = true;
      _selectedAnswer = answerKey;
      
      // Kiểm tra đáp án đúng
      String correctAnswer = _questions[_currentQuestionIndex]['correctAnswer'];
      if (answerKey == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      } else {
        // Đã hết câu hỏi -> Hiện kết quả
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Kết quả"),
        content: Text("Bạn trả lời đúng $_score / ${_questions.length} câu!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng dialog
              Navigator.of(context).pop(); // Thoát màn hình Quiz về lại trang trước
            },
            child: const Text("Kết thúc"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = Map<String, String>.from(currentQuestion['options']);

    return Scaffold(
      appBar: AppBar(
        title: Text("Câu hỏi ${_currentQuestionIndex + 1}/${_questions.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hiển thị câu hỏi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentQuestion['question'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Hiển thị các lựa chọn (A, B, C, D)
            ...options.entries.map((entry) {
              final key = entry.key;   // "A", "B",...
              final text = entry.value; // Nội dung đáp án
              
              Color bgColor = Colors.white;
              if (_isAnswered) {
                if (key == currentQuestion['correctAnswer']) {
                  bgColor = Colors.green.shade100; // Đáp án đúng hiện màu xanh
                } else if (key == _selectedAnswer) {
                  bgColor = Colors.red.shade100;   // Đáp án sai bạn chọn hiện màu đỏ
                }
              } else if (_selectedAnswer == key) {
                bgColor = Colors.blue.shade100;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: bgColor,
                    padding: const EdgeInsets.all(16),
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _answerQuestion(key),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$key. $text",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // Nút "Câu tiếp theo" chỉ hiện khi đã chọn đáp án
            if (_isAnswered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1 
                      ? "Câu tiếp theo" 
                      : "Xem kết quả",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}