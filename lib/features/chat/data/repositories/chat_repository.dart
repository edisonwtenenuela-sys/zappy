import 'package:zappy/core/data/fake_api_client.dart';
import 'package:zappy/features/chat/data/chat_mock_data.dart';
import 'package:zappy/features/chat/domain/chat_models.dart';

class ChatRepository {
  ChatRepository({FakeApiClient? apiClient}) : _apiClient = apiClient ?? const FakeApiClient();

  final FakeApiClient _apiClient;

  Future<List<ChatThread>> fetchThreads() {
    return _apiClient.request(ChatMockData.threads);
  }
}
