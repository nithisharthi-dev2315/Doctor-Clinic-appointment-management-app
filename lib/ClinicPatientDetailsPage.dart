import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Apiservice/appointment_api_service.dart';
import 'ClinicInvoiceTab.dart';
import 'TransferDialog.dart';
import 'api/ApiService.dart';
import 'model/ClinicPatientResponse.dart';
import 'dart:ui';

class ClinicPatientDetailsPage extends StatelessWidget {
  final ClinicPatient patient;
  final String doctorId;

  const ClinicPatientDetailsPage({
    super.key,
    required this.patient,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Patient Details",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _actionButtons(context, doctorId), // ✅ FIXED
            const SizedBox(height: 20),
            _detailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow("Name", patient.name),
          _infoRow("Mobile", patient.mobile),
          _infoRow("Treatment", patient.treatment),
          _infoRow("Treatment Date", _formatDate(patient.treatmentDate)),
          _infoRow("Treatment Time", _formatTo12Hour(patient.treatmentTime)),
          _infoRow(
            "Transferred To",
            patient.transferredTo ?? "-",
            highlight: patient.transferredTo != null,
          ),
          _infoRow("Added On", _formatDateTime(patient.createdAt)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: highlight
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTONS =================

  Widget _actionButtons(BuildContext context, String docterid) {
    print(' patient.invoice===========${patient.invoice}');

    return Column(
      children: [
        Row(
          children: [
            _gridBtn("View", const Color(0xFF2563EB), () {
              showClinicPatientViewDialog(context, patient);
            }),
            const SizedBox(width: 12),
            _gridBtn("Transfer", const Color(0xFF7C3AED), () {
              showTransferDialog(context, patient.id, docterid);
            }),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _gridBtn(
              patient.invoice != null ? "View Invoice" : "+ Invoice",

              // 🎨 Color
              patient.invoice != null
                  ? const Color(0xFF2563EB) // 🔵 View Invoice
                  : const Color(0xFF16A34A), // 🟢 + Invoice

              () async {
                final invoice = patient.invoice;

                /// ➕ ADD INVOICE
                if (invoice == null) {
                  final bool? created = await showCreateInvoiceDialog(
                    context,
                    patientId: patient.id,
                    patientName: patient.name,
                    treatment: patient.treatment,
                    doctorId: docterid,
                  );

                  if (created == true && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClinicInvoiceTab(
                          doctorId: docterid,
                        ),
                      ),
                    );
                  }
                  return;
                }

                /// 🔗 VIEW INVOICE
                final rawUrl = invoice['url'] as String?;
                if (rawUrl == null || rawUrl.isEmpty) return;

                await launchUrl(
                  Uri.parse(rawUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),

            const SizedBox(width: 12),
            _gridBtn("Close", const Color(0xFFDC2626), () {
              // optional action
            }),
          ],
        ),
      ],
    );
  }

  Widget _gridBtn(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void showTransferDialog(
    BuildContext context,
    String patientId,
    String doctorId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TransferDialog(patientId: patientId),
    );
  }

  Future<bool?> showCreateInvoiceDialog(
    BuildContext context, {
    required String patientId,
    required String patientName,
    required String treatment,
    required String doctorId,
  }) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool isLoading = false;
    final parentContext = context;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 HEADER
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Create Invoice for $patientName",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const Divider(),

                    /// 💰 AMOUNT
                    Text(
                      "Treatment Amount (₹)",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: "e.g. 700",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 📝 NOTES
                    Text(
                      "Notes (optional)",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔘 ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            minimumSize: const Size(140, 45),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                            if (amountCtrl.text.trim().isEmpty) return;

                            setState(() => isLoading = true);

                            final double rupees =
                                double.tryParse(amountCtrl.text.trim()) ?? 0;
                            final int paise = (rupees * 100).round();


                            // 🔍 Print format
                            print("Amount (UI)  : ₹${rupees.toStringAsFixed(2)}");
                            print("Amount (API) : $paise paise");

                            final success = await AppointmentApiService.generateInvoice(
                              patientId: patientId,
                              amount: paise.toString(), // ✅ INT
                              treatment: treatment,
                              notes: notesCtrl.text.trim(),
                            );


                            setState(() => isLoading = false);

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pop(parentContext, true);
                              ApiService.getDoctorAppointments(doctorId);
                            }

                          },

                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                            "Create Invoice",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600, // bold
                              fontSize: 14,
                            ),
                          ),

                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showInvoiceSuccessDialog(
      BuildContext context, {
        required String patientName,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  "Invoice Created Successfully",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Invoice for $patientName has been generated.",
                  style: GoogleFonts.poppins(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600, // bold
                      fontSize: 14,
                    ),
                  ),

                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void showClinicPatientViewDialog(
    BuildContext context,
    ClinicPatient patient,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mobile: ${patient.mobile}",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),

                const SizedBox(height: 16),

                /// 🔹 DETAILS GRID
                _rowItem("Treatment", patient.treatment),
                _rowItem("Treatment Date", _formatDate(patient.treatmentDate)),
                _rowItem(
                  "Treatment Time",
                  _formatTo12Hour(patient.treatmentTime),
                ),
                _rowItem(
                  "DOB",
                  patient.dob == null ? "—" : _formatDate(patient.dob),
                ),
                _rowItem(
                  "Address",
                  (patient.address == null || patient.address!.isEmpty)
                      ? "—"
                      : patient.address!,
                ),

                _rowItem("Notes", patient.notes ?? "—"),
                _rowItem("Added", _formatDateTime(patient.createdAt)),

                /// 🔹 INVOICE LINK
                if (patient.invoice != null &&
                    patient.invoice['url'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Invoice",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final rawUrl = patient.invoice?['url'] as String?;

                      if (rawUrl == null || rawUrl.isEmpty) {
                        return; // nothing to open
                      }

                      final uri = Uri.parse(rawUrl);

                      try {
                        final launched = await launchUrl(
                          uri,
                          mode: LaunchMode
                              .externalApplication, // opens Chrome / default browser
                        );

                        if (!launched) {
                          debugPrint("❌ Could not launch invoice URL");
                        }
                      } catch (e) {
                        debugPrint("❌ Invoice launch error: $e");
                      }
                    },
                    child: Text(
                      (patient.invoice?['filename'] as String?) ??
                          "View Invoice",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF2563EB),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                /// 🔹 CLOSE BUTTON
                Center(
                  child: SizedBox(
                    height: 40,
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORMATTERS =================

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    final d = date.toLocal();
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String _formatDateTime(DateTime date) {
    final d = date.toLocal();
    return "${d.day}/${d.month}/${d.year}, "
        "${_formatTo12Hour("${d.hour}:${d.minute}")}";
  }

  String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final isPm = hour >= 12;
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}";
    } catch (_) {
      return time24;
    }
  }
}
