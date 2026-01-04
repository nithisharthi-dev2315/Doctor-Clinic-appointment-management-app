class SessionInfo {
  final String concern;
  final String packageName;
  final int sessionsCount;
  final int durationWeeks;

  SessionInfo({
    required this.concern,
    required this.packageName,
    required this.sessionsCount,
    required this.durationWeeks,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      concern: json['concern'],
      packageName: json['package_name'],
      sessionsCount: json['sessions_count'],
      durationWeeks: json['duration_weeks'],
    );
  }
}
