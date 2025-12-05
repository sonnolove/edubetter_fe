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

  Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'Content-Type': 'application/json'};
    }
    final idToken = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
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
    final url = Uri.parse('$_baseUrl/api/courses');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  Future<List<dynamic>> getLessons(String subjectId) async {
    final url = Uri.parse('$_baseUrl/api/courses/$subjectId/lessons');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load lessons');
    }
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

  Future<dynamic> generateQuiz(List<String> lessonIds, String title) async {
    final url = Uri.parse('$_baseUrl/api/quizzes/generate');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({'lessonIds': lessonIds, 'title': title}),
    );
    if (response.statusCode == 201) return json.decode(response.body);
    throw Exception('Failed to generate quiz: ${response.body}');
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

  // Trong class ApiService, thêm đoạn code này vào cuối (trước dấu } đóng class)

  // --- CHAT TUTOR (GIA SƯ AI) ---
  Future<String> chatWithTutor(String question) async {
    final url = Uri.parse('$_baseUrl/api/chat-tutor');
    
    // Gửi câu hỏi lên Node.js
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({'question': question}),
    );

    if (response.statusCode == 200) {
      // Node.js trả về: { success: true, data: { answer: "...", sources: [...] } }
      final jsonResponse = json.decode(response.body);
      final aiData = jsonResponse['data'];
      
      // Bạn có thể lấy thêm sources nếu muốn hiển thị nguồn tài liệu
      return aiData['answer'] ?? "Lỗi: Không có câu trả lời.";
    } else {
      throw Exception('Chat failed: ${response.body}');
    }
  }


  
}