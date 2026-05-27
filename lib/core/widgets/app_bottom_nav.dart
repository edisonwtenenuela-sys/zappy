import 'package:flutter/material.dart';
import 'package:zappy/core/i18n/app_i18n.dart';
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
    final t = AppI18n.of(context).t;

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.play_arrow), label: t.feed),
          NavigationDestination(icon: const Icon(Icons.live_tv), label: t.live),
          NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), label: t.chat),
          NavigationDestination(icon: const Icon(Icons.videogame_asset), label: t.games),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), label: t.wallet),
        ],
      ),
    );
  }
}
