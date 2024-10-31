import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _isLoggedInKey = 'isLoggedIn';

  static Future<void> setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, status);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}
