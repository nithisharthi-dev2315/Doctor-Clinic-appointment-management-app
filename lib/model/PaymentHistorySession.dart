class PaymentHistorySession {
  final String id;
  final String concern;
  final String packageName;
  final int sessionsCount;
  final int durationWeeks;

  PaymentHistorySession({
    required this.id,
    required this.concern,
    required this.packageName,
    required this.sessionsCount,
    required this.durationWeeks,
  });

  factory PaymentHistorySession.fromJson(Map<String, dynamic> json) {
    return PaymentHistorySession(
      id: json['_id'] ?? '',
      concern: json['concern'] ?? '',
      packageName: json['package_name'] ?? '',
      sessionsCount: json['sessions_count'] ?? 0,
      durationWeeks: json['duration_weeks'] ?? 0,
    );
  }
}
