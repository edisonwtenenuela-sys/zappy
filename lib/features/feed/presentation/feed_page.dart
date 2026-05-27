import 'package:flutter/material.dart';
import 'package:zappy/features/feed/data/feed_repository.dart';
import 'package:zappy/features/feed/domain/feed_video.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final Future<List<FeedVideo>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = FeedRepository().fetchFeedVideos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedVideo>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final videos = snapshot.data ?? <FeedVideo>[];
        return Scaffold(
          body: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [video.color.withValues(alpha: 0.85), Colors.black],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 86),
                    ),
                  ),
                  Positioned(
                    top: 56,
                    left: 16,
                    child: Text(
                      'Zappy',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 92,
                    bottom: 36,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.creator,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(video.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 28,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(icon: Icons.favorite, label: _formatNumber(video.likes)),
                        const SizedBox(height: 16),
                        _ActionButton(icon: Icons.chat_bubble, label: _formatNumber(video.comments)),
                        const SizedBox(height: 16),
                        _ActionButton(icon: Icons.share, label: _formatNumber(video.shares)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
