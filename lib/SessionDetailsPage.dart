import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AddSessionDialog.dart';
import 'Apiservice/appointment_api_service.dart';
import 'model/PaymentHistoryItem.dart';

class SessionDetailsPage extends StatelessWidget {
  final PaymentHistoryItem payment;

  const SessionDetailsPage({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Payment Details",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF0F172A),
        ),
      ),

      /// 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔹 ACTION BUTTONS
            Row(
              children: [
                _actionButton(
                  text: "Add Session",
                  color: const Color(0xFF2563EB),
                  onTap: () async {
                    final success = await _showAddSessionDialog(context);
                    if (success == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
                const SizedBox(width: 10),
                _actionButton(
                  text: "Send Consent",
                  color: const Color(0xFF34D399),
                  onTap: () async {
                    try {
                      final success =
                      await AppointmentApiService.sendConsentApi(
                        appointmentId: payment.appointmentId,
                        doctorName: payment.doctorAssigned,
                        patientName: payment.customer.name,
                        patientPhone: payment.customer.contact,
                        sessionId: payment.sessionId,
                      );
                      if (success && context.mounted) {
                        _showConsentSuccessDialog(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to send consent"),
                          ),
                        );
                      }
                    }
                  },
                ),


              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 DETAILS CARD
            _detailsCard(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 ADD SESSION DIALOG (WITH INSET + POP ANIMATION)
  // ---------------------------------------------------------------------------

  String formatAmount(dynamic amount, String currency) {
    final int minorUnits = int.tryParse(amount.toString()) ?? 0;

    // Convert from minor units (paise / cents)
    final num value = minorUnits / 100;

    // Remove .00 if whole number
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency; // fallback
    }
  }


  void _showConsentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Icon(
          Icons.verified,
          color: Color(0xFF34D399),
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Consent Sent Successfully",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Consent link has been sent to the patient's WhatsApp number.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }




  Future<bool?> _showAddSessionDialog(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Add Session",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (_, __, ___) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: ScheduleSessionDialog(
                customerName: payment.customer.name,
                sessionsCount: payment.session.sessionsCount,
                appointmentId: payment.appointmentId,
                sessionId: payment.sessionId,
                assigned: payment.doctorAssigned,
              ),
            ),
          ),
        );
      },

      /// 🔹 POP-IN ANIMATION
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 DETAILS CARD
  // ---------------------------------------------------------------------------

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
     /*     _infoRow("Payment ID", payment.id),
          _infoRow("Appointment ID", payment.appointmentId),*/
          _infoRow("Customer", payment.customer.name),
          _infoRow("Package", payment.session.packageName),
          _infoRow("Concern", payment.session.concern),
          _infoRow(
            "Duration",
            "${payment.session.sessionsCount} sessions"
                "${payment.session.durationWeeks > 0
                ? " • ${payment.session.durationWeeks} weeks"
                : ""}",
          ),
          _infoRow(
            "Amount",
            "${currencySymbol(payment.currency)} ${formatAmount(payment.amount, payment.currency)}",
          ),

          _infoRow(
            "Status",
            payment.status.toUpperCase(),
          ),
          _infoRow(
            "Created On",
            _formatDate(payment.createdAt),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 ACTION BUTTON
  // ---------------------------------------------------------------------------

  Widget _actionButton({
    required String text,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 INFO ROW
  // ---------------------------------------------------------------------------

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
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
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}
