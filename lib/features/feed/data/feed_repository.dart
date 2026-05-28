import 'package:flutter/material.dart';
import 'package:zappy/core/data/api_client.dart';
import 'package:zappy/features/feed/domain/feed_video.dart';

class FeedRepository {
  FeedRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<FeedVideo>> fetchFeedVideos() async {
    try {
      final json = await _apiClient.getJson('/api/feed');
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

      return data.map((item) {
        final colorHex = item['colorHex']?.toString() ?? '#0F172A';
        return FeedVideo(
          creator: item['creator']?.toString() ?? '@creator',
          description: item['description']?.toString() ?? '',
          likes: (item['likes'] as num?)?.toInt() ?? 0,
          comments: (item['comments'] as num?)?.toInt() ?? 0,
          shares: (item['shares'] as num?)?.toInt() ?? 0,
          color: _parseColor(colorHex),
        );
      }).toList();
    } catch (_) {
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
    }
  }

  Color _parseColor(String hex) {
    final sanitized = hex.replaceFirst('#', '');
    final full = sanitized.length == 6 ? 'FF$sanitized' : sanitized;
    return Color(int.tryParse(full, radix: 16) ?? 0xFF0F172A);
  }
}
