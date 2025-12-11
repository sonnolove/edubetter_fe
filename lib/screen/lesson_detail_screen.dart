import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:my_edu_app/services/api_service.dart'; // Import ApiService
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as mobile;

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  // Truyền thêm subjectId để gửi lên server khi đánh dấu xong
  final String subjectId; 

  const LessonDetailScreen({
    super.key, 
    required this.lesson, 
    required this.subjectId
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  mobile.YoutubePlayerController? _mobileController;
  final ApiService _apiService = ApiService();
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.lesson.isCompleted;
    // Khởi tạo video player... (Giữ nguyên code cũ)
    final videoId = mobile.YoutubePlayer.convertUrlToId(widget.lesson.youtubeUrl);
    if (videoId != null && !kIsWeb) {
      _mobileController = mobile.YoutubePlayerController(
        initialVideoId: videoId,
        flags: const mobile.YoutubePlayerFlags(autoPlay: false, mute: false, enableCaption: true),
      );
    }
    // TODO: Nếu muốn xịn hơn, có thể gọi API check xem bài này đã học chưa để set _isCompleted ban đầu
  }

  @override
  void dispose() {
    _mobileController?.dispose();
    super.dispose();
  }

  Future<void> _launchURL() async { /* ...Code cũ... */ }

  // Hàm xử lý khi bấm nút "Đánh dấu đã học"
  Future<void> _toggleCompletion() async {
    setState(() => _isLoading = true);
    try {
      final newState = !_isCompleted;
      await _apiService.updateLearningProgress(
        widget.lesson.id, 
        widget.subjectId, 
        newState
      );
      
      setState(() {
        _isCompleted = newState;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? "Đã đánh dấu hoàn thành! 🎉" : "Đã hủy hoàn thành"),
          backgroundColor: newState ? Colors.green : Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.lesson.title, style: const TextStyle(fontSize: 16)),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VIDEO (Giữ nguyên)
            Container(
              width: double.infinity,
              height: 240,
              color: Colors.black,
              child: _buildVideoPlayer(),
            ),

            // 2. NỘI DUNG
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.lesson.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  MarkdownBody(
                    data: widget.lesson.textContent.isNotEmpty ? widget.lesson.textContent : "_Chưa có nội dung chi tiết._",
                    styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 16, height: 1.6)),
                  ),
                  
                  const SizedBox(height: 40),

                  // 3. NÚT ĐÁNH DẤU HOÀN THÀNH (MỚI)
                  Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _toggleCompletion,
                          icon: Icon(
                            _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isCompleted ? "ĐÃ HOÀN THÀNH" : "ĐÁNH DẤU ĐÃ HỌC",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCompleted ? Colors.green : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() { /* ...Code cũ giữ nguyên... */ 
    if (kIsWeb) {
      return const Center(child: Text("Web Video Placeholder")); // Demo Web
    }
    if (_mobileController != null) {
      return mobile.YoutubePlayer(controller: _mobileController!);
    }
    return const SizedBox();
  }
}