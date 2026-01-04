class CreatePaymentLinkResponse {
  final bool success;
  final String message;
  final PaymentLinkData payment;
  final PaymentLinkShort link;

  CreatePaymentLinkResponse({
    required this.success,
    required this.message,
    required this.payment,
    required this.link,
  });

  factory CreatePaymentLinkResponse.fromJson(Map<String, dynamic> json) {
    return CreatePaymentLinkResponse(
      success: json['success'],
      message: json['message'],
      payment: PaymentLinkData.fromJson(json['payment']),
      link: PaymentLinkShort.fromJson(json['link']),
    );
  }
}

class PaymentLinkShort {
  final String id;
  final String shortUrl;
  final String referenceId;

  PaymentLinkShort({
    required this.id,
    required this.shortUrl,
    required this.referenceId,
  });

  factory PaymentLinkShort.fromJson(Map<String, dynamic> json) {
    return PaymentLinkShort(
      id: json['id'],
      shortUrl: json['short_url'],
      referenceId: json['reference_id'],
    );
  }
}

class PaymentLinkData {
  final String referenceId;
  final int amount;
  final String currency;
  final String status;

  PaymentLinkData({
    required this.referenceId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentLinkData.fromJson(Map<String, dynamic> json) {
    return PaymentLinkData(
      referenceId: json['referenceId'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
    );
  }
}
