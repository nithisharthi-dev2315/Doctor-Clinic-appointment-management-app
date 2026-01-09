import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../SessionUpdateRequest.dart';
import '../model/AddSessionRequest.dart';
import '../model/AddSessionResponsee.dart';
import '../model/AvailableDoctor.dart';
import '../model/BookSessionPackage.dart';
import '../model/ConcernModel.dart';
import '../model/CreatePaymentLinkRequest.dart';
import '../model/CreatePaymentLinkResponse.dart';
import '../model/CreateRoomResponse.dart';
import '../model/DoctorModel.dart';
import '../model/DoctorPayment.dart';
import '../model/DoctorPaymentsResponse.dart';
import '../model/EnquiryRequest.dart';
import '../model/EnquiryResponse.dart';
import '../model/PaymentHistoryResponse.dart';
import '../model/UpdateEnquiryResponse.dart';
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

    debugPrint("📤 REQUEST URL: $url");
    debugPrint("📤 REQUEST BODY: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    /// 🔽 PRINT FULL RESPONSE
    debugPrint("📥 STATUS CODE: ${response.statusCode}");
    debugPrint("📥 HEADERS: ${response.headers}");
    debugPrint("📥 RAW BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      debugPrint("✅ PARSED JSON: $data");
      debugPrint("✅ SUCCESS FLAG: ${data["success"]}");

      return data["success"] == true;
    } else {
      debugPrint("❌ ERROR RESPONSE BODY: ${response.body}");
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

  static const getdocurl =
      "https://srv1090011.hstgr.cloud/api/add_sessions";

  static Future<DoctorPaymentResponse> getDoctorPayments({
    required String doctorId,
    required String username,
  }) async {
    final url = Uri.parse("$getdocurl/fetch_paidsessions_simple");

    final requestBody = {
      "doctorId": doctorId,
      "username": username,
    };

    debugPrint("📤 REQUEST URL: $url");
    debugPrint("📤 REQUEST BODY: ${jsonEncode(requestBody)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    debugPrint("📥 STATUS CODE: ${response.statusCode}");
    debugPrint("📥 RAW RESPONSE BODY:");
    debugPrint(response.body);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      debugPrint("🧩 FULL JSON STRUCTURE ↓↓↓");
      printJson(decoded);

      /// ✅ RETURN SINGLE RESPONSE OBJECT
      return DoctorPaymentResponse.fromJson(decoded);
    } else {
      debugPrint("❌ ERROR BODY: ${response.body}");
      throw Exception("Failed to load payments");
    }
  }


  static printJson(dynamic data, [String indent = ""]) {
    if (data is Map) {
      data.forEach((key, value) {
        debugPrint("$indent🔑 $key : ${value.runtimeType}");
        printJson(value, "$indent  ");
      });
    } else if (data is List) {
      for (int i = 0; i < data.length; i++) {
        debugPrint("$indent📦 [$i] : ${data[i].runtimeType}");
        printJson(data[i], "$indent  ");
      }
    } else {
      debugPrint("$indent➡ $data");
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
  static Future<List<AvailableDoctor>> fetchAvailableDoctors() async {
    final response = await http.get(
      Uri.parse("$_baseUrltrans/add_sessions/available_doctors"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List list = decoded['doctors'] ?? [];

      return list
          .map<AvailableDoctor>((d) => AvailableDoctor.fromJson(d))
          .toList();
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

  static Future<CreateRoomResponse> createSessionRoom({
    required String sessionObjectId,
    required int sessionIndex,
    required String handledDoctorId,
    required String treatment,
  }) async {
    final url = Uri.parse(
      "https://srv1090011.hstgr.cloud/api/add_sessions/"
          "$sessionObjectId/session/$sessionIndex/create_room",
    );

    debugPrint("📤 CREATE ROOM URL:");
    debugPrint(url.toString());

    final requestBody = {
      "doctorId": handledDoctorId,
      "treatmentType": treatment,
    };

    debugPrint("📤 CREATE ROOM BODY:");
    jsonEncode(requestBody).split('\n').forEach(debugPrint);

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    debugPrint("📥 STATUS CODE: ${res.statusCode}");

    /// 🔥 PRINT FULL RAW RESPONSE (NO TRUNCATION)
    debugPrint("📥 RAW RESPONSE BODY ↓↓↓");
    jsonDecode(res.body)
        .toString()
        .split(',')
        .forEach(debugPrint);

    if (res.statusCode == 200) {
      /// 🔥 PRETTY PRINT JSON
      debugPrint("📥 PRETTY RESPONSE JSON ↓↓↓");
      const encoder = JsonEncoder.withIndent('  ');
      encoder
          .convert(jsonDecode(res.body))
          .split('\n')
          .forEach(debugPrint);

      final parsed =
      CreateRoomResponse.fromJson(jsonDecode(res.body));

      debugPrint("🟢 PARSED CREATE ROOM RESPONSE");
      debugPrint("Success      : ${parsed.success}");
      debugPrint("Message      : ${parsed.message}");
      debugPrint("Room Name    : ${parsed.room.roomName}");
      debugPrint("Room SID     : ${parsed.room.roomSid}");
      debugPrint("Patient Link : ${parsed.room.patientLink}");
      debugPrint("Doctor Link  : ${parsed.session.doctorLink}");
      debugPrint("Handled By   : ${parsed.session.handledBy}");
      debugPrint("Treatment    : ${parsed.session.treatment}");
      debugPrint("════════════════════════════════");

      return parsed;
    } else {
      debugPrint("❌ CREATE ROOM FAILED");
      throw Exception("Create room failed");
    }
  }


  static const String editsession =
      "https://srv1090011.hstgr.cloud/api/add_sessions";

  /// UPDATE SESSIONS
  static Future<Map<String, dynamic>> updateSessions(
      SessionUpdateRequest request) async {

    /// 🔹 PRINT REQUEST
    debugPrint("===== UPDATE SESSIONS API REQUEST =====");
    debugPrint("URL  : $editsession/update");
    debugPrint("BODY : ${jsonEncode(request.toJson())}");
    debugPrint("=====================================");

    final response = await http.post(
      Uri.parse("$editsession/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    /// 🔹 PRINT RESPONSE
    debugPrint("===== UPDATE SESSIONS API RESPONSE =====");
    debugPrint("Status Code : ${response.statusCode}");
    debugPrint("Body        : ${response.body}");
    debugPrint("======================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Server error | ${response.statusCode} | ${response.body}",
      );
    }

    final body = jsonDecode(response.body);

    if (body["success"] != true) {
      throw Exception(body["message"] ?? "Update failed");
    }

    /// ✅ RETURN RESPONSE
    return body;
  }
  static Future<Map<String, dynamic>> updateEnquiry({
    required String addSessionId,
    required String sessionIndex,
    required String chiefComplaints,
    required String enquiryNotes,
    required String updatedBy,
  }) async {
    final url = Uri.parse(
      "https://srv1090011.hstgr.cloud/api/add_sessions/update-enquiry",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "addSessionId": addSessionId,
        "sessionIndex": sessionIndex,
        "chiefComplaints": chiefComplaints,
        "enquiryNotes": enquiryNotes,
        "updatedBy": updatedBy,
      }),
    );

    final data = jsonDecode(response.body);

    debugPrint("UpdateEnquiry Parsed Data: $data");

    if (response.statusCode == 200 && data["success"] == true) {
      return data; // ✅ JUST RETURN RAW MAP
    } else {
      throw Exception(data["message"] ?? "Failed to update enquiry");
    }
  }



  /// 🔹 SEND CONSENT API
  static Future<bool> sendConsentApi({
    required String appointmentId,
    required String doctorName,
    required String patientName,
    required String patientPhone,
    required String sessionId,
  }) async {
    final Uri url = Uri.parse(
      "https://srv1090011.hstgr.cloud/api/consent/send/$appointmentId",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "appointmentId": appointmentId,
        "doctorName": doctorName,
        "patientName": patientName,
        "patientPhone": patientPhone,
        "sessionId": sessionId,
      }),
    );

    final data = jsonDecode(response.body);

    return response.statusCode == 200 && data["success"] == true;
  }

  void prettyPrintJson(String jsonStr) {
    const encoder = JsonEncoder.withIndent('  ');
    final object = jsonDecode(jsonStr);
    final prettyString = encoder.convert(object);
    prettyString.split('\n').forEach(debugPrint);
  }


  }
