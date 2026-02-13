import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionService {
  const AuthSessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'admin_auth_token';
  static const String _roleKey = 'user_role';
  static const String _adminRole = 'admin';
  final FlutterSecureStorage _storage;

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveRole(String role) {
    return _storage.write(key: _roleKey, value: role);
  }

  Future<String?> readRole() {
    return _storage.read(key: _roleKey);
  }

  Future<bool> isAdmin() async {
    final role = await readRole();
    return role == _adminRole;
  }

  Future<void> saveAdminSession(String token) async {
    await saveToken(token);
    await saveRole(_adminRole);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  Future<void> clearToken() {
    return clearSession();
  }
}
