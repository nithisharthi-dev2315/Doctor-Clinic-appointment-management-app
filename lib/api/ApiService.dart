import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Appointment.dart';
import 'AppointmentResponse.dart';

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


}
