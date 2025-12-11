import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      // Nếu chạy máy ảo Android thì dùng 10.0.2.2
      // Nếu chạy máy thật thì phải dùng IP LAN của máy tính (VD: 192.168.1.X)
      return 'http://10.0.2.2:3000';
    }
  }

  // Hàm tạo Header thông minh
  Future<Map<String, String>> _getHeaders() async {
    // 1. Lấy user hiện tại
    final user = FirebaseAuth.instance.currentUser;
    
    // 2. Header mặc định (luôn cần)
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 3. CHỈ KHI ĐÃ ĐĂNG NHẬP mới lấy Token gắn vào
    if (user != null) {
      try {
        final token = await user.getIdToken();
        headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        print("Lỗi lấy token: $e");
      }
    }
    
    // 4. Nếu LÀ KHÁCH -> Vẫn trả về headers (nhưng không có Authorization)
    // Để server biết đây là khách và trả về dữ liệu public
    return headers;
  }

  // --- ADMIN: QUẢN LÝ USER ---
  Future<List<dynamic>> getAllUsers() async {
    final url = Uri.parse('$_baseUrl/api/admin/users');
    print("ApiService: Đang gọi API $url"); // DEBUG

    final response = await http.get(url, headers: await _getHeaders());
    
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      // In chi tiết lỗi từ server trả về
      print("ApiService Error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    final url = Uri.parse('$_baseUrl/api/admin/users/$uid/role');
    await http.put(
      url,
      headers: await _getHeaders(),
      body: json.encode({'role': newRole}),
    );
  }

  // --- ADMIN: SUBJECTS ---
  Future<void> createSubject(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/admin/subjects');
    await http.post(url, headers: await _getHeaders(), body: json.encode(data));
  }

  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/admin/subjects/$id');
    await http.put(url, headers: await _getHeaders(), body: json.encode(data));
  }

  Future<void> deleteSubject(String id) async {
    final url = Uri.parse('$_baseUrl/api/admin/subjects/$id');
    await http.delete(url, headers: await _getHeaders());
  }

  // --- ADMIN: LESSONS ---
  Future<void> createLesson(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/admin/lessons');
    await http.post(url, headers: await _getHeaders(), body: json.encode(data));
  }

  Future<void> updateLesson(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/admin/lessons/$id');
    await http.put(url, headers: await _getHeaders(), body: json.encode(data));
  }

  Future<void> deleteLesson(String id) async {
    final url = Uri.parse('$_baseUrl/api/admin/lessons/$id');
    await http.delete(url, headers: await _getHeaders());
  }

  // --- ADMIN: USER MANAGEMENT (Full CRUD) ---
  
  // // 1. Lấy danh sách (Đã có)
  // Future<List<dynamic>> getAllUsers() async {
  //   final url = Uri.parse('$_baseUrl/api/admin/users');
  //   final response = await http.get(url, headers: await _getHeaders());
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body) as List<dynamic>;
  //   } else {
  //     throw Exception('Failed to load users');
  //   }
  // }

  // 2. Tạo User mới
  Future<void> createUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/admin/users');
    final response = await http.post(
      url, 
      headers: await _getHeaders(), 
      body: json.encode(data)
    );
    
    if (response.statusCode != 201) {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  // 3. Cập nhật User
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/admin/users/$uid');
    await http.put(
      url, 
      headers: await _getHeaders(), 
      body: json.encode(data)
    );
  }

  // 4. Xóa User
  Future<void> deleteUser(String uid) async {
    final url = Uri.parse('$_baseUrl/api/admin/users/$uid');
    await http.delete(url, headers: await _getHeaders());
  }


  // --- USER & COURSES & QUIZ ---
  Future<void> createProfile(String fullName, String? avatarUrl) async {
    final url = Uri.parse('$_baseUrl/api/users/create-profile');
    try {
      await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({'fullName': fullName, 'avatarUrl': avatarUrl}),
      );
    } catch (e) {
      print('Error creating profile: $e');
    }
  }

  Future<List<dynamic>> getSubjects() async {
    // Đảm bảo URL đúng (nếu chạy máy ảo Android thì localhost là 10.0.2.2)
    final url = Uri.parse('$_baseUrl/api/courses'); 
    
    try {
      final headers = await _getHeaders();
      print("Đang gọi API: $url với headers: $headers"); // <--- In ra xem có token không

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print("Load data thành công!");
        return json.decode(response.body) as List<dynamic>;
      } else {
        print("Lỗi Server: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      print('Lỗi fetching subjects: $e');
      return []; // Trả về rỗng nếu lỗi
    }
  }

 // --- SỬA ĐỔI: Lấy bài học VÀ ghép với tiến độ học tập ---
  Future<List<dynamic>> getLessons(String subjectId) async {
    final user = FirebaseAuth.instance.currentUser;
    final headers = await _getHeaders();

    // BƯỚC 1: Gọi API lấy danh sách bài học gốc (như cũ)
    final lessonUrl = Uri.parse('$_baseUrl/api/courses/$subjectId/lessons');
    final lessonResponse = await http.get(lessonUrl, headers: headers);

    if (lessonResponse.statusCode != 200) {
      throw Exception('Failed to load lessons');
    }

    // Convert dữ liệu bài học sang dạng List Map (để có thể chỉnh sửa)
    List<dynamic> lessons = List<Map<String, dynamic>>.from(
        json.decode(lessonResponse.body).map((x) => Map<String, dynamic>.from(x))
    );

    // BƯỚC 2: Nếu user đã đăng nhập, gọi thêm API lấy tiến độ
    if (user != null) {
      try {
        // [QUAN TRỌNG] Gọi API lấy danh sách ID các bài đã học.
        // Lưu ý: Đường dẫn này phải khớp với Server Node.js của bạn.
        // Thường là GET /api/learning-progress?userId=...&subjectId=...
        final progressUrl = Uri.parse(
            '$_baseUrl/api/learning-progress?userId=${user.uid}&subjectId=$subjectId'
        );
        
        final progressResponse = await http.get(progressUrl, headers: headers);

        if (progressResponse.statusCode == 200) {
          final progressData = json.decode(progressResponse.body);
          
          // Tạo một danh sách chứa các ID bài đã học cho dễ tìm kiếm
          Set<String> completedLessonIds = {};

          // Xử lý dữ liệu trả về (tùy theo server trả về mảng String hay mảng Object)
          if (progressData is List) {
            for (var item in progressData) {
              if (item is String) {
                completedLessonIds.add(item); // Nếu server trả về ["id1", "id2"]
              } else if (item is Map && item['lessonId'] != null) {
                completedLessonIds.add(item['lessonId']); // Nếu server trả về [{"lessonId": "id1"}, ...]
              }
            }
          }

          // BƯỚC 3: MERGE (GHÉP DỮ LIỆU)
          // Duyệt qua từng bài học, kiểm tra xem ID có nằm trong danh sách đã học không
          for (var lesson in lessons) {
            final String id = lesson['id'].toString();
            // Nếu tìm thấy ID trong danh sách đã học -> gán is_completed = true
            if (completedLessonIds.contains(id)) {
              lesson['is_completed'] = true; 
            } else {
              lesson['is_completed'] = false;
            }
          }
          print("Đã cập nhật trạng thái học: $completedLessonIds"); // Log để kiểm tra
        }
      } catch (e) {
        print("Lỗi khi lấy tiến độ học tập (Không ảnh hưởng app, chỉ không hiện tick xanh): $e");
      }
    }

    return lessons;
  }

  // --- LEARNING PROGRESS ---
  Future<void> updateLearningProgress(String lessonId, String subjectId, bool isCompleted) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('$_baseUrl/api/learning-progress');
    try {
      await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'userId': user.uid,
          'lessonId': lessonId,
          'subjectId': subjectId,
          'isCompleted': isCompleted,
        }),
      );
    } catch (e) {
      print('Error updating progress: $e');
      throw e; // Ném lỗi để UI biết mà xử lý (ví dụ: hiện thông báo lỗi)
    }
  }

 // --- HÀM TẠO QUIZ (CẬP NHẬT MỚI) ---
  Future<dynamic> generateQuiz(List<String> lessonIds, String title, {int numberOfQuestions = 5}) async {
    final url = Uri.parse('$_baseUrl/api/quizzes/generate');
    
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({
        'lessonIds': lessonIds,
        'title': title,
        'numberOfQuestions': numberOfQuestions, // Gửi số lượng câu hỏi lên server
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate quiz: ${response.body}');
    }
  }

  // --- CHECK ADMIN ROLE ---
  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("isAdmin: User is null");
      return false;
    }
    
    print("isAdmin: Đang kiểm tra quyền cho user ${user.uid}...");
    try {
      // Nếu gọi thành công API này nghĩa là có quyền Admin
      await getAllUsers();
      print("isAdmin: Kiểm tra thành công -> TRUE");
      return true;
    } catch (e) {
      print("isAdmin: Kiểm tra thất bại -> FALSE. Lý do: $e");
      return false;
    }
  }

    // --- QUIZ HISTORY ---
  Future<List<dynamic>> getQuizHistory() async {
    final url = Uri.parse('$_baseUrl/api/quizzes');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load quiz history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quiz history: $e');
      rethrow;
    }
  }


  // --- CHAT TUTOR & HISTORY ---

  // 1. Lấy danh sách các cuộc trò chuyện
  Future<List<dynamic>> getChatSessions() async {
    final url = Uri.parse('$_baseUrl/api/chat/sessions');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        return []; // Trả về rỗng nếu lỗi hoặc chưa có
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      return [];
    }
  }

  // 2. Lấy nội dung tin nhắn của 1 cuộc trò chuyện
  Future<List<dynamic>> getChatMessages(String sessionId) async {
    final url = Uri.parse('$_baseUrl/api/chat/sessions/$sessionId/messages');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  // 3. Gửi tin nhắn (CẬP NHẬT: Nhận thêm sessionId)
  // Trả về Map đầy đủ để lấy lại sessionId mới nếu có
  Future<Map<String, dynamic>> chatWithTutor(String question, {String? sessionId}) async {
    final url = Uri.parse('$_baseUrl/api/chat-tutor');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({
        'question': question,
        'sessionId': sessionId // Gửi kèm ID nếu đang chat dở
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Trả về { success, data, sessionId }
    } else {
      throw Exception('Chat failed: ${response.body}');
    }
  }

// User tự cập nhật Profile
  Future<void> updateMyProfile({String? fullName, String? email, String? avatarUrl}) async {
    final url = Uri.parse('$_baseUrl/api/users/me');
    final body = {};
    if (fullName != null) body['fullName'] = fullName;
    if (email != null) body['email'] = email;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi cập nhật: ${response.body}');
    }
    
    // Force reload lại user để app cập nhật thông tin mới ngay lập tức
    await FirebaseAuth.instance.currentUser?.reload();
  }

  // User tự đổi mật khẩu
  Future<void> changeMyPassword(String newPassword) async {
    final url = Uri.parse('$_baseUrl/api/users/me/password');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: json.encode({'password': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi đổi mật khẩu: ${response.body}');
    }
  }
  
}