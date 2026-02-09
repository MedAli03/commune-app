import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';

class AuthService {
  static const String _adminPin = '1234';

  Box get _box => Hive.box(authBoxName);

  bool get isAdminLoggedIn =>
      _box.get(adminLoggedInKey, defaultValue: false) as bool;

  Future<bool> loginWithPin(String pin) async {
    if (pin != _adminPin) {
      return false;
    }
    await _box.put(adminLoggedInKey, true);
    return true;
  }

  Future<void> logout() async {
    await _box.put(adminLoggedInKey, false);
  }
}
