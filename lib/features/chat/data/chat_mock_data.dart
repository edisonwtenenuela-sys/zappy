import 'package:zappy/features/chat/domain/chat_models.dart';

class ChatMockData {
  static List<ChatThread> threads() {
    final now = DateTime.now();
    return [
      ChatThread(
        id: 't1',
        userName: 'Ana Creator',
        lastMessage: 'Gracias por el regalo de hoy!',
        lastAt: now.subtract(const Duration(minutes: 12)),
        unreadCount: 2,
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Hola Ana! tu live estuvo brutal',
            sentByMe: true,
            sentAt: now.subtract(const Duration(minutes: 40)),
          ),
          ChatMessage(
            id: 'm2',
            text: 'Gracias por el regalo de hoy!',
            sentByMe: false,
            sentAt: now.subtract(const Duration(minutes: 12)),
          ),
        ],
      ),
      ChatThread(
        id: 't2',
        userName: 'Carlos Gaming',
        lastMessage: 'Mañana hacemos torneo en sala.',
        lastAt: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'm3',
            text: 'Mañana hacemos torneo en sala.',
            sentByMe: false,
            sentAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      ChatThread(
        id: 't3',
        userName: 'Sofi Clips',
        lastMessage: 'Te paso los horarios del team.',
        lastAt: now.subtract(const Duration(days: 1, hours: 1)),
        unreadCount: 1,
        messages: [
          ChatMessage(
            id: 'm4',
            text: 'Te paso los horarios del team.',
            sentByMe: false,
            sentAt: now.subtract(const Duration(days: 1, hours: 1)),
          ),
        ],
      ),
    ];
  }
}
