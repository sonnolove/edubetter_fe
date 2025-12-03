class Lesson {
  final String id;
  final String title;
  final String youtubeUrl;
  final String textContent;
  final int order;

  Lesson({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.textContent,
    required this.order,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      youtubeUrl: json['youtubeUrl'] ?? '',
      textContent: json['textContent'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}