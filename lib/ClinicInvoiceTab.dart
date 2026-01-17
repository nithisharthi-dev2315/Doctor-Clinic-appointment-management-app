import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'Apiservice/appointment_api_service.dart';
import 'HomePage.dart';
import 'model/patient_invoice_item.dart';

class ClinicInvoiceTab extends StatefulWidget {
  final String doctorId;
  final bool showSuccess;

  const ClinicInvoiceTab({
    super.key,
    required this.doctorId,
    this.showSuccess = false,
  });

  @override
  State<ClinicInvoiceTab> createState() => _ClinicInvoiceTabState();
}

class _ClinicInvoiceTabState extends State<ClinicInvoiceTab> {
  bool isLoading = true;
  List<PatientInvoiceItem> invoices = [];

  /// 🔄 TRACK SHARING STATE
  final Set<String> _sharingIds = {};

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      setState(() => isLoading = true);
      final response = await AppointmentApiService.fetchInvoices(
        doctorId: widget.doctorId,
      );
      invoices = response.data;
    } catch (e) {
      debugPrint("Invoice load error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDateDDMMYY(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date.toLocal());
  }

  /// 🔗 OPEN PDF
  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 📤 SHARE PDF FILE
  Future<void> _sharePdfFile({
    required String id,
    required String driveUrl,
    required String filename,
  }) async {
    if (_sharingIds.contains(id)) return;

    setState(() => _sharingIds.add(id));

    try {
      final downloadUrl = _convertDriveToDownload(driveUrl);
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/$filename");

        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: "Invoice PDF",
        );
      }
    } catch (e) {
      debugPrint("PDF share error: $e");
    } finally {
      setState(() => _sharingIds.remove(id));
    }
  }

  /// 🔄 GOOGLE DRIVE VIEW → DOWNLOAD
  String _convertDriveToDownload(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final fileId = segments[segments.indexOf('d') + 1];
    return "https://drive.google.com/uc?export=download&id=$fileId";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Invoices",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ClinicFloatingButtons(
        onAddInvoice: () async {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AddInvoiceDialog(),
          );

          if (result == true) {
            _loadInvoices();
          }
        },
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : invoices.isEmpty
          ? Center(
        child: Text(
          "No invoices found",
          style: GoogleFonts.poppins(),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadInvoices,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: invoices.length,
          itemBuilder: (_, index) {
            final item = invoices[index];
            final isSharing = _sharingIds.contains(item.id);

            return GestureDetector(
              onTap: item.invoice == null
                  ? null
                  : () => _openPdf(item.invoice!.url),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PDF ICON
                    Container(
                      width: 48,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.treatment,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),

                          /// ✅ GENERATED DATE (DD MM YY)
                          Text(
                            item.invoice?.generatedAt != null
                                ? "Date: ${formatDateDDMMYY(item.invoice!.generatedAt)}"
                                : "Date: -",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// AMOUNT + SHARE
                    Column(
                      children: [
                        Text(
                          item.invoice != null
                              ? "₹${(item.invoice!.amount / 100).toStringAsFixed(0)}"
                              : "-",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: item.invoice != null
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),

                        if (item.invoice != null)
                          isSharing
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : IconButton(
                            icon: const Icon(Icons.share, size: 20),
                            onPressed: () => _sharePdfFile(
                              id: item.id,
                              driveUrl: item.invoice!.url,
                              filename: item.invoice!.filename,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 🔥 FLOATING BUTTON
class ClinicFloatingButtons extends StatelessWidget {
  final VoidCallback onAddInvoice;

  const ClinicFloatingButtons({
    super.key,
    required this.onAddInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _clinicFabButton(
        onTap: onAddInvoice,
      ),
    );
  }
}

Widget _clinicFabButton({
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF22C55E),
            Color(0xFF16A34A),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    ),
  );
}
