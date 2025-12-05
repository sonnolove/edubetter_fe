import 'package:flutter/material.dart';
import 'package:my_edu_app/models/subject.dart';
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
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _subjectsFuture = _apiService.getSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refreshList(),
      child: FutureBuilder<List<dynamic>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có môn học nào.'));
          }

          final subjects = snapshot.data!.map((json) => Subject.fromJson(json)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              
              // Tính phần trăm tiến độ (0.0 đến 1.0)
              double progress = 0.0;
              if (subject.totalLessons > 0) {
                progress = subject.completedLessons / subject.totalLessons;
                if (progress > 1.0) progress = 1.0; // Đảm bảo không quá 100%
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject)),
                    ).then((_) => _refreshList()); // Reload khi quay lại
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh thumbnail
                      Stack(
                        children: [
                          Image.network(
                            subject.thumbnailUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 160, color: Colors.grey[300], child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                          // Badge hiển thị số lượng bài
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${subject.totalLessons} bài học",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên môn
                            Text(
                              subject.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            // Mô tả
                            Text(
                              subject.description,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // --- THANH TIẾN ĐỘ ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tiến độ học tập",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${subject.completedLessons}/${subject.totalLessons}",
                                  style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                color: progress == 1.0 ? Colors.green : Colors.blueAccent, // Xanh lá nếu xong, xanh dương nếu đang học
                                minHeight: 8,
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
          );
        },
      ),
    );
  }
}