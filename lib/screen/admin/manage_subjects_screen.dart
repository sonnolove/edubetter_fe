import 'package:flutter/material.dart';
import 'package:my_edu_app/models/subject.dart';
import 'package:my_edu_app/screen/admin/manage_lessons_screen.dart';
import 'package:my_edu_app/services/api_service.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _subjectsFuture = _apiService.getSubjects();
    });
  }

  // Hiển thị Dialog Thêm/Sửa
  void _showSubjectDialog({Subject? subject}) {
    final nameController = TextEditingController(text: subject?.name ?? '');
    final descController = TextEditingController(text: subject?.description ?? '');
    final imgController = TextEditingController(text: subject?.thumbnailUrl ?? '');
    // ID chỉ cho nhập khi tạo mới, sửa thì không đổi ID được
    final idController = TextEditingController(text: subject?.id ?? ''); 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subject == null ? "Thêm Môn Học" : "Sửa Môn Học"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subject == null) // Chỉ hiện ô nhập ID khi tạo mới
                TextField(controller: idController, decoration: const InputDecoration(labelText: "ID Môn (vd: math12)")),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên Môn")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Mô tả")),
              TextField(controller: imgController, decoration: const InputDecoration(labelText: "Link Ảnh")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "name": nameController.text,
                "description": descController.text,
                "thumbnailUrl": imgController.text,
              };
              if (subject == null) data["id"] = idController.text; // Gửi ID lên server

              try {
                if (subject == null) {
                  await _apiService.createSubject(data);
                } else {
                  await _apiService.updateSubject(subject.id, data);
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
      appBar: AppBar(title: const Text("Quản lý Môn học")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));

          final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final sub = subjects[index];
              return ListTile(
                leading: Image.network(sub.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.error)),
                title: Text(sub.name),
                subtitle: Text(sub.id),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showSubjectDialog(subject: sub),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Xác nhận xóa
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Xác nhận"),
                            content: const Text("Xóa môn này sẽ không xóa bài học bên trong. Bạn chắc chứ?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa")),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _apiService.deleteSubject(sub.id);
                          _refreshList();
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Chuyển sang trang quản lý bài học của môn này
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ManageLessonsScreen(subject: sub)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}