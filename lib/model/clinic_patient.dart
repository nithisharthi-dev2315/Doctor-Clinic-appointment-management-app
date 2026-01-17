class ClinicPatient {
  final String id;
  final String name;
  final String mobile;
  final String treatment;
  final String treatmentDate;
  final String treatmentTime;
  final String? transferredTo;
  final Invoice? invoice;
  final String createdAt;

  ClinicPatient({
    required this.id,
    required this.name,
    required this.mobile,
    required this.treatment,
    required this.treatmentDate,
    required this.treatmentTime,
    this.transferredTo,
    this.invoice,
    required this.createdAt,
  });

  factory ClinicPatient.fromJson(Map<String, dynamic> json) {
    return ClinicPatient(
      id: json['_id'],
      name: json['name'],
      mobile: json['mobile'],
      treatment: json['treatment'],
      treatmentDate: json['treatmentDate'],
      treatmentTime: json['treatmentTime'],
      transferredTo: json['transferredTo'],
      invoice:
      json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null,
      createdAt: json['createdAt'],
    );
  }
}
class Invoice {
  final String url;
  final String driveId;
  final String filename;
  final int amount;
  final String currency;
  final String generatedByName;
  final String generatedAt;

  Invoice({
    required this.url,
    required this.driveId,
    required this.filename,
    required this.amount,
    required this.currency,
    required this.generatedByName,
    required this.generatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      url: json['url'],
      driveId: json['driveId'],
      filename: json['filename'],
      amount: json['amount'],
      currency: json['currency'],
      generatedByName: json['generatedByName'],
      generatedAt: json['generatedAt'],
    );
  }
}
