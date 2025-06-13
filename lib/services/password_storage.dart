import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'password_map';

  static Future<void> savePassword(String reason, String password) async {
    final data = await _storage.read(key: _key);
    final Map<String, String> map = data != null
        ? Map<String, String>.from(jsonDecode(data))
        : {};
    map[reason] = password;
    await _storage.write(key: _key, value: jsonEncode(map));
  }

  static Future<Map<String, String>> getAllPasswords() async {
    final data = await _storage.read(key: _key);
    return data != null ? Map<String, String>.from(jsonDecode(data)) : {};
  }

  static Future<void> deletePassword(String reason) async {
    final data = await _storage.read(key: _key);
    if (data == null) return;

    final Map<String, String> map = Map<String, String>.from(jsonDecode(data));
    map.remove(reason);
    await _storage.write(key: _key, value: jsonEncode(map));
  }
}
