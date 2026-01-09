import 'dart:convert';

/// ================= CREATE ROOM RESPONSE =================

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
    // sessions is a LIST → take latest session
    final List sessions = json['addSession']?['sessions'] ?? [];
    final Map<String, dynamic> latestSession =
    sessions.isNotEmpty ? sessions.last : {};

    return CreateRoomResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      room: Room.fromJson(json['room'] ?? {}),
      session: Session.fromJson(latestSession),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "room": room.toJson(),
      "session": session.toJson(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}

/// ================= ROOM =================

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
      patientLink: json['link'],        // patient link
      doctorLink: json['doctorLink'],   // if backend provides
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roomName": roomName,
      "roomSid": roomSid,
      "patientLink": patientLink,
      "doctorLink": doctorLink,
    };
  }
}

/// ================= SESSION =================

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

  Map<String, dynamic> toJson() {
    return {
      "roomName": roomName,
      "patientLink": patientLink,
      "doctorLink": doctorLink,
      "handledBy": handledBy,
      "treatment": treatment,
    };
  }
}
