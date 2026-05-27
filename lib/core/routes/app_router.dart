import 'package:flutter/material.dart';
import 'package:zappy/core/widgets/app_bottom_nav.dart';
import 'package:zappy/features/auth/presentation/login_page.dart';
import 'package:zappy/features/feed/presentation/feed_page.dart';
import 'package:zappy/features/live/presentation/live_page.dart';
import 'package:zappy/features/chat/presentation/chat_page.dart';
import 'package:zappy/features/wallet/presentation/wallet_page.dart';
import 'package:zappy/features/games/presentation/games_page.dart';

class AppRouter {
  static const root = '/';
  static const login = '/login';
  static const feed = '/feed';
  static const live = '/live';
  static const chat = '/chat';
  static const wallet = '/wallet';
  static const games = '/games';

  static final routes = <String, WidgetBuilder>{
    root: (_) => const AppBottomNav(),
    login: (_) => const LoginPage(),
    feed: (_) => const FeedPage(),
    live: (_) => const LivePage(),
    chat: (_) => const ChatPage(),
    wallet: (_) => const WalletPage(),
    games: (_) => const GamesPage(),
  };
}
