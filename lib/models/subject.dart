class Subject {
  final String id;
  final String name;
  final String description;
  final String thumbnailUrl;
  // Thêm 2 trường mới
  final int totalLessons;
  final int completedLessons;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    this.totalLessons = 0,
    this.completedLessons = 0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? json['title'] ?? 'Môn học',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      // Parse dữ liệu từ server (mặc định là 0 nếu không có)
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
    );
  }
}