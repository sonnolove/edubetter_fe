import 'package:flutter/material.dart';
import 'package:my_edu_app/services/api_service.dart';
import 'package:my_edu_app/services/chat_memory_service.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;
  final String title;

  const ChatScreen({super.key, required this.sessionId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final ChatMemoryService _chatMemory = ChatMemoryService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messages = _chatMemory.getMessages(widget.sessionId);
    });
    // Cuộn xuống cuối sau khi render xong
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  _chatMemory.addMessage(widget.sessionId, text, true);
  _controller.clear();
  _loadMessages();

  setState(() => _isLoading = true);

  try {
    // Gọi API: result chắc chắn là Map<String, dynamic> do khai báo trong ApiService
    // LƯU Ý: Nên truyền thêm sessionId để bot nhớ ngữ cảnh (xem phần lời khuyên bên dưới)
    final result = await _apiService.chatWithTutor(text, sessionId: widget.sessionId);
    
    String aiText = "Không có câu trả lời";

    // Kiểm tra và trích xuất dữ liệu an toàn
    if (result.containsKey('data') && result['data'] is Map) {
      // Trường hợp chuẩn: { "success": true, "data": { "answer": "..." } }
      aiText = result['data']['answer']?.toString() ?? "Lỗi: Dữ liệu trống";
    } else if (result.containsKey('message')) {
      // Trường hợp server trả về lỗi dạng: { "message": "Lỗi gì đó..." }
      aiText = result['message']?.toString() ?? "Lỗi không xác định";
    } else {
      // Trường hợp dự phòng: In ra toàn bộ map nếu cấu trúc lạ
      aiText = result.toString(); 
    }

    if (mounted) {
      _chatMemory.addMessage(widget.sessionId, aiText, false);
      _loadMessages();
    }
  } catch (e) {
    if (mounted) {
      _chatMemory.addMessage(widget.sessionId, "Lỗi kết nối: $e", false);
      _loadMessages();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("Bắt đầu cuộc trò chuyện...", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: msg.isUser ? Colors.blueAccent : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("AI đang trả lời...", style: TextStyle(color: Colors.grey)),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Nhập câu hỏi...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}