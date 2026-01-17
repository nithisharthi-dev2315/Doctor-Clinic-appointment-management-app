class ClinicPatientResponse {
  final bool success;
  final String message;
  final String patientId;
  final ClinicPatient patient;

  ClinicPatientResponse({
    required this.success,
    required this.message,
    required this.patientId,
    required this.patient,
  });

  factory ClinicPatientResponse.fromJson(Map<String, dynamic> json) {
    return ClinicPatientResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      patientId: json['patientId'] ?? '',
      patient: ClinicPatient.fromJson(json['patient'] ?? {}),
    );
  }
}
class ClinicPatient {
  final String id;
  final String? clinic;
  final String? clinicName;
  final String name;
  final String mobile;
  final int? age;
  final String? email;
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? notes;
  final String? primaryConcern;
  final String treatment;
  final DateTime? treatmentDate;
  final String treatmentTime;
  final String? transferredTo;
  final dynamic invoice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClinicPatient({
    required this.id,
    this.clinic,
    this.clinicName,
    required this.name,
    required this.mobile,
    this.age,
    this.email,
    this.dob,
    this.gender,
    this.address,
    this.notes,
    this.primaryConcern,
    required this.treatment,
    this.treatmentDate,
    required this.treatmentTime,
    this.transferredTo,
    this.invoice,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClinicPatient.fromJson(Map<String, dynamic> json) {
    return ClinicPatient(
      id: json['_id'] ?? '',
      clinic: json['clinic'],
      clinicName: json['clinic_name'],
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      age: json['age'],
      email: json['email'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      gender: json['gender'],
      address: json['address'],
      notes: json['notes'],
      primaryConcern: json['primaryConcern'],
      treatment: json['treatment'] ?? '',
      treatmentDate: json['treatmentDate'] != null
          ? DateTime.parse(json['treatmentDate']).toLocal()
          : null,
      treatmentTime: json['treatmentTime'] ?? '',
      transferredTo: json['transferredTo'],
      invoice: json['invoice'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

// =====================
// REQUEST MODEL
// =====================
class ClinicPatientRequest {
  final String name;
  final String mobile;
  final int age;
  final String email;
  final String gender;
  final String treatment;
  final String treatmentDate; // yyyy-MM-dd
  final String treatmentTime; // HH:mm
  final String address;
  final String? notes;

  ClinicPatientRequest({
    required this.name,
    required this.mobile,
    required this.age,
    required this.email,
    required this.gender,
    required this.treatment,
    required this.treatmentDate,
    required this.treatmentTime,
    required this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "age": age,
      "email": email,
      "gender": gender,
      "treatment": treatment,
      "treatmentDate": treatmentDate,
      "treatmentTime": treatmentTime,
      "address": address,
      "notes": notes,
    };
  }
}