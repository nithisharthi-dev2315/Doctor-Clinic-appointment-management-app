import 'invoice_model.dart';

class PatientInvoiceItem {
  final String id;
  final String name;
  final String mobile;
  final String treatment;
  final DateTime treatmentDate;
  final String treatmentTime;
  final InvoiceData? invoice;
  final DateTime createdAt;

  PatientInvoiceItem({
    required this.id,
    required this.name,
    required this.mobile,
    required this.treatment,
    required this.treatmentDate,
    required this.treatmentTime,
    required this.invoice,
    required this.createdAt,
  });

  factory PatientInvoiceItem.fromJson(Map<String, dynamic> json) {
    return PatientInvoiceItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      treatment: json['treatment'] ?? '',
      treatmentDate: DateTime.parse(json['treatmentDate']),
      treatmentTime: json['treatmentTime'] ?? '',
      invoice: json['invoice'] != null && json['invoice'] is Map<String, dynamic>
          ? InvoiceData.fromJson(json['invoice'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

