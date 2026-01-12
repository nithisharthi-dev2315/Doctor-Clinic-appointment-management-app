import 'dart:convert';
import 'package:http/http.dart' as http;

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



}
