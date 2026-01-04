class AppointmentResponseAdd {
  final String message;
  final AppointmentData appointment;
  final bool whatsAppOptIn;
  final bool doctorResolved;

  AppointmentResponseAdd({
    required this.message,
    required this.appointment,
    required this.whatsAppOptIn,
    required this.doctorResolved,
  });

  factory AppointmentResponseAdd.fromJson(Map<String, dynamic> json) {
    return AppointmentResponseAdd(
      message: json["message"] ?? "",
      appointment: AppointmentData.fromJson(json["appointment"] ?? {}),
      whatsAppOptIn: json["whatsAppOptIn"] ?? false,
      doctorResolved: json["doctorResolved"] ?? false,
    );
  }
}


class AppointmentData {
  final String id;
  final String name;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? videoLinkPatient;
  final String? videoLinkDoctor;

  AppointmentData({
    required this.id,
    required this.name,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.videoLinkPatient,
    this.videoLinkDoctor,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      id: json["_id"],
      name: json["name"],
      appointmentDate: json["appointment_date"],
      appointmentTime: json["appointment_time"],
      status: json["status"],
      videoLinkPatient: json["twilioRoomPatient"]?["link"],
      videoLinkDoctor: json["twilioRoomDoctor"]?["link"],
    );
  }
}
