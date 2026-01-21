// ======================= CONSENT FORM =======================
class ConsentForm {
  final String? url;
  final String? driveId;
  final String? filename;
  final String? name;
  final String? age;
  final String? concern;
  final String? assessmentLink;
  final String? uploadedBy;
  final DateTime? submittedAt;

  ConsentForm({
    this.url,
    this.driveId,
    this.filename,
    this.name,
    this.age,
    this.concern,
    this.assessmentLink,
    this.uploadedBy,
    this.submittedAt,
  });

  factory ConsentForm.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return ConsentForm();
    }

    return ConsentForm(
      url: json['url'],
      driveId: json['driveId'],
      filename: json['filename'],
      name: json['name'],
      age: json['age'],
      concern: json['concern'],
      assessmentLink: json['assessmentLink'],
      uploadedBy: json['uploadedBy'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
    );
  }
}
