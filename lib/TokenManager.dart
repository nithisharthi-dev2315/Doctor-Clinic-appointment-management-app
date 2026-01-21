
import 'package:Zeromedixine/utils/ApiConstants.dart';
import 'package:flutter/cupertino.dart';
import 'Apiservice/appointment_api_service.dart';
import 'Preferences/AppPreferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

class TokenManager {
  static String? _accessToken;
  static Future<String>? _refreshingToken; // 🔒 lock

  /// 🔐 Save token after login
  static Future<void> saveToken(String token) async {
    _accessToken = token;
    await AppPreferences.setAccessToken(token);
    debugPrint("🔐 TOKEN SAVED");
  }

  /// 📦 Load token (app restart)
  static Future<void> loadTokenFromPrefs() async {
    _accessToken = AppPreferences.getAccessToken();
    debugPrint("📦 TOKEN LOADED FROM PREFS");
  }

  /// 🔑 Get valid token (AUTO refresh)
  static Future<String> getValidToken() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      await loadTokenFromPrefs();
    }

    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception("❌ Token not available");
    }

    // ⏳ Check expiry
    if (_isTokenExpired(_accessToken!)) {
      debugPrint("⏳ TOKEN EXPIRED");



      _refreshingToken ??= _refreshTokenSafely(_accessToken!);

      _accessToken = await _refreshingToken!;
      _refreshingToken = null;

      await AppPreferences.setAccessToken(_accessToken!);
      debugPrint("♻️ NEW TOKEN SAVED");
    }

    return _accessToken!;
  }

  /// 🔄 Refresh token safely
  static Future<String> _refreshTokenSafely(String oldToken) async {
    try {
      debugPrint("🔄 REGENERATING TOKEN");

      final response =
      await AppointmentApiService.regenerateToken(oldToken: oldToken);

      return response.accessToken;
    } catch (e) {
      debugPrint("❌ TOKEN REFRESH FAILED → $e");
      await clearToken();
      throw Exception("Session expired. Please login again.");
    }
  }

  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = (payload['exp'] as int) * 1000;
      return DateTime.now().millisecondsSinceEpoch >= exp;
    } catch (e) {
      debugPrint("⚠️ JWT PARSE FAILED → $e");
      return true;
    }
  }

  /// 🚪 LOGOUT
  static Future<void> clearToken() async {
    _accessToken = null;
    _refreshingToken = null;
    await AppPreferences.logout();
    debugPrint("🚪 TOKEN CLEARED");
  }
}




