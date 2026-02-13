import 'api_client.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final data = await _client.postJson('/admin/login', {
      'username': username,
      'password': password,
    });

    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Token missing from login response.');
    }
    return token;
  }

  Future<void> logout() async {
    await _client.postJson('/admin/logout', const {});
  }

  Future<Map<String, dynamic>> me() async {
    return _client.getJson('/admin/me');
  }
}
