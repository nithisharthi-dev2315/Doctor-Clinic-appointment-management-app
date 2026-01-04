class EnquiryRequest {
  final String patientId;
  final String chiefComplaint;
  final String notes;
  final String doctorAssigned;

  EnquiryRequest({
    required this.patientId,
    required this.chiefComplaint,
    required this.notes,
    required this.doctorAssigned,
  });

  Map<String, dynamic> toJson() {
    return {
      "patientId": patientId,
      "chiefComplaint": chiefComplaint,
      "notes": notes,
      "doctorAssigned": doctorAssigned,
    };
  }
}
