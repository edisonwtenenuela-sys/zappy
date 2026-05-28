import 'package:flutter/material.dart';
import 'package:zappy/core/i18n/app_i18n.dart';
import 'package:zappy/core/settings/locale_controller.dart';
import 'package:zappy/core/widgets/app_bottom_nav.dart';
import 'package:zappy/features/auth/data/auth_local_data_source.dart';
import 'package:zappy/features/auth/data/repositories/auth_repository.dart';
import 'package:zappy/features/auth/domain/auth_user.dart';
import 'package:zappy/features/auth/presentation/login_page.dart';
import 'core/theme/app_theme.dart';

class ZappyApp extends StatefulWidget {
  const ZappyApp({super.key});

  @override
  State<ZappyApp> createState() => _ZappyAppState();
}

class _ZappyAppState extends State<ZappyApp> {
  final _authLocal = AuthLocalDataSource();
  final _localeController = LocaleController();

  String? _languageCode;
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadUser();
  }

  Future<void> _loadLanguage() async {
    final code = await _localeController.resolveInitialLanguage();
    if (mounted) setState(() => _languageCode = code);
  }

  Future<void> _loadUser() async {
    final user = await _authLocal.getUser();
    if (mounted) setState(() => _currentUser = user);
  }

  Future<void> _changeLanguage(String code) async {
    await _localeController.saveLanguage(code);
    if (mounted) setState(() => _languageCode = code);
  }

  Future<void> _handleLogin(AuthLoginResult result) async {
    await _authLocal.saveSession(token: result.token, user: result.user);
    if (mounted) {
      setState(() {
        _currentUser = result.user;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authLocal.logout();
    if (mounted) {
      setState(() {
        _currentUser = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_languageCode == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
        theme: AppTheme.light,
      );
    }

    return AppI18n(
      languageCode: _languageCode!,
      onChangeLanguage: _changeLanguage,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zappy',
        theme: AppTheme.light,
        home: FutureBuilder<bool>(
          future: _authLocal.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final loggedIn = snapshot.data ?? false;
            if (!loggedIn) return LoginPage(onLogin: _handleLogin);

            return AppBottomNav(onLogout: _handleLogout, currentUser: _currentUser);
          },
        ),
      ),
    );
  }
}
