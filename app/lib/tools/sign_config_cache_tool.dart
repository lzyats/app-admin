import 'package:shared_preferences/shared_preferences.dart';

class SignConfigCacheTool {
  SignConfigCacheTool._();

  static const String _key = 'sign.config.v1';

  static Future<void> saveConfig(String rawJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rawJson.trim().isEmpty) {
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_key, rawJson);
  }

  static Future<String?> getConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_key) ?? '';
    return raw.isEmpty ? null : raw;
  }

  static Future<void> clearConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
