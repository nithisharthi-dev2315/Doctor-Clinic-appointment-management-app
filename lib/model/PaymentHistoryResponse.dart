

import 'PaymentHistoryItem.dart';

class PaymentHistoryResponse {
  final bool success;
  final int count;
  final List<PaymentHistoryItem> payments;

  PaymentHistoryResponse({
    required this.success,
    required this.count,
    required this.payments,
  });

  factory PaymentHistoryResponse.fromJson(
      Map<String, dynamic> json) {
    return PaymentHistoryResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      payments: (json['payments'] as List? ?? [])
          .map((e) => PaymentHistoryItem.fromJson(e))
          .toList(),
    );
  }
}
