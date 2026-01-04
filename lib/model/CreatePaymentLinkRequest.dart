class CreatePaymentLinkRequest {
  final String appointmentId;
  final String sessionId;
  final int amount;
  final String currency;
  final String description;
  final String assignedBy;
  final bool sendWhatsApp;
  final PaymentCustomer customer;

  CreatePaymentLinkRequest({
    required this.appointmentId,
    required this.sessionId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.assignedBy,
    required this.sendWhatsApp,
    required this.customer,
  });

  Map<String, dynamic> toJson() => {
    "appointmentId": appointmentId,
    "sessionId": sessionId,
    "amount": amount,
    "currency": currency,
    "description": description,
    "assignedBy": assignedBy,
    "sendWhatsApp": sendWhatsApp,
    "customer": customer.toJson(),
  };
}

class PaymentCustomer {
  final String name;
  final String email;
  final String contact;

  PaymentCustomer({
    required this.name,
    required this.email,
    required this.contact,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "contact": contact,
  };
}
