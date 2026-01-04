class DoctorPayment {
  final String id;
  final String appointmentId;
  final String sessionId;
  final DoctorAssigned doctorAssigned;
  final PackageSnapshot packageSnapshot;
  final List<SessionSlot> sessions;
  final String status;
  final DateTime createdAt;
  final Customer customer;

  DoctorPayment({
    required this.id,
    required this.appointmentId,
    required this.sessionId,
    required this.doctorAssigned,
    required this.packageSnapshot,
    required this.sessions,
    required this.status,
    required this.createdAt,
    required this.customer,
  });

  factory DoctorPayment.fromJson(Map<String, dynamic> json) {
    return DoctorPayment(
      id: json['_id'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      sessionId: json['session'] ?? '',
      doctorAssigned:
      DoctorAssigned.fromJson(json['doctorAssigned'] ?? {}),
      packageSnapshot:
      PackageSnapshot.fromJson(json['package_snapshot'] ?? {}),

      /// ✅ CRASH FIX IS HERE
      sessions: (json['sessions'] as List?)
          ?.map((e) => SessionSlot.fromJson(e))
          .toList() ??
          [],

      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      customer: Customer.fromJson(json['customer'] ?? {}),
    );
  }
}

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
class PackageSnapshot {
  final String packageName;
  final int sessionsCount;
  final int? durationWeeks;
  final String concern;

  PackageSnapshot({
    required this.packageName,
    required this.sessionsCount,
    required this.durationWeeks,
    required this.concern,
  });

  factory PackageSnapshot.fromJson(Map<String, dynamic> json) {
    return PackageSnapshot(
      packageName: json['package_name'] ?? '',
      sessionsCount: json['sessions_count'] ?? 0,
      durationWeeks: json['duration_weeks'],
      concern: json['concern'] ?? '',
    );
  }
}
class SessionSlot {
  final int index;
  final String date;
  final String time;
  final DateTime scheduledAt;
  final bool sendReminder;

  SessionSlot({
    required this.index,
    required this.date,
    required this.time,
    required this.scheduledAt,
    required this.sendReminder,
  });

  factory SessionSlot.fromJson(Map<String, dynamic> json) {
    return SessionSlot(
      index: json['index'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      scheduledAt: DateTime.parse(json['scheduledAt']),
      sendReminder: json['sendReminder'] ?? false,
    );
  }
}
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
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
