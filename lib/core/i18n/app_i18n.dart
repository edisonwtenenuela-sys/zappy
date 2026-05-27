import 'package:flutter/material.dart';
import 'package:zappy/core/i18n/app_text.dart';

class AppI18n extends InheritedWidget {
  const AppI18n({
    super.key,
    required this.languageCode,
    required this.onChangeLanguage,
    required super.child,
  });

  final String languageCode;
  final Future<void> Function(String code) onChangeLanguage;

  static AppI18n of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppI18n>();
    assert(result != null, 'AppI18n not found in context');
    return result!;
  }

  AppText get t => AppText(languageCode);

  @override
  bool updateShouldNotify(covariant AppI18n oldWidget) {
    return oldWidget.languageCode != languageCode;
  }
}
