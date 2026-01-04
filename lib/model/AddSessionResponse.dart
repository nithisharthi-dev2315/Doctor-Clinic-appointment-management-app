class AddSessionResponse {
  final bool success;
  final String message;
  final AppointmentAfterSession appointment;

  AddSessionResponse({
    required this.success,
    required this.message,
    required this.appointment,
  });

  factory AddSessionResponse.fromJson(Map<String, dynamic> json) {
    return AddSessionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      appointment:
      AppointmentAfterSession.fromJson(json['appointment']),
    );
  }
}
class AppointmentAfterSession {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;

  final String primaryConcern;
  final String appointmentDate;
  final String appointmentTime;
  final String cdate;
  final String ctime;

  final bool reminder30PatientSent;
  final bool reminder30DoctorSent;

  final String language;
  final String? couponCode;
  final bool whatsAppOptIn;
  final bool whatsAppOptOut;

  final String status;
  final String doctorAssigned;
  final DateTime confirmedAt;

  final String? chiefComplaint;
  final String? enquiryNotes;

  final String? transferredFrom;
  final String? transferredTo;
  final String? sourcePatientId;
  final String? transferNotes;
  final DateTime? transferredAt;

  final TwilioRoomBasic? twilioRoom;
  final TwilioRoomWithLink? twilioRoomPatient;
  final TwilioRoomWithLink? twilioRoomDoctor;

  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentAfterSession({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.primaryConcern,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.cdate,
    required this.ctime,
    required this.reminder30PatientSent,
    required this.reminder30DoctorSent,
    required this.language,
    required this.couponCode,
    required this.whatsAppOptIn,
    required this.whatsAppOptOut,
    required this.status,
    required this.doctorAssigned,
    required this.confirmedAt,
    required this.chiefComplaint,
    required this.enquiryNotes,
    required this.transferredFrom,
    required this.transferredTo,
    required this.sourcePatientId,
    required this.transferNotes,
    required this.transferredAt,
    required this.twilioRoom,
    required this.twilioRoomPatient,
    required this.twilioRoomDoctor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentAfterSession.fromJson(Map<String, dynamic> json) {
    return AppointmentAfterSession(
      id: json['_id'],
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',

      primaryConcern: json['primaryConcern'] ?? '',
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      cdate: json['cdate'] ?? '',
      ctime: json['ctime'] ?? '',

      reminder30PatientSent:
      json['reminder30PatientSent'] ?? false,
      reminder30DoctorSent:
      json['reminder30DoctorSent'] ?? false,

      language: json['language'] ?? '',
      couponCode: json['couponCode'],
      whatsAppOptIn: json['whatsAppOptIn'] ?? false,
      whatsAppOptOut: json['whatsAppOptOut'] ?? false,

      status: json['status'] ?? '',
      doctorAssigned: json['doctorAssigned'] ?? '',
      confirmedAt: DateTime.parse(json['confirmedAt']),

      chiefComplaint: json['chiefComplaint'],
      enquiryNotes: json['enquiryNotes'],

      transferredFrom: json['transferredFrom'],
      transferredTo: json['transferredTo'],
      sourcePatientId: json['sourcePatientId'],
      transferNotes: json['transferNotes'],
      transferredAt: json['transferredAt'] != null
          ? DateTime.parse(json['transferredAt'])
          : null,

      twilioRoom: json['twilioRoom'] != null
          ? TwilioRoomBasic.fromJson(json['twilioRoom'])
          : null,

      twilioRoomPatient: json['twilioRoomPatient'] != null
          ? TwilioRoomWithLink.fromJson(
          json['twilioRoomPatient'])
          : null,

      twilioRoomDoctor: json['twilioRoomDoctor'] != null
          ? TwilioRoomWithLink.fromJson(
          json['twilioRoomDoctor'])
          : null,

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
class TwilioRoomBasic {
  final String roomName;
  final String roomSid;
  final DateTime createdAt;

  TwilioRoomBasic({
    required this.roomName,
    required this.roomSid,
    required this.createdAt,
  });

  factory TwilioRoomBasic.fromJson(Map<String, dynamic> json) {
    return TwilioRoomBasic(
      roomName: json['roomName'],
      roomSid: json['roomSid'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TwilioRoomWithLink {
  final String roomName;
  final String roomSid;
  final String link;
  final DateTime createdAt;

  TwilioRoomWithLink({
    required this.roomName,
    required this.roomSid,
    required this.link,
    required this.createdAt,
  });

  factory TwilioRoomWithLink.fromJson(Map<String, dynamic> json) {
    return TwilioRoomWithLink(
      roomName: json['roomName'],
      roomSid: json['roomSid'],
      link: json['link'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
