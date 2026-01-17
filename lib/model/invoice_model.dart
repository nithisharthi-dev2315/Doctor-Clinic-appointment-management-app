class InvoiceData {
  final String url;
  final String driveId;
  final String filename;
  final int amount;
  final String currency;
  final String generatedByName;
  final DateTime generatedAt;

  InvoiceData({
    required this.url,
    required this.driveId,
    required this.filename,
    required this.amount,
    required this.currency,
    required this.generatedByName,
    required this.generatedAt,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      url: json['url'] ?? '',
      driveId: json['driveId'] ?? '',
      filename: json['filename'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      generatedByName: json['generatedByName'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}
