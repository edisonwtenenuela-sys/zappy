import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zappy/features/auth/domain/auth_user.dart';

class AuthLocalDataSource {
  static const _isLoggedInKey = 'is_logged_in';
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _authUserKey = 'auth_user';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final loggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    return loggedIn && token != null && token.isNotEmpty && refreshToken != null && refreshToken.isNotEmpty;
  }

  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required AuthUser user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_authUserKey, jsonEncode(user.toStorageMap()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<AuthUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authUserKey);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw);
    if (map is! Map<String, dynamic>) return null;
    return AuthUser.fromStorageMap(map.map((k, v) => MapEntry(k, v?.toString() ?? '')));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_authUserKey);
  }
}
