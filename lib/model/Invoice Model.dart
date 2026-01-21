// ======================= INVOICE =======================
class Invoice {
  final String? url;
  final String? driveId;
  final String? filename;
  final int amount;
  final String currency;
  final String? generatedBy;
  final String? generatedByName;
  final DateTime? generatedAt;
  final String? razorpayPaymentLink;

  Invoice({
    this.url,
    this.driveId,
    this.filename,
    required this.amount,
    required this.currency,
    this.generatedBy,
    this.generatedByName,
    this.generatedAt,
    this.razorpayPaymentLink,
  });

  factory Invoice.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return Invoice(
        amount: 0,
        currency: 'INR',
      );
    }

    return Invoice(
      url: json['url'],
      driveId: json['driveId'],
      filename: json['filename'],
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      generatedBy: json['generatedBy'],
      generatedByName: json['generatedByName'],
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
      razorpayPaymentLink: json['razorpayPaymentLink'],
    );
  }
}
