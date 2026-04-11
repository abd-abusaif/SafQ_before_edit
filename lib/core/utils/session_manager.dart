import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // ← كلمة المرور في secure storage
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ← باقي البيانات في SharedPreferences (غير حساسة)
  static const _keyIdNumber = 'idNumber';
  static const _keyName = 'driverName';
  static const _keyRole = 'role';
  static const _keyLineFrom = 'lineFrom';
  static const _keyLineTo = 'lineTo';
  static const _keyIsLoggedIn = 'isLoggedIn';

  // ← كلمة المرور فقط في Secure Storage
  static const _keyPassword = 'currentPassword';

  static Future<void> saveSession({
    required String idNumber,
    required String name,
    required String role,
    required String lineFrom,
    required String lineTo,
    required String password,
  }) async {
    // ← البيانات العادية في SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdNumber, idNumber);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyLineFrom, lineFrom);
    await prefs.setString(_keyLineTo, lineTo);
    await prefs.setBool(_keyIsLoggedIn, true);

    // ← كلمة المرور في Secure Storage (مشفرة)
    await _secure.write(key: _keyPassword, value: password);
  }

  static Future<Map<String, String>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    // ← نقرأ كلمة المرور من Secure Storage
    final password = await _secure.read(key: _keyPassword) ?? '';

    return {
      'idNumber': prefs.getString(_keyIdNumber) ?? '',
      'name': prefs.getString(_keyName) ?? '',
      'role': prefs.getString(_keyRole) ?? '',
      'lineFrom': prefs.getString(_keyLineFrom) ?? '',
      'lineTo': prefs.getString(_keyLineTo) ?? '',
      'currentPassword': password, // ← من Secure Storage
    };
  }

  // ← تحديث كلمة المرور في Secure Storage
  static Future<void> updatePassword(String newPassword) async {
    await _secure.write(key: _keyPassword, value: newPassword);
  }

  static Future<void> clearSession() async {
    // ← نمسح الاثنين معاً
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secure.delete(key: _keyPassword);
  }
}
