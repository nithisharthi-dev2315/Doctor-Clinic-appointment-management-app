import 'DoctorPayment.dart';

class DoctorPaymentsResponse {
  final bool success;
  final int count;
  final List<DoctorPayment> payments;

  DoctorPaymentsResponse({
    required this.success,
    required this.count,
    required this.payments,
  });

  factory DoctorPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return DoctorPaymentsResponse(
      success: json['success'],
      count: json['count'],
      payments: (json['payments'] as List)
          .map((e) => DoctorPayment.fromJson(e))
          .toList(),
    );
  }
}
