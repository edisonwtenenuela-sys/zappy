import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class ZappyApp extends StatelessWidget {
  const ZappyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zappy',
      theme: AppTheme.light,
      initialRoute: AppRouter.root,
      routes: AppRouter.routes,
    );
  }
}
