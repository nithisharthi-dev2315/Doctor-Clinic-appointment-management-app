class ScheduleSessionResponse {
  final bool success;
  final String message;
  final AddSession addSession;

  ScheduleSessionResponse({
    required this.success,
    required this.message,
    required this.addSession,
  });

  factory ScheduleSessionResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleSessionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      addSession: AddSession.fromJson(json['addSession']),
    );
  }
}
class AddSession {
  final String appointmentId;
  final String session;
  final String doctorAssigned;
  final PackageSnapshot packageSnapshot;
  final List<SessionItem> sessions;
  final String createdBy;
  final String notes;
  final String status;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddSession({
    required this.appointmentId,
    required this.session,
    required this.doctorAssigned,
    required this.packageSnapshot,
    required this.sessions,
    required this.createdBy,
    required this.notes,
    required this.status,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddSession.fromJson(Map<String, dynamic> json) {
    return AddSession(
      appointmentId: json['appointmentId'],
      session: json['session'],
      doctorAssigned: json['doctorAssigned'],
      packageSnapshot:
      PackageSnapshot.fromJson(json['package_snapshot']),
      sessions: (json['sessions'] as List)
          .map((e) => SessionItem.fromJson(e))
          .toList(),
      createdBy: json['createdBy'],
      notes: json['notes'] ?? '',
      status: json['status'],
      id: json['_id'],
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
class SessionItem {
  final int index;
  final String date;
  final String time;
  final DateTime scheduledAt;
  final bool sendReminder;
  final bool sessionNotificationSent;
  final Reschedule reschedule;

  SessionItem({
    required this.index,
    required this.date,
    required this.time,
    required this.scheduledAt,
    required this.sendReminder,
    required this.sessionNotificationSent,
    required this.reschedule,
  });

  factory SessionItem.fromJson(Map<String, dynamic> json) {
    return SessionItem(
      index: json['index'],
      date: json['date'],
      time: json['time'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      sendReminder: json['sendReminder'] ?? false,
      sessionNotificationSent:
      json['sessionNotificationSent'] ?? false,
      reschedule: Reschedule.fromJson(json['reschedule']),
    );
  }
}
class Reschedule {
  final String status;
  final String? reason;

  Reschedule({
    required this.status,
    this.reason,
  });

  factory Reschedule.fromJson(Map<String, dynamic> json) {
    return Reschedule(
      status: json['status'],
      reason: json['reason'],
    );
  }
}
