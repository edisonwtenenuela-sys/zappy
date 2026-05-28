import 'package:zappy/core/data/api_client.dart';
import 'package:zappy/features/chat/data/chat_mock_data.dart';
import 'package:zappy/features/chat/domain/chat_models.dart';

class ChatRepository {
  ChatRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ChatThread>> fetchThreads() async {
    try {
      final json = await _apiClient.getJson('/api/chat/threads');
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

      return data.map((thread) {
        final messagesRaw = (thread['messages'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();

        return ChatThread(
          id: thread['id']?.toString() ?? '',
          userName: thread['userName']?.toString() ?? 'User',
          lastMessage: thread['lastMessage']?.toString() ?? '',
          lastAt: DateTime.tryParse(thread['lastAt']?.toString() ?? '') ?? DateTime.now(),
          unreadCount: (thread['unreadCount'] as num?)?.toInt() ?? 0,
          messages: messagesRaw
              .map(
                (msg) => ChatMessage(
                  id: msg['id']?.toString() ?? '',
                  text: msg['text']?.toString() ?? '',
                  sentByMe: msg['sentByMe'] == true,
                  sentAt: DateTime.tryParse(msg['sentAt']?.toString() ?? '') ?? DateTime.now(),
                ),
              )
              .toList(),
        );
      }).toList();
    } catch (_) {
      return ChatMockData.threads();
    }
  }
}
