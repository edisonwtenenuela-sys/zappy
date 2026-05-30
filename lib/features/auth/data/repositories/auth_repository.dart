import 'package:zappy/core/data/api_client.dart';
import 'package:zappy/features/auth/domain/auth_user.dart';

class AuthLoginResult {
  const AuthLoginResult({required this.token, required this.user});

  final String token;
  final AuthUser user;
}

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthLoginResult> login({required String email, required String password}) async {
    final json = await _apiClient.postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return _mapAuthResult(json);
  }

  Future<AuthLoginResult> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final json = await _apiClient.postJson('/api/auth/register', {
      'email': email,
      'password': password,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
    });
    return _mapAuthResult(json);
  }

  Future<AuthUser> me(String token) async {
    final json = await _apiClient.getJson(
      '/api/auth/me',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) throw Exception('User not received');
    return AuthUser.fromJson(data);
  }

  AuthLoginResult _mapAuthResult(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final token = data?['token']?.toString();
    final userMap = data?['user'] as Map<String, dynamic>?;
    if (token == null || token.isEmpty) throw Exception('Token not received');
    if (userMap == null) throw Exception('User not received');

    return AuthLoginResult(token: token, user: AuthUser.fromJson(userMap));
  }
}
