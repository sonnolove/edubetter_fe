import 'package:flutter/material.dart';
import 'package:my_edu_app/models/subject.dart'; // Dùng model Subject mới
import 'package:my_edu_app/screen/subject_detail_screen.dart';
import 'package:my_edu_app/services/api_service.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _apiService.getSubjects(); // Gọi hàm mới
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _subjectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có môn học nào.'));
        }

        // Map sang List<Subject>
        final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    // Truyền Subject sang màn hình chi tiết
                    MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject)),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      subject.thumbnailUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 150, color: Colors.grey[300], child: const Icon(Icons.image),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subject.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(subject.description, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}