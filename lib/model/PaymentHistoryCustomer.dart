class PaymentHistoryCustomer {
  final String name;
  final String email;
  final String contact;

  PaymentHistoryCustomer({
    required this.name,
    required this.email,
    required this.contact,
  });

  factory PaymentHistoryCustomer.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryCustomer(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
    );
  }
}
