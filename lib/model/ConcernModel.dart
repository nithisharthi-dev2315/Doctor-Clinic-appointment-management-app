class ConcernModel {
  final String id;
  final String concern;

  ConcernModel({
    required this.id,
    required this.concern,
  });

  factory ConcernModel.fromJson(Map<String, dynamic> json) {
    return ConcernModel(
      id: json['_id'],
      concern: json['concern'],
    );
  }
}
