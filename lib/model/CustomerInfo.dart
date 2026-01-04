class CustomerInfo {
  final String name;
  final String email;
  final String contact;

  CustomerInfo({
    required this.name,
    required this.email,
    required this.contact,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
    );
  }
}
