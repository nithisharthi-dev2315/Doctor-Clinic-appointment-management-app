import 'dart:convert';

class ApiConstants {
  static const String baseUrl =
      "https://srv1090011.hstgr.cloud/api";

  static const String createAppointment =
      "$baseUrl/appointments";

  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'];
      if (exp == null) return true;

      final expiryDate =
      DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return true;
    }
  }
}
