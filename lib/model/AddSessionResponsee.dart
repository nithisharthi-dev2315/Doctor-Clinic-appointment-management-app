class AddSessionResponsee {
  final bool success;
  final String message;

  AddSessionResponsee({
    required this.success,
    required this.message,
  });

  factory AddSessionResponsee.fromJson(Map<String, dynamic> json) {
    return AddSessionResponsee(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }
}
