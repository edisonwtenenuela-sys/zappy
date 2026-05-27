import 'package:flutter/material.dart';
import 'package:zappy/features/chat/presentation/chat_page.dart';
import 'package:zappy/features/feed/presentation/feed_page.dart';
import 'package:zappy/features/games/presentation/games_page.dart';
import 'package:zappy/features/live/presentation/live_page.dart';
import 'package:zappy/features/wallet/presentation/wallet_page.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FeedPage(),
      const LivePage(),
      const ChatPage(),
      const GamesPage(),
      WalletPage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.play_arrow), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.live_tv), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.videogame_asset), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
        ],
      ),
    );
  }
}
