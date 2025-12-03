import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/quiz/quiz_screen.dart'; // Để làm lại bài
import 'package:my_edu_app/services/api_service.dart';
import 'package:intl/intl.dart'; // Format ngày tháng (nếu chưa có intl thì hiển thị ngày thô cũng được)

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.getQuizHistory();
  }

  // Hàm helper để format ngày (nếu không dùng thư viện intl thì dùng hàm này cho đơn giản)
  String _formatDate(String? isoString) {
    if (isoString == null) return 'Không rõ ngày';
    try {
      final date = DateTime.parse(isoString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử Bài kiểm tra")),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Bạn chưa tạo bài kiểm tra nào.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final questions = quiz['questions'] as List<dynamic>? ?? [];
              
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: const Icon(Icons.assignment, color: Colors.deepPurple),
                  ),
                  title: Text(
                    quiz['title'] ?? 'Bài kiểm tra không tên',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Số câu hỏi: ${questions.length}"),
                      Text(
                        "Ngày tạo: ${_formatDate(quiz['createdAt'])}", // Server Firestore trả về createdAt dạng String hoặc Object
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Làm lại"),
                    onPressed: () {
                      // Chuyển sang màn hình làm bài với dữ liệu cũ
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(quizData: quiz),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}