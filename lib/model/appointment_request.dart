class AppointmentRequest {
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String primaryConcern;
  final String date; // yyyy-MM-dd
  final String time; // 10:30 AM
  final bool whatsAppOptIn;
  final String language;
  final String? couponCode;
  final String doctorId;
  final String doctorUsername;

  AppointmentRequest({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.primaryConcern,
    required this.date,
    required this.time,
    required this.whatsAppOptIn,
    required this.language,
    this.couponCode,
    required this.doctorId,
    required this.doctorUsername,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "gender": gender,
      "phone": phone,
      "email": email,
      "primaryConcern": primaryConcern,
      "date": date,
      "time": time,
      "whatsAppOptIn": whatsAppOptIn,
      "language": language,
      "couponCode": couponCode ?? "",
      "doctorId": doctorId,
      "doctorUsername": doctorUsername,
    };
  }
}
