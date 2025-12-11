class Subject {
  final String id;
  final String name;
  final String description;
  // final String thumbnailUrl; // <-- Đã xóa dòng này
  final int totalLessons;
  final int completedLessons;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    // required this.thumbnailUrl, // <-- Đã xóa dòng này
    this.totalLessons = 0,
    this.completedLessons = 0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? json['title'] ?? 'Môn học',
      description: json['description'] ?? '',
      // Không lấy thumbnailUrl từ JSON nữa
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
    );
  }

  // --- HÀM TỰ CHỌN ẢNH LOCAL DỰA THEO TÊN MÔN ---
  // Bạn hãy đảm bảo tên file ảnh trong assets/images khớp với các tên dưới đây
  String get imageAsset {
    final n = name.toLowerCase();
    if (n.contains('toán')) return 'assets/image/math.jpg';
    if (n.contains('văn') || n.contains('ngữ văn')) return 'assets/image/literature.jpg';
    if (n.contains('anh') || n.contains('tiếng anh')) return 'assets/image/english.jpg';
    if (n.contains('lý') || n.contains('vật lý')) return 'assets/image/physics.jpg';
    if (n.contains('hóa')) return 'assets/image/chemistry.jpg';
    if (n.contains('sinh')) return 'assets/image/biology.jpg';
    if (n.contains('sử') || n.contains('lịch sử')) return 'assets/image/his.jpg';
    if (n.contains('địa')) return 'assets/image/geography.jpg';
    if (n.contains('pháp')) return 'assets/image/economic.jpg';
    
    // Ảnh mặc định nếu không tìm thấy tên môn (Bạn nên tạo file này)
    return 'assets/image/default.jpg'; 
  }
}