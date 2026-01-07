class CreateRoomResponse {
  final bool success;
  final String message;
  final Room room;
  final Session session;

  CreateRoomResponse({
    required this.success,
    required this.message,
    required this.room,
    required this.session,
  });

  factory CreateRoomResponse.fromJson(Map<String, dynamic> json) {
    final sessionJson = json['addSession']['sessions'][0];

    return CreateRoomResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      room: Room.fromJson(json['room'] ?? {}),
      session: Session.fromJson(sessionJson ?? {}),
    );
  }
}

class Room {
  final String? roomName;
  final String? roomSid;
  final String? patientLink;
  final String? doctorLink;

  Room({
    this.roomName,
    this.roomSid,
    this.patientLink,
    this.doctorLink,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomName: json['roomName'],
      roomSid: json['roomSid'],
      patientLink: json['link'],
      doctorLink: json['doctorLink'], // if available
    );
  }
}

class Session {
  final String? roomName;
  final String? patientLink;
  final String? doctorLink;
  final String? handledBy;
  final String? treatment;

  Session({
    this.roomName,
    this.patientLink,
    this.doctorLink,
    this.handledBy,
    this.treatment,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final patientRoom = json['twilioRoomPatient'] ?? {};
    final doctorRoom = json['twilioRoomDoctor'] ?? {};

    return Session(
      roomName: patientRoom['roomName'],
      patientLink: patientRoom['link'],
      doctorLink: doctorRoom['link'],
      handledBy: json['session_handled_display'],
      treatment: json['treatment'],
    );
  }
}

