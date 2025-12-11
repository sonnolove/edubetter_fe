import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/chat/chat_screen.dart';
import 'package:my_edu_app/services/chat_memory_service.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatMemoryService _chatMemory = ChatMemoryService();

  void _createNewChat() {
    // 1. Tạo session mới trong RAM
    final newId = _chatMemory.createNewSession();
    
    // 2. Chuyển sang màn hình chat
    _openChat(sessionId: newId, title: "Cuộc trò chuyện mới");
  }

  void _openChat({required String sessionId, required String title}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(sessionId: sessionId, title: title),
      ),
    );
    // Quay lại thì refresh giao diện để cập nhật tiêu đề/tin nhắn mới
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _chatMemory.sessions;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhẹ hiện đại
      appBar: AppBar(
        title: const Text(
          "Lịch sử Hỏi đáp AI",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple, // Màu chữ tím
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      
      // Nút tạo chat mới nổi bật hơn
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: _createNewChat,
          label: const Text("Hỏi AI ngay", style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add_comment_rounded),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      body: sessions.isEmpty
          ? _buildEmptyState() // Tách widget empty state ra cho gọn
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Đảo ngược danh sách để hiển thị chat mới nhất lên đầu (nếu cần logic này, còn không thì cứ để index)
                // Ở đây mình giữ nguyên logic index của bạn
                final session = sessions[index];
                
                return _buildSessionCard(session);
              },
            ),
    );
  }

  // Widget hiển thị khi chưa có tin nhắn
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy_outlined, size: 80, color: Colors.deepPurple.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chưa có cuộc trò chuyện nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "Hãy bắt đầu hỏi AI để giải đáp thắc mắc nhé!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị từng thẻ chat
  Widget _buildSessionCard(dynamic session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openChat(
            sessionId: session.id,
            title: session.title,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.deepPurple, size: 28),
                ),
                const SizedBox(width: 16),
                
                // Nội dung text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.message_rounded, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            "${session.messages.length} tin nhắn",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Icon mũi tên
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}