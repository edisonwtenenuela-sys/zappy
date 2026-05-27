import 'package:flutter/material.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lives')),
      body: const Center(
        child: Text('Lives + regalos (próxima fase)'),
      ),
    );
  }
}
