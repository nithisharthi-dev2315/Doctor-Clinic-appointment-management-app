import 'Appointment.dart';

class AppointmentResponse {
  final bool success;
  final List<Appointment> appointments;

  AppointmentResponse({
    required this.success,
    required this.appointments,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      success: json['success'],
      appointments: (json['appointments'] as List)
          .map((e) => Appointment.fromJson(e))
          .toList(),
    );
  }
}
