import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenManager {
  FcmTokenManager._();

  /// Call this ONCE after Firebase.initializeApp()
  static void init() {
    // ✅ MOST IMPORTANT: Listen for token creation & refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint("✅ FCM TOKEN GENERATED / REFRESHED:");
      debugPrint(token);

      // TODO: Send token to backend API
      // ApiService.saveFcmToken(token);
    });

    // 🔹 Optional: Try to get token once (non-blocking)
    _tryGetInitialToken();
  }

  /// Optional manual attempt (safe)
  static Future<void> _tryGetInitialToken() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint("🔹 Initial FCM Token:");
        debugPrint(token);
      } else {
        debugPrint("⚠️ Token not ready yet (Firebase will retry)");
      }
    } catch (e) {
      debugPrint("⚠️ FCM getToken failed (safe): $e");
    }
  }
}
