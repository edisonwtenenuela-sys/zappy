import 'package:flutter/material.dart';
import 'package:zappy/core/widgets/app_bottom_nav.dart';
import 'package:zappy/features/auth/data/auth_local_data_source.dart';
import 'package:zappy/features/auth/presentation/login_page.dart';
import 'core/theme/app_theme.dart';

class ZappyApp extends StatefulWidget {
  const ZappyApp({super.key});

  @override
  State<ZappyApp> createState() => _ZappyAppState();
}

class _ZappyAppState extends State<ZappyApp> {
  final _authLocal = AuthLocalDataSource();

  Future<void> _handleLogin() async {
    await _authLocal.setLoggedIn(true);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleLogout() async {
    await _authLocal.logout();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zappy',
      theme: AppTheme.light,
      home: FutureBuilder<bool>(
        future: _authLocal.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final loggedIn = snapshot.data ?? false;
          if (!loggedIn) {
            return LoginPage(onLogin: _handleLogin);
          }

          return AppBottomNav(onLogout: _handleLogout);
        },
      ),
    );
  }
}
