import 'package:flutter/material.dart';
import 'package:zappy/core/data/fake_api_client.dart';
import 'package:zappy/features/feed/domain/feed_video.dart';

class FeedRepository {
  FeedRepository({FakeApiClient? apiClient}) : _apiClient = apiClient ?? const FakeApiClient();

  final FakeApiClient _apiClient;

  Future<List<FeedVideo>> fetchFeedVideos() {
    return _apiClient.request(() {
      return List.generate(
        8,
        (index) => FeedVideo(
          creator: '@creator${index + 1}',
          description: 'Contenido viral #${index + 1} en Zappy',
          likes: 1200 + (index * 137),
          comments: 80 + (index * 11),
          shares: 45 + (index * 7),
          color: Color.lerp(const Color(0xFF0F172A), const Color(0xFF06B6D4), index / 8)!,
        ),
      );
    });
  }
}
