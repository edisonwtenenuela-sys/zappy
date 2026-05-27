import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zappy Feed')),
      body: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(12),
            child: SizedBox(
              height: 220,
              child: Center(
                child: Text('Video #${index + 1}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
