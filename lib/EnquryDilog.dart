import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Apiservice/appointment_api_service.dart';
import 'model/DoctorPayment.dart';

class EnquiryDialog extends StatefulWidget {
  final String addSessionId;
  final String sessionIndex;
  final String updatedBy; // doctorId
  final String username;
  final DoctorPayment payment;

  const EnquiryDialog({
    super.key,
    required this.addSessionId,
    required this.sessionIndex,
    required this.updatedBy,
    required this.username,
    required this.payment,
  });

  @override
  State<EnquiryDialog> createState() => _EnquiryDialogState();
}

class _EnquiryDialogState extends State<EnquiryDialog> {
  final TextEditingController chiefController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isLoading = false;

  /// ✅ REQUIRED KEY (FIXES YOUR ERROR)
  late List<bool> enquiryExpanded;

  late final int currentSessionIndex;

  @override
  void initState() {
    super.initState();
    currentSessionIndex = int.parse(widget.sessionIndex) - 1;

    final session = widget.payment.sessions[currentSessionIndex];
    chiefController.text = session.chiefComplaints ?? "";
    notesController.text = session.enquiryNotes ?? "";
  }

  // ================= SUBMIT =================
  Future<void> _submitEnquiry() async {
    if (chiefController.text.trim().isEmpty) {
      _toast("Chief complaints required");
      return;
    }

    setState(() => isLoading = true);

    try {
      await AppointmentApiService.updateEnquiry(
        addSessionId: widget.addSessionId,
        sessionIndex: widget.sessionIndex,
        chiefComplaints: chiefController.text.trim(),
        enquiryNotes: notesController.text.trim(),
        updatedBy: widget.updatedBy,
      );

      /// 🔁 RELOAD FROM SERVER
      final response = await AppointmentApiService.getDoctorPayments(
        doctorId: widget.updatedBy,
        username: widget.username,
      );

      /// ✅ ALWAYS CHECK sessions
      if (response.sessions.isEmpty) return;

      /// 🔥 MATCH BY PAYMENT ID (SAFE)
      final updatedPayment = response.sessions.firstWhere(
            (p) => p.id == widget.addSessionId,
        orElse: () => response.sessions.first,
      );


      Navigator.pop(
        context,
        updatedPayment.sessions[currentSessionIndex], // ✅ RETURN SESSION
      );
    } catch (e) {
      _toast("Failed to update enquiry");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  // ================= RELOAD =================
  Future<void> _reloadDoctorPayments() async {
    try {


      final response = await AppointmentApiService.getDoctorPayments(
        doctorId: widget.updatedBy,
        username: widget.username,
      );

      if (!mounted || response.sessions.isEmpty) return;

      final updatedSessions = response.sessions.first.sessions;


      if (currentSessionIndex >= updatedSessions.length) return;

      setState(() {
        /// ✅ UPDATE ONLY CURRENT SESSION
        widget.payment.sessions[currentSessionIndex] =
        updatedSessions[currentSessionIndex];

        /// ✅ KEEP EXPANDED STATE SAFE
        _syncExpanded();
      });
    } catch (e) {
      debugPrint("Reload failed: $e");
    }
  }

  void _syncExpanded() {
    enquiryExpanded =
    List<bool>.filled(widget.payment.sessions.length, false);
  }



  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                const Icon(
                  Icons.help_outline,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(
                  "Add Enquiry",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 18),

            /// CHIEF COMPLAINT
            _section(
              title: "Chief Complaints",
              child: _inputField(
                controller: chiefController,
                hint: "Describe the patient's main issue",
                maxLines: 4,
              ),
            ),

            const SizedBox(height: 16),

            /// NOTES
            _section(
              title: "Doctor Notes (Optional)",
              child: _inputField(
                controller: notesController,
                hint: "Additional observations or notes",
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 26),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitEnquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Add Enquiry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    chiefController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
