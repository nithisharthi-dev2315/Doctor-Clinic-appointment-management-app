class TokenRefreshResponse {
  final bool success;
  final String accessToken;

  TokenRefreshResponse({
    required this.success,
    required this.accessToken,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      success: json['success'] ?? false,
      accessToken: json['accessToken'] ?? '',
    );
  }
}
