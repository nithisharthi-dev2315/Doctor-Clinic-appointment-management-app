  import 'patient_invoice_item.dart';

  class PatientInvoiceResponse {
    final bool success;
    final List<PatientInvoiceItem> data;
    final int total;
    final int page;
    final int limit;

    PatientInvoiceResponse({
      required this.success,
      required this.data,
      required this.total,
      required this.page,
      required this.limit,
    });

    factory PatientInvoiceResponse.fromJson(Map<String, dynamic> json) {
      final List rawList =
      json['data'] is List ? json['data'] : [];

      final invoices = rawList
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => PatientInvoiceItem.fromJson(e))
          .toList();

      return PatientInvoiceResponse(
        success: json['success'] == true,
        data: invoices,
        total: json['total'] ?? invoices.length,
        page: json['page'] ?? 1,
        limit: json['limit'] ?? 20,
      );
    }
  }
