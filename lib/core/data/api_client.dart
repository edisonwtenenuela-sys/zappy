import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zappy/core/data/api_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid JSON format');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error']?.toString() ?? 'Unexpected API error';
      throw Exception(error);
    }

    return decoded;
  }
}
