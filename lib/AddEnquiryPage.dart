import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'Apiservice/appointment_api_service.dart';
import 'model/EnquiryRequest.dart';

class AddEnquiryDialog extends StatefulWidget {
  final String appointmentId;
  final String doctorId;

  const AddEnquiryDialog({
    super.key,
    required this.appointmentId,
    required this.doctorId,
  });

  @override
  State<AddEnquiryDialog> createState() => _AddEnquiryDialogState();
}

class _AddEnquiryDialogState extends State<AddEnquiryDialog> {
  final TextEditingController chiefController = TextEditingController();
  final TextEditingController notesController = TextEditingController();


  late stt.SpeechToText _speech;
  bool isListening = false;
  TextEditingController? activeController;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }


  Future<void> _startListening(TextEditingController controller) async {
    activeController = controller;

    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _stopListening();
          }
        },
        onError: (error) {
          _toast("Speech error: ${error.errorMsg}");
          _stopListening();
        },
      );

      if (!available) {
        _toast("Speech recognition not available");
        return;
      }

      setState(() => isListening = true);

      _speech.listen(
        localeId: 'en_IN', // change to ta_IN if needed
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
      );
    } catch (e) {
      _toast("Speech init failed");
    }
  }


  void _stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
    setState(() => isListening = false);
  }


  Widget _actionRow(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              isListening ? _stopListening() : _startListening(controller);
            },
            icon: Icon(
              isListening ? Icons.stop : Icons.mic,
              size: 18,
            ),
            label: Text(isListening ? "Stop" : "Record"),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () {
              _toast("Summarize coming soon");
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text("Summarize"),
          ),
        ],
      ),
    );
  }



  Future<void> _submitEnquiry() async {
    if (chiefController.text.trim().isEmpty) {
      _toast("Chief complaints required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final request = EnquiryRequest(
        patientId: widget.appointmentId,
        chiefComplaint: chiefController.text.trim(),
        notes: notesController.text.trim(),
        doctorAssigned: widget.doctorId,
      );

      final response =
      await AppointmentApiService.submitEnquiry(request);

      if (response.success) {
        _toast("Enquiry save successful");
        Navigator.pop(context);
      }
    } catch (e) {
      _toast("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

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

            /// ───── HEADER ─────
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 22),
                  ),
                )

              ],
            ),

            const SizedBox(height: 18),

            /// ───── CHIEF COMPLAINT ─────
            _section(
              title: "Chief Complaints",
              child: Column(
                children: [
                  _inputField(
                    controller: chiefController,
                    hint: "Describe the patient's main issue",
                    maxLines: 4,
                  ),
                  _actionRow(chiefController),
                ],
              ),
            ),


            const SizedBox(height: 16),

            /// ───── NOTES ─────
            _section(
              title: "Doctor Notes (Optional)",
              child: Column(
                children: [
                  _inputField(
                    controller: notesController,
                    hint: "Additional observations or notes",
                    maxLines: 3,
                  ),
                  _actionRow(notesController),
                ],
              ),
            ),

            const SizedBox(height: 26),

            /// ───── ACTION BUTTON ─────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitEnquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
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
                    : Text(
                  "Submit Enquiry",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───── SECTION WRAPPER ─────
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
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: child,
        ),
      ],
    );
  }

  /// ───── TEXT FIELD ─────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: const Color(0xFF2563EB),
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF94A3B8),
        ),
        border: InputBorder.none,
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        content: Center(
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold, // ✅ bold
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _speech.stop();
    chiefController.dispose();
    notesController.dispose();
    super.dispose();
  }
}


