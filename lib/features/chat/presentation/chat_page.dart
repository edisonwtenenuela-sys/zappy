import 'package:flutter/material.dart';
import 'package:zappy/features/chat/data/chat_mock_data.dart';
import 'package:zappy/features/chat/domain/chat_models.dart';
import 'package:zappy/features/chat/presentation/chat_detail_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = ChatMockData.threads();

    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final thread = threads[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF06B6D4).withValues(alpha: 0.16),
              child: Text(thread.userName[0]),
            ),
            title: Text(thread.userName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              thread.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: _ThreadMeta(thread: thread),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(thread: thread),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ThreadMeta extends StatelessWidget {
  const _ThreadMeta({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(thread.lastAt);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(time, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        if (thread.unreadCount > 0)
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.red,
            child: Text(
              '${thread.unreadCount}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
