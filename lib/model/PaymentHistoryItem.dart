import 'PaymentHistoryCustomer.dart';
import 'PaymentHistorySession.dart';

class PaymentHistoryItem {
  final String id;
  final String appointmentId;
  final String sessionId;
  final int amount;
  final String currency;
  final String status;
  final String linkShortUrl;
  final DateTime createdAt;
  final PaymentHistoryCustomer customer;
  final PaymentHistorySession session;

  PaymentHistoryItem({
    required this.id,
    required this.appointmentId,
    required this.sessionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.linkShortUrl,
    required this.createdAt,
    required this.customer,
    required this.session,
  });

  factory PaymentHistoryItem.fromJson(
      Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['_id'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      linkShortUrl: json['linkShortUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      customer: PaymentHistoryCustomer.fromJson(
          json['customer'] ?? {}),
      session: PaymentHistorySession.fromJson(
          json['session'] ?? {}),
    );
  }
}
