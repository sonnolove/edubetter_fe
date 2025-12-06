import 'package:flutter/material.dart';
import 'package:my_edu_app/screen/chat/chat_screen.dart';
import 'package:my_edu_app/services/chat_memory_service.dart'; // Import bộ nhớ local

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
      appBar: AppBar(
        title: const Text("Lịch sử Hỏi đáp AI"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewChat,
        label: const Text("Đoạn chat mới"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Chưa có lịch sử chat nào", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade50,
                      child: const Icon(Icons.smart_toy, color: Colors.deepPurple),
                    ),
                    title: Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${session.messages.length} tin nhắn",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: () => _openChat(
                      sessionId: session.id,
                      title: session.title,
                    ),
                  ),
                );
              },
            ),
    );
  }
}