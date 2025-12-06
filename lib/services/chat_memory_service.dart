class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id, 
    required this.title, 
    required this.createdAt,
    required this.messages
  });
}

class ChatMessage {
  final String text;
  final bool isUser; // true: user, false: bot
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

// Class quản lý dữ liệu trong RAM (Singleton)
class ChatMemoryService {
  static final ChatMemoryService _instance = ChatMemoryService._internal();
  factory ChatMemoryService() => _instance;
  ChatMemoryService._internal();

  // Danh sách các cuộc hội thoại
  final List<ChatSession> _sessions = [];

  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  // Tạo cuộc hội thoại mới
  String createNewSession() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _sessions.insert(0, ChatSession(
      id: id,
      title: "Cuộc trò chuyện mới",
      createdAt: DateTime.now(),
      messages: []
    ));
    return id;
  }

  // Thêm tin nhắn vào cuộc hội thoại
  void addMessage(String sessionId, String text, bool isUser) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      // Thêm tin nhắn
      _sessions[index].messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        time: DateTime.now()
      ));
      
      // Cập nhật tiêu đề nếu là tin nhắn đầu tiên của user
      if (isUser && _sessions[index].messages.length == 1) {
        _sessions[index].title = text.length > 30 ? "${text.substring(0, 30)}..." : text;
      }
    }
  }

  // Lấy tin nhắn của 1 session
  List<ChatMessage> getMessages(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId, 
        orElse: () => ChatSession(id: "", title: "", createdAt: DateTime.now(), messages: []));
    return session.messages;
  }

  // Xóa sạch dữ liệu (Dùng khi Đăng xuất)
  void clearAll() {
    _sessions.clear();
  }
}