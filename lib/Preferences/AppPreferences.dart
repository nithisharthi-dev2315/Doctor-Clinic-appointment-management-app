import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 🔑 KEYS
  static const String keyDoctorId = "doctor_id";
  static const String keyUsername = "username";
  static const String keyPassword = "password";
  static const String keyIsLoggedIn = "is_logged_in";
  static const String keyEmail = "email";
  static const String keyMobile = "mobile";
  static const String keyRole = "role";

  // 🟢 SETTERS
  static Future<void> setDoctorId(String value) async =>
      await _prefs?.setString(keyDoctorId, value);

  static Future<void> setUsername(String value) async =>
      await _prefs?.setString(keyUsername, value);

  static Future<void> setPassword(String value) async =>
      await _prefs?.setString(keyPassword, value);

  static Future<void> setLoggedIn(bool value) async =>
      await _prefs?.setBool(keyIsLoggedIn, value);

  static Future<void> setEmail(String value) async =>
      await _prefs?.setString(keyEmail, value);

  static Future<void> setMobile(String value) async =>
      await _prefs?.setString(keyMobile, value);

  static Future<void> setRole(String value) async =>
      await _prefs?.setString(keyRole, value);

  // 🔵 GETTERS
  static String getDoctorId() =>
      _prefs?.getString(keyDoctorId) ?? "";

  static String getUsername() =>
      _prefs?.getString(keyUsername) ?? "";

  static String getPassword() =>
      _prefs?.getString(keyPassword) ?? "";

  static bool isLoggedIn() =>
      _prefs?.getBool(keyIsLoggedIn) ?? false;

  static String getEmail() =>
      _prefs?.getString(keyEmail) ?? "";

  static String getMobile() =>
      _prefs?.getString(keyMobile) ?? "";

  static String getRole() =>
      _prefs?.getString(keyRole) ?? "";

  // 🔴 CLEAR
  static Future<void> logout() async =>
      await _prefs?.clear();
}


