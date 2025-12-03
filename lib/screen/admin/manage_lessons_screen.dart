import 'package:flutter/material.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/services/api_service.dart';

class ManageLessonsScreen extends StatefulWidget {
  final Subject subject;
  const ManageLessonsScreen({super.key, required this.subject});

  @override
  State<ManageLessonsScreen> createState() => _ManageLessonsScreenState();
}

class _ManageLessonsScreenState extends State<ManageLessonsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _lessonsFuture = _apiService.getLessons(widget.subject.id);
    });
  }

  void _showLessonDialog({Lesson? lesson}) {
    final titleController = TextEditingController(text: lesson?.title ?? '');
    final videoController = TextEditingController(text: lesson?.youtubeUrl ?? '');
    final contentController = TextEditingController(text: lesson?.textContent ?? '');
    final orderController = TextEditingController(text: (lesson?.order ?? 1).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lesson == null ? "Thêm Bài Học" : "Sửa Bài Học"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tên bài")),
              TextField(controller: videoController, decoration: const InputDecoration(labelText: "Link Video (Youtube)")),
              TextField(controller: orderController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Thứ tự")),
              TextField(
                controller: contentController, 
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Nội dung Text (cho AI đọc)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "subjectId": widget.subject.id, // Link với môn học hiện tại
                "title": titleController.text,
                "youtubeUrl": videoController.text, // Chú ý: backend nhận videoUrl, model Flutter dùng youtubeUrl
                "videoUrl": videoController.text,   // Gửi cả 2 cho chắc ăn với backend mới
                "textContent": contentController.text,
                "orderIndex": int.tryParse(orderController.text) ?? 1,
                "order": int.tryParse(orderController.text) ?? 1,
              };

              try {
                if (lesson == null) {
                  await _apiService.createLesson(data);
                } else {
                  await _apiService.updateLesson(lesson.id, data);
                }
                Navigator.pop(ctx);
                _refreshList();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thành công!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bài học: ${widget.subject.name}")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLessonDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final lessons = snapshot.data?.map((json) => Lesson.fromJson(json)).toList() ?? [];

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${lesson.order}')),
                title: Text(lesson.title),
                subtitle: Text(lesson.textContent, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showLessonDialog(lesson: lesson),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                         await _apiService.deleteLesson(lesson.id);
                         _refreshList();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}