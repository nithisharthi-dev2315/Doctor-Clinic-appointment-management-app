import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'SessionDetailsDialog.dart';
import 'model/DoctorPayment.dart';

class SessionScheduleDetailsPage extends StatelessWidget {
  final DoctorPayment payment;
  final String doctorId;

  const SessionScheduleDetailsPage({
    super.key,
    required this.payment,
    required this.doctorId,
  });




  @override
  Widget build(BuildContext context) {
    debugPrint('doctorId====$doctorId');

    for (final session in payment.sessions) {
      debugPrint(
        "Session ${session.index} doctorId => ${session.sessionHandled}",
      );
    }

    final session = payment.sessions.first;
    final sessionDate = session.scheduledAt.toLocal();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Session Schedule Details",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _actionButtons(context),
            const SizedBox(height: 16),
            _detailsCard(sessionDate),
          ],
        ),
      ),
    );
  }


  // ===========================================================================
  // 🔹 DETAILS CARD
  // ===========================================================================
  Widget _detailsCard(DateTime sessionDate) {


    final SessionSlot slot = payment.sessions.first;

    final DateTime sessionDateTime = slot.scheduledAt;

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
          _sectionTitle("Session Information"),
          const SizedBox(height: 16),
/*

          _infoRow(
            "Appointment ID",
            payment.appointmentId,
          ),

*/

          _infoRow(
            "Patient Name",
            payment.customer.name,
          ),


          _infoRow(
            "Phone Number",
            payment.customer.contact,
          ),


          _infoRow(
            "Plan Name",
            payment.packageSnapshot.packageName,
          ),

          _infoRow(
            "Concern",
            payment.packageSnapshot.concern,
          ),


          _infoRow(
            "Sessions",
            "${payment.sessions.length} session(s)",
          ),


          _infoRow(
            "Scheduled Date",
            formatOnlyDate(sessionDateTime),
          ),

          _infoRow(
            "Scheduled Time",
            formatOnlyTime(sessionDateTime),
          ),
        ],
      ),
    );
  }


  String formatOnlyDate(DateTime dateTime) {
    return DateFormat("dd MMM yyyy").format(dateTime);
  }

  String formatOnlyTime(DateTime dateTime) {
    return DateFormat("hh:mm a").format(dateTime);
  }
    Widget _actionButtons(BuildContext context) {
      return Row(
        children: [
          _actionButton(
            text: "View Details",
            icon: Icons.visibility_outlined,
            color: const Color(0xFF1F808F),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => SessionDetailsDialog(
                  payment: payment,
                  doctorId: doctorId,
                  username: payment.createdByDoctor.username,

                ),
              );
            },

          ),
        ],
      );
    }

  // ===========================================================================
  // 🔹 REUSABLE WIDGETS
  // ===========================================================================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
    );
  }

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

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1),
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        elevation: 1.5,
        shadowColor: color.withOpacity(0.25),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
