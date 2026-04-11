import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const _keyLanguage = 'language';

  // ← حفظ اللغة المختارة
  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, langCode);
  }

  // ← قراءة اللغة المحفوظة
  static Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  // ← حذف اللغة المحفوظة (يرجع للتلقائي)
  static Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLanguage);
  }
}
