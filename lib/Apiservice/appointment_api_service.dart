import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/AddSessionRequest.dart';
import '../model/AddSessionResponsee.dart';
import '../model/BookSessionPackage.dart';
import '../model/ConcernModel.dart';
import '../model/CreatePaymentLinkRequest.dart';
import '../model/CreatePaymentLinkResponse.dart';
import '../model/DoctorModel.dart';
import '../model/DoctorPayment.dart';
import '../model/DoctorPaymentsResponse.dart';
import '../model/EnquiryRequest.dart';
import '../model/EnquiryResponse.dart';
import '../model/PaymentHistoryResponse.dart';
import '../model/appointment_request.dart';
import '../model/appointment_response.dart';
import '../utils/ApiConstants.dart';


  class AppointmentApiService {
  static Future<AppointmentResponseAdd> createAppointment(
      AppointmentRequest request) async {

    final response = await http.post(
      Uri.parse(ApiConstants.createAppointment),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return AppointmentResponseAdd.fromJson(json);
    } else {
      throw Exception("Failed to create appointment");
    }
  }

  static Future<List<ConcernModel>> getConcerns() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/concerns"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ConcernModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load concerns");
    }
  }
  static Future<EnquiryResponse> submitEnquiry(
      EnquiryRequest request,
      ) async {
    final url =
    Uri.parse("${ApiConstants.baseUrl}/appointments/enquiries");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return EnquiryResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Failed to submit enquiry");
    }
  }
  static const String baseUrl =
      "https://srv1090011.hstgr.cloud/api";

  static Future<List<SessionPackage>> getSessionsByConcern(
      String concern) async {
    final url =
    Uri.parse("$baseUrl/sessions?concern=$concern");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      final List list = body['sessions'];

      return list
          .map((e) => SessionPackage.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load session packages");
    }
  }
  static Future<bool> addSessionToAppointment({
    required String appointmentId,
    required String sessionId,
    required String assignedBy,
    String? notes,
  }) async {
    final url = Uri.parse(
      "$baseUrl/appointments/$appointmentId/add-session",
    );

    final body = {
      "sessionId": sessionId,
      "notes": notes ?? "",
      "assignedBy": assignedBy,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["success"] == true;
    } else {
      throw Exception("Failed to add session");
    }
  }
  static const String _baseUrl =
      "https://srv1090011.hstgr.cloud/api/payments";
  static Future<CreatePaymentLinkResponse> createPaymentLink(

      CreatePaymentLinkRequest request) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/create-link"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreatePaymentLinkResponse.fromJson(
          jsonDecode(response.body));
    } else {
      throw Exception("Failed to create payment link");
    }
  }

  static const _baseUrl1 =
      "https://srv1090011.hstgr.cloud/api/add_sessions";

  static Future<List<DoctorPayment>> getDoctorPayments({
    required String doctorId,
    required String username,
  }) async {

    final url = Uri.parse("$_baseUrl1/fetch_paidsessions_simple");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "doctorId": doctorId,
        "username": username,
      }),
    );

    debugPrint("📥 Status Code: ${response.statusCode}");
    debugPrint("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      /// ✅ SAFE EXTRACTION
      final List list = decoded['sessions'] ?? [];

      /// ✅ SAFE MAPPING
      return list
          .map((e) => DoctorPayment.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load payments");
    }
  }



  static const String _baseUrlpayhistory =
      "https://srv1090011.hstgr.cloud/api/payments";

  static Future<PaymentHistoryResponse>
  getDoctorPaymentHistory({
    required String doctorId,
    required String username,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrlpayhistory/doctor"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "doctorId": doctorId,
        "username": username,
      }),
    );

    if (response.statusCode == 200) {
      return PaymentHistoryResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
          "Failed to load payment history");
    }
  }


  static const String baseUrltrsn =
      "https://srv1090011.hstgr.cloud/api";

  /// 🔹 FETCH CLINICS (REAL API)
  static Future<List<Map<String, String>>> fetchClinics() async {
    final url =
    Uri.parse("https://srv1090011.hstgr.cloud/api/clinics");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];

      return data.map<Map<String, String>>((c) {
        return {
          "id": c["_id"]?.toString() ?? "",
          "name": c["clinicName"]?.toString() ?? "",
          "address": c["address"]?.toString() ?? "",
          "pincode": c["pincode"]?.toString() ?? "",
          "state": c["state"]?.toString() ?? "",
        };
      }).toList();
    } else {
      throw Exception("Failed to load clinics");
    }
  }


  /// 🔹 TRANSFER API
  static Future<bool> transferToClinic({
    required String appointmentId,
    required String clinicId,
    required String clinicName,
    required Map<String, dynamic> patientData,
    required String treatment,
    required String transferNotes,
  }) async {
    final url =
    Uri.parse("$baseUrltrsn/appointments/transfer-to-clinic");

    final now = DateTime.now();
    final treatmentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final body = {
      "appointmentId": appointmentId,
      "clinicId": clinicId,
      "clinicName": clinicName,
      "patientData": patientData,
      "notes": "",
      "treatment": treatment,
      "treatmentDate": now.toIso8601String().split("T").first,
      "treatmentTime": treatmentTime,
      "transferNotes": transferNotes,
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return res.statusCode == 200 &&
        jsonDecode(res.body)['success'] == true;
  }
  // 🔹 FETCH AVAILABLE DOCTORS
  static const String _baseUrltrans =
      "https://srv1090011.hstgr.cloud/api";

  /// 🔹 GET AVAILABLE DOCTORS
  static Future<List<Map<String, String>>> fetchAvailableDoctors() async {
    final response = await http.get(
      Uri.parse("$_baseUrltrans/add_sessions/available_doctors"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      /// ✅ CORRECT KEY
      final List list = decoded['doctors'] ?? [];

      return list.map<Map<String, String>>((d) {
        return {
          "id": d["_id"]?.toString() ?? "",
          "name": d["username"]?.toString() ?? "",
          "type": d["type"]?.toString() ?? "",
          "mobile": d["mobile_no"]?.toString() ?? "",
        };
      }).toList();
    } else {
      throw Exception("Failed to load doctors");
    }
  }


  /// 🔹 TRANSFER TO DOCTOR
  static Future<bool> transferToDoctor({
    required String appointmentId,
    required String doctorId,
    String clinicName = "",
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrltrans/appointments/transfer-to-doctor"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "appointmentId": appointmentId,
        "doctorId": doctorId,
        "clinicName": clinicName,
      }),
    );

    return response.statusCode == 200 &&
        jsonDecode(response.body)['success'] == true;
  }

  static const String _baseUrlsess =
      "https://srv1090011.hstgr.cloud/api/add_sessions/create";

  static Future<AddSessionResponsee> addSession(
      AddSessionRequest request) async {
    final response = await http.post(
      Uri.parse(_baseUrlsess),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AddSessionResponsee.fromJson(data);
    } else {
      throw Exception(data["message"] ?? "Failed to add session");
    }
  }
}
