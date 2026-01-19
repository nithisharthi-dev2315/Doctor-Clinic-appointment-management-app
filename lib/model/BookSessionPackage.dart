class SessionPackage {
  final String id;
  final String packageName;
  final int sessionsCount;
  final int durationWeeks;
  final int priceInr;
  final int priceUsd;
  final int priceAbroadInr;
  final int freeDietMonths;
  final String notes;

  SessionPackage({
    required this.id,
    required this.packageName,
    required this.sessionsCount,
    required this.durationWeeks,
    required this.priceInr,
    required this.priceUsd,
    required this.priceAbroadInr,
    required this.freeDietMonths,
    required this.notes,
  });

  /// 🔹 NORMAL SESSION PACKAGE
  factory SessionPackage.fromJson(Map<String, dynamic> json) {
    return SessionPackage(
      id: json['_id'],
      packageName: json['package_name'],
      sessionsCount: json['sessions_count'],
      durationWeeks: json['duration_weeks'],
      priceInr: json['price_inr'],
      priceUsd: json['price_usd'],
      priceAbroadInr: json['price_abroad_inr'] ?? 0,
      freeDietMonths: json['includes_free_diet_months'] ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  /// 🔹 DIET PACKAGE (NEW ✅)
  factory SessionPackage.fromDietJson(Map<String, dynamic> json) {
    return SessionPackage(
      id: json['_id'],
      packageName: json['package_name'],
      sessionsCount: json['sessions_count'], // from API
      durationWeeks: (json['months'] ?? 0) * 4, // convert months → weeks
      priceInr: json['price_inr'],
      priceUsd: json['price_usd'],
      priceAbroadInr: json['price_abroad_inr'] ?? 0,
      freeDietMonths: json['months'] ?? 0, // diet months
      notes: json['notes'] ?? '',
    );
  }
}
