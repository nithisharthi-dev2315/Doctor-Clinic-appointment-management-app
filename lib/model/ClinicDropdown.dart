
class ClinicDropdown {
  final String id;
  final String name;

  ClinicDropdown({required this.id, required this.name});

  factory ClinicDropdown.fromJson(Map<String, dynamic> json) {
    return ClinicDropdown(
      id: json['_id'],
      name: json['clinicName'],
    );
  }
}
