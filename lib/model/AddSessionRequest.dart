class AddSessionRequest {
  final String appointmentId;
  final String doctorAssigned;
  final String sessionId;
  final String notes;
  final List<SessionItem> sessions;

  AddSessionRequest({
    required this.appointmentId,
    required this.doctorAssigned,
    required this.sessionId,
    this.notes = "",
    required this.sessions,
  });

  Map<String, dynamic> toJson() {
    return {
      "appointmentId": appointmentId,
      "doctorAssigned": doctorAssigned,
      "sessionId": sessionId,
      "notes": notes,
      "sessions": sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class SessionItem {
  final int index;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm

  SessionItem({
    required this.index,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "date": date,
      "time": time,
    };
  }
}
