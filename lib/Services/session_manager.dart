import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _mobileKey = 'user_mobile';
  static const String _tokenKey = 'user_token';

  // Original method
  static Future<void> saveMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, mobile);
  }

  // ✅ New method to save both token and mobile together
  static Future<void> saveMobileAndToken(String mobile, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, mobile);
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mobileKey);
    await prefs.remove(_tokenKey);
  }
}
