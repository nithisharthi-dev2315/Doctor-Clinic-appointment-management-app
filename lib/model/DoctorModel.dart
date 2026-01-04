class DoctorModel {
  final String id;
  final String name;

  DoctorModel({
    required this.id,
    required this.name,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['_id']?.toString() ?? '',
      name: json['username']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }
}
