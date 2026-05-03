import 'package:shared_preferences/shared_preferences.dart';

class SignCacheTool {
  SignCacheTool._();

  static const String _prefix = 'sign.today';

  static String _key(int userId, String day) {
    return '$_prefix.$userId.$day';
  }

  static Future<void> saveTodayStatus({
    required int userId,
    required String day,
    required String rawJson,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String prefix = '$_prefix.$userId.';
    final List<String> keys = prefs.getKeys().toList();
    for (final String key in keys) {
      if (key.startsWith(prefix) && key != _key(userId, day)) {
        await prefs.remove(key);
      }
    }
    await prefs.setString(_key(userId, day), rawJson);
  }

  static Future<String?> getTodayStatus({
    required int userId,
    required String day,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_key(userId, day)) ?? '';
    return raw.isEmpty ? null : raw;
  }

  static Future<void> clearTodayStatus({
    required int userId,
    required String day,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId, day));
  }
}
