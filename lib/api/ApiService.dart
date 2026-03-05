import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../Preferences/AppPreferences.dart';
import '../TokenManager.dart';
import '../model/ClinicPatientResponse.dart';
import 'Appointment.dart';
import 'AppointmentResponse.dart';
import 'login_response.dart';

class ApiService {
  static const String baseUrl =
      "https://srv1090011.hstgr.cloud/api";

  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = Uri.parse("$baseUrl$endpoint");

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  static Future<List<Appointment>> getDoctorAppointments(
      String doctorId) async {
    final response = await ApiService.post(
      "/appointments/doctor",
      {"doctorId": doctorId},
    );

    if (response.statusCode == 200) {
      final data = AppointmentResponse.fromJson(
        jsonDecode(response.body),
      );
      return data.appointments;
    } else {
      throw Exception("Failed to load appointments");
    }
  }

  static Future<ClinicLoginResponse> clinicLogin(
      String username,
      String password,
      ) async
  {
    final response = await ApiService.post(
      "/clinics/auth/login",
      {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return ClinicLoginResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Clinic login failed");
    }
  }
  static const String getPatientBaseUrl = "https://srv1090011.hstgr.cloud/api/clinics/patients";

  static Future<List<ClinicPatient>> getClinicPatients(String clinicId) async {
    final url = Uri.parse("$getPatientBaseUrl/public/$clinicId");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    debugPrint("URL: $url");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      /// ✅ API success flag
      final bool success = jsonData['success'] ?? false;
      if (!success) {
        throw Exception("API returned success=false");
      }

      /// ✅ CORRECT KEY
      final List list = jsonData['data'] ?? [];
      debugPrint("PATIENT COUNT: ${list.length}");

      return list.map((e) {
        debugPrint("PATIENT ITEM: $e");
        return ClinicPatient.fromJson(e);
      }).toList();
    } else {
      throw Exception("Failed to load clinic patients");
    }
  }


  static Future<bool> transferPatient({
    required String patientId,
    required String toClinicId,
    required String concernId,
    String notes = "",
  }) async {
    final url = Uri.parse(
      "https://srv1090011.hstgr.cloud/api/clinics/patients/$patientId/transfer",
    );

    final token = await AppPreferences.getAccessToken();

    print('token===========${token}');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "toClinic": toClinicId,
        "concernId": concernId,
        "notes": notes,
      }),
    );

    final data = json.decode(response.body);

    debugPrint("TRANSFER RESPONSE → $data");

    return response.statusCode == 200 && data['success'] == true;
  }

  static const String fcm_url =
      "https://srv1090011.hstgr.cloud/api/notifications/update";

  static Future<void> saveFcmToken({
    required String userId,
    required String role,
    required String token,
    String deviceType = "android",
    String? clinicId,
  })
  async {
    try {
      final response = await http.post(
        Uri.parse(fcm_url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "role": role,
          "token": token,
          "deviceType": deviceType,
          "clinicId": clinicId,
        }),
      );

      debugPrint("🔹 FCM API Status: ${response.statusCode}");
      debugPrint("🔹 FCM API Response: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ FCM token saved successfully");
      } else {
        debugPrint("❌ Failed to save FCM token");
      }
    } catch (e) {
      debugPrint("❌ FCM API Error: $e");
    }
  }
  static Future<String?> summarizeChiefComplaint(String roomName) async {
    try {
      final response = await http.post(
        Uri.parse("https://srv1090011.hstgr.cloud/api/video/summarize"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "roomName": roomName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          String summary = data["summary"] ?? "";

          print('summary=========== $summary');

          // ✅ RETURN FULL SUMMARY (NO REGEX)
          return summary.trim();
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
  static Future<String?> summarizeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse("https://srv1090011.hstgr.cloud/api/ai/summarize-text"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "text": text,
        }),
      );
      print('text=========${text}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          return (data["summary"] ?? "").toString().trim();
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

}
