// ======================= DOCTOR PAYMENT =======================
import 'ConsentForm Model.dart';
import 'Invoice Model.dart';

class DoctorPaymentResponse {
  final bool success;
  final int count;
  final List<DoctorPayment> sessions;

  DoctorPaymentResponse({
    required this.success,
    required this.count,
    required this.sessions,
  });

  factory DoctorPaymentResponse.fromJson(Map<String, dynamic> json) {
    return DoctorPaymentResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => DoctorPayment.fromJson(e))
          .toList(),
    );
  }
}

class DoctorPayment {
  final String id;
  final String appointmentId;
  final String session;
  final DoctorAssigned doctorAssigned;
  final PackageSnapshot packageSnapshot;
  final List<SessionSlot> sessions;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Customer customer;
  final Appointment appointment;
  final CreatedByDoctor createdByDoctor;

  // 🔥 ADD THESE
  final ConsentForm consentForm;
  final Invoice invoice;

  DoctorPayment({
    required this.id,
    required this.appointmentId,
    required this.session,
    required this.doctorAssigned,
    required this.packageSnapshot,
    required this.sessions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.appointment,
    required this.createdByDoctor,

    // 🔥 ADD THESE
    required this.consentForm,
    required this.invoice,
  });


  factory DoctorPayment.fromJson(Map<String, dynamic> json) {
    return DoctorPayment(
      id: json['_id'],
      appointmentId: json['appointmentId'],
      session: json['session'],
      doctorAssigned: DoctorAssigned.fromJson(json['doctorAssigned'] ?? {}),
      packageSnapshot: PackageSnapshot.fromJson(json['package_snapshot'] ?? {}),
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => SessionSlot.fromJson(e))
          .toList(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      customer: Customer.fromJson(json['customer'] ?? {}),
      appointment: Appointment.fromJson(json['appointment'] ?? {}),
      createdByDoctor:
      CreatedByDoctor.fromJson(json['createdByDoctor'] ?? {}),

      // ✅ NOW VALID
      consentForm: ConsentForm.fromJson(json['consentForm']),
      invoice: Invoice.fromJson(json['invoice']),
    );
  }

}

// ======================= DOCTOR ASSIGNED =======================

class DoctorAssigned {
  final String username;
  final String name;

  DoctorAssigned({
    required this.username,
    required this.name,
  });

  factory DoctorAssigned.fromJson(Map<String, dynamic> json) {
    return DoctorAssigned(
      username: json['username'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

// ======================= PACKAGE SNAPSHOT =======================

class PackageSnapshot {
  final String packageName;
  final int sessionsCount;
  final int? durationWeeks;
  final String concern;

  PackageSnapshot({
    required this.packageName,
    required this.sessionsCount,
    this.durationWeeks,
    required this.concern,
  });

  factory PackageSnapshot.fromJson(Map<String, dynamic> json) {
    return PackageSnapshot(
      packageName: json['package_name'],
      sessionsCount: json['sessions_count'],
      durationWeeks: json['duration_weeks'],
      concern: json['concern'],
    );
  }
}

// ======================= SESSION SLOT =======================

class SessionSlot {
  final int index;
  final String date;
  final String time;
  final DateTime scheduledAt;
  final bool sendReminder;

  final String? treatment;
  final String? sessionHandled;
  final String? sessionHandledDisplay;


  final String? chiefComplaints;
  final String? enquiryNotes;
  final String? enquiryUpdatedBy;
  final DateTime? enquiryUpdatedAt;

  final TwilioRoom? patientRoom;
  final TwilioRoom? doctorRoom;

  SessionSlot({
    required this.index,
    required this.date,
    required this.time,
    required this.scheduledAt,
    required this.sendReminder,
    this.treatment,
    this.sessionHandled,
    this.sessionHandledDisplay,
    this.chiefComplaints,
    this.enquiryNotes,
    this.enquiryUpdatedBy,
    this.enquiryUpdatedAt,
    this.patientRoom,
    this.doctorRoom,
  });
  /// ✅ SINGLE SOURCE OF TRUTH
  DateTime get scheduledDateTime {
    try {
      final dateParts = date.split('-'); // yyyy-MM-dd
      final timeParts = time.split(':'); // HH:mm

      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {
      // fallback if parsing fails
      return scheduledAt;
    }
  }

  factory SessionSlot.fromJson(Map<String, dynamic> json) {
    return SessionSlot(
      index: json['index'],
      date: json['date'],
      time: json['time'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      sendReminder: json['sendReminder'] ?? false,
      treatment: json['treatment'],
      sessionHandled: json['session_handled'],
      sessionHandledDisplay: json['session_handled_display'],
      chiefComplaints: json['chiefComplaints'],
      enquiryNotes: json['enquiryNotes'],
      enquiryUpdatedBy: json['enquiryUpdatedBy'],
      enquiryUpdatedAt: json['enquiryUpdatedAt'] != null
          ? DateTime.parse(json['enquiryUpdatedAt'])
          : null,
      patientRoom:
      TwilioRoom.fromJson(json['twilioRoomPatient']),
      doctorRoom:
      TwilioRoom.fromJson(json['twilioRoomDoctor']),
    );


  }

  /// ✅ IMMUTABLE UPDATE
  SessionSlot copyWith({
    String? treatment,
    String? sessionHandled,
    String? sessionHandledDisplay,
    String? chiefComplaints,
    String? enquiryNotes,
    String? enquiryUpdatedBy,
    DateTime? enquiryUpdatedAt,
    TwilioRoom? patientRoom,
    TwilioRoom? doctorRoom,
  }) {
    return SessionSlot(
      index: index,
      date: date,
      time: time,
      scheduledAt: scheduledAt,
      sendReminder: sendReminder,
      treatment: treatment ?? this.treatment,
      sessionHandled: sessionHandled ?? this.sessionHandled,
      sessionHandledDisplay:
      sessionHandledDisplay ?? this.sessionHandledDisplay,
      chiefComplaints:
      chiefComplaints ?? this.chiefComplaints,
      enquiryNotes: enquiryNotes ?? this.enquiryNotes,
      enquiryUpdatedBy:
      enquiryUpdatedBy ?? this.enquiryUpdatedBy,
      enquiryUpdatedAt:
      enquiryUpdatedAt ?? this.enquiryUpdatedAt,
      patientRoom: patientRoom ?? this.patientRoom,
      doctorRoom: doctorRoom ?? this.doctorRoom,
    );
  }
}

// ======================= TWILIO ROOM =======================

class TwilioRoom {
  final String? roomName;
  final String? roomSid;
  final String? link;
  final DateTime? createdAt;

  TwilioRoom({
    this.roomName,
    this.roomSid,
    this.link,
    this.createdAt,
  });

  factory TwilioRoom.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return TwilioRoom();
    }

    return TwilioRoom(
      roomName: json['roomName'],
      roomSid: json['roomSid'],
      link: json['link'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

// ======================= CUSTOMER =======================

class Customer {
  final String name;
  final String contact;
  final String email;

  Customer({
    required this.name,
    required this.contact,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
    );
  }
}

// ======================= APPOINTMENT =======================

class Appointment {
  final String id;
  final String name;
  final String phone;
  final String email;

  Appointment({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

// ======================= CREATED BY DOCTOR =======================

class CreatedByDoctor {
  final String username;
  final String name;

  CreatedByDoctor({
    required this.username,
    required this.name,
  });

  factory CreatedByDoctor.fromJson(Map<String, dynamic> json) {
    return CreatedByDoctor(
      username: json['username'],
      name: json['name'],
    );
  }
}
