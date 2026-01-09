class AvailableDoctor {
  final String id;
  final String name;
  final String mobile;
  final String type;

  AvailableDoctor({
    required this.id,
    required this.name,
    required this.mobile,
    required this.type,
  });

  factory AvailableDoctor.fromJson(Map<String, dynamic> json) {
    return AvailableDoctor(
      id: json['_id']?.toString() ?? '',
      name: json['username']?.toString() ?? '',
      mobile: json['mobile_no']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
