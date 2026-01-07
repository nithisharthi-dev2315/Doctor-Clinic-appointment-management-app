class UpdateEnquiryResponse {
  final bool success;
  final String message;
  final AddSession addSession;

  UpdateEnquiryResponse({
    required this.success,
    required this.message,
    required this.addSession,
  });

  factory UpdateEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return UpdateEnquiryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      addSession: AddSession.fromJson(json['addSession']),
    );
  }
}
class AddSession {
  final String id;
  final String appointmentId;
  final String session;
  final String doctorAssigned;
  final PackageSnapshot packageSnapshot;
  final List<SessionItem> sessions;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddSession({
    required this.id,
    required this.appointmentId,
    required this.session,
    required this.doctorAssigned,
    required this.packageSnapshot,
    required this.sessions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddSession.fromJson(Map<String, dynamic> json) {
    return AddSession(
      id: json['_id'],
      appointmentId: json['appointmentId'],
      session: json['session'],
      doctorAssigned: json['doctorAssigned'],
      packageSnapshot:
      PackageSnapshot.fromJson(json['package_snapshot']),
      sessions: (json['sessions'] as List)
          .map((e) => SessionItem.fromJson(e))
          .toList(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
class PackageSnapshot {
  final String packageName;
  final int sessionsCount;
  final int durationWeeks;
  final String concern;

  PackageSnapshot({
    required this.packageName,
    required this.sessionsCount,
    required this.durationWeeks,
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
class TwilioRoom {
  final String roomName;
  final String roomSid;
  final String link;
  final DateTime createdAt;

  TwilioRoom({
    required this.roomName,
    required this.roomSid,
    required this.link,
    required this.createdAt,
  });

  factory TwilioRoom.fromJson(Map<String, dynamic> json) {
    return TwilioRoom(
      roomName: json['roomName'],
      roomSid: json['roomSid'],
      link: json['link'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
class SessionItem {
  final int index;
  final String date;
  final String time;
  final DateTime scheduledAt;
  final String treatment;
  final String chiefComplaints;
  final String enquiryNotes;
  final String enquiryUpdatedBy;
  final DateTime enquiryUpdatedAt;
  final TwilioRoom twilioRoomPatient;
  final TwilioRoom twilioRoomDoctor;

  SessionItem({
    required this.index,
    required this.date,
    required this.time,
    required this.scheduledAt,
    required this.treatment,
    required this.chiefComplaints,
    required this.enquiryNotes,
    required this.enquiryUpdatedBy,
    required this.enquiryUpdatedAt,
    required this.twilioRoomPatient,
    required this.twilioRoomDoctor,
  });

  factory SessionItem.fromJson(Map<String, dynamic> json) {
    return SessionItem(
      index: json['index'],
      date: json['date'],
      time: json['time'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      treatment: json['treatment'],
      chiefComplaints: json['chiefComplaints'] ?? '',
      enquiryNotes: json['enquiryNotes'] ?? '',
      enquiryUpdatedBy: json['enquiryUpdatedBy'] ?? '',
      enquiryUpdatedAt:
      DateTime.parse(json['enquiryUpdatedAt']),
      twilioRoomPatient:
      TwilioRoom.fromJson(json['twilioRoomPatient']),
      twilioRoomDoctor:
      TwilioRoom.fromJson(json['twilioRoomDoctor']),
    );
  }
}
