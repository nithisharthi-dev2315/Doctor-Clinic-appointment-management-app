class EnquiryResponse {
  final bool success;
  final String message;

  EnquiryResponse({
    required this.success,
    required this.message,
  });

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) {
    return EnquiryResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }
}
