class Appointment {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;

  final String? primaryConcern;
  final String appointmentDate;
  final String appointmentTime;

  final String status;
  final String language;

  final String? couponCode;
  final String? chiefComplaints;
  final String? notes;

  final String? videoLink;
  final String? twilioRoomName;

  final String? transferredTo;
  final String? transferredFrom;
  final String? transferredToName;
  final String? transferredFromName;

  final String doctorAssigned;
  final String doctorAssignedUsername;

  Appointment({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.primaryConcern,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.language,
    required this.couponCode,
    required this.chiefComplaints,
    required this.notes,
    required this.videoLink,
    required this.twilioRoomName,
    required this.transferredTo,
    required this.transferredFrom,
    required this.transferredToName,
    required this.transferredFromName,
    required this.doctorAssigned,
    required this.doctorAssignedUsername,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',

      primaryConcern: json['primaryConcern'],
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',

      status: json['status'] ?? 'pending',
      language: json['language'] ?? 'English',

      couponCode: json['couponCode'],
      chiefComplaints: json['chief_complaints'],
      notes: json['notes'],

      twilioRoomName: json['twilioRoomName'],
      videoLink: json['twilioRoomDoctor']?['link'],

      transferredTo: json['transferredTo'],
      transferredFrom: json['transferredFrom'],
      transferredToName: json['transferredToName'],
      transferredFromName: json['transferredFromName'],

      doctorAssigned: json['doctorAssigned'] ?? '',
      doctorAssignedUsername: json['doctorAssignedUsername'] ?? '',
    );
  }
}
