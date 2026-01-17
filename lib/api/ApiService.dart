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
      ) async {
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



}
