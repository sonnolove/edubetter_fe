class Subject {
  final String id;
  final String name; // Thay title bằng name
  final String description;
  final String thumbnailUrl;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      // Server trả về 'title' (do mình map trong server.js) hoặc 'name'
      // Để an toàn, ta ưu tiên lấy 'name', nếu không có thì lấy 'title'
      name: json['name'] ?? json['title'] ?? 'Môn học',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }
}