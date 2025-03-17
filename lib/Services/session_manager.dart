import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _mobileKey = 'user_mobile';

  // Save mobile number
  static Future<void> saveMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, mobile);
  }

  // Retrieve mobile number
  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  // Clear session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mobileKey);
  }
}
