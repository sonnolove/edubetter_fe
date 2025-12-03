import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:my_edu_app/models/lesson.dart';
import 'package:url_launcher/url_launcher.dart'; // Thư viện mới
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // Chỉ khởi tạo Youtube Player nếu KHÔNG PHẢI là Web
    if (!kIsWeb) {
      final videoId = YoutubePlayer.convertUrlToId(widget.lesson.youtubeUrl);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Hàm mở link trên Web
  Future<void> _launchVideoUrl() async {
    final Uri url = Uri.parse(widget.lesson.youtubeUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở liên kết này')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.lesson.title, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KHUNG HIỂN THỊ (Xử lý khác nhau giữa Web và Mobile)
            Container(
              height: 240,
              width: double.infinity,
              color: Colors.black,
              child: _buildVideoArea(),
            ),

            // 2. NỘI DUNG BÀI HỌC
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 4, width: 60, color: Colors.orangeAccent),
                  const SizedBox(height: 24),
                  const Text("Nội dung bài học:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: MarkdownBody(
                      data: widget.lesson.textContent.isNotEmpty 
                          ? widget.lesson.textContent 
                          : "_Chưa có nội dung văn bản._",
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, height: 1.6),
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

  // Widget con để quyết định hiển thị Player hay Nút bấm
  Widget _buildVideoArea() {
    // TRƯỜNG HỢP 1: Đang chạy trên Web -> Hiện nút bấm mở link
    if (kIsWeb) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ondemand_video, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              "Trình phát video được tối ưu cho Ứng dụng Mobile",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _launchVideoUrl,
              icon: const Icon(Icons.open_in_new),
              label: const Text("Xem video trên YouTube"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      );
    }

    // TRƯỜNG HỢP 2: Đang chạy Mobile (Android/iOS) -> Hiện Player xịn
    if (_controller != null) {
      return YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
      );
    }

    // TRƯỜNG HỢP 3: Lỗi không load được video
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.white54),
          SizedBox(height: 10),
          Text('Không thể tải video', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}