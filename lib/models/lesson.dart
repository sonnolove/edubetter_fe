class Lesson {
  final String id;
  final String title;
  final String youtubeUrl;
  final String textContent;
  final int order;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.textContent,
    required this.order,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      youtubeUrl: json['youtubeUrl'] ?? '',
      textContent: json['textContent'] ?? '',
      order: json['order'] ?? 0,
      // Map từ Server về (Lưu ý: tùy server trả về 0/1 hay true/false)
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1
    );
  }
}