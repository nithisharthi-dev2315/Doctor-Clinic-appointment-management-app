import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../api/ApiService.dart';

class FcmTokenManager {
  FcmTokenManager._();

  static void init({
    required String userId,
    required String role,
    String? clinicId,
  }) {
    /// 🔁 Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint("✅ FCM TOKEN REFRESHED:");
      debugPrint(token);

      if (token.isNotEmpty) {
        ApiService.saveFcmToken(
          userId: userId,
          role: role,
          token: token,
          clinicId: clinicId,
        );
      }
    });

    _tryGetInitialToken(userId, role, clinicId);
  }

  static Future<void> _tryGetInitialToken(
      String userId,
      String role,
      String? clinicId,
      ) async
  {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        debugPrint("🔹 Initial FCM Token:");
        debugPrint(token);

        await ApiService.saveFcmToken(
          userId: userId,
          role: role,
          token: token,
          clinicId: clinicId,
        );
      } else {
        debugPrint("⚠️ Token not ready yet");
      }
    } catch (e) {
      debugPrint("⚠️ FCM getToken failed: $e");
    }
  }
}
