import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'Apiservice/appointment_api_service.dart';
import 'AppToast.dart';
import 'api/ApiService.dart';
import 'model/EnquiryRequest.dart';

class AddEnquiryDialog extends StatefulWidget {
  final String appointmentId;
  final String doctorId;
  final String roomName;

  const AddEnquiryDialog({
    super.key,
    required this.appointmentId,
    required this.doctorId,
    required this.roomName,
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
  bool isSummarizing = false;
  bool isSummaryAdded = false;
  bool isTranscribing = false;



  // 🎙 Recording state
  bool isChiefListening = false;
  bool isNotesListening = false;

// ⏳ Transcript Loading
  bool isChiefTranscribing = false;
  bool isNotesTranscribing = false;

// ✨ Summarize Loading
  bool isChiefSummarizing = false;
  bool isNotesSummarizing = false;

// ✅ Summary Added
  bool isChiefSummaryAdded = false;
  bool isNotesSummaryAdded = false;

  String normalize(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase()
        .trim();
  }

  String extractChiefComplaint(String text) {
    final regex = RegExp(r'Chief Complaint:(.*?)(\n|$)',
        caseSensitive: false);

    final match = regex.firstMatch(text);
    return match != null ? match.group(0)!.trim() : "";
  }


  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }


  Future<void> _startListening(TextEditingController controller) async {
    activeController = controller;

    bool isChief = controller == chiefController;

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

      setState(() {
        if (isChief) {
          isChiefListening = true;
        } else {
          isNotesListening = true;
        }
      });

      _speech.listen(
        localeId: 'en_IN',
        onResult: (result) {
          if (!mounted) return;

          if (result.finalResult) {
            setState(() {
              final newText = result.recognizedWords.trim();
              if (newText.isNotEmpty) {
                controller.text =
                    "${controller.text.trim()} $newText".trim();
              }
            });
          }
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

    setState(() {
      isChiefListening = false;
      isNotesListening = false;
    });
  }

  Widget _actionRow(
      TextEditingController controller, {
        bool showTranscribe = true,
        required String roomName,
      }) {

    bool isChief = controller == chiefController;

    bool isListening =
    isChief ? isChiefListening : isNotesListening;

    bool isTranscribing =
    isChief ? isChiefTranscribing : isNotesTranscribing;

    bool isSummarizing =
    isChief ? isChiefSummarizing : isNotesSummarizing;

    bool isSummaryAdded =
    isChief ? isChiefSummaryAdded : isNotesSummaryAdded;

    Widget smallButton({
      required Widget child,
      required VoidCallback? onTap,
      required Color color,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1),
            ),
            child: Center(child: child),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [

          /// 🎙 Record
          smallButton(
            color: Colors.red,
            onTap: () {
              isListening
                  ? _stopListening()
                  : _startListening(controller);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isListening ? Icons.stop : Icons.mic,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(height: 2),
                Text(
                  isListening ? "Stop" : "Record",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          if (showTranscribe) ...[
            smallButton(
              color: Colors.teal,
              onTap: isTranscribing
                  ? null
                  : () async {
                if (isSummaryAdded) {
                  AppToast.warning(context, "Summary already added");
                  return;
                }

                setState(() {
                  if (isChief) {
                    isChiefTranscribing = true;
                  } else {
                    isNotesTranscribing = true;
                  }
                });

                final result =
                await ApiService.summarizeChiefComplaint(roomName);

                if (!mounted) return;

                setState(() {
                  if (isChief) {
                    isChiefTranscribing = false;
                  } else {
                    isNotesTranscribing = false;
                  }
                });

                if (result != null && result.trim().isNotEmpty) {
                  controller.text =
                  "${controller.text.trim()}\n\n${result.trim()}";

                  setState(() {
                    if (isChief) {
                      isChiefSummaryAdded = true;
                    } else {
                      isNotesSummaryAdded = true;
                    }
                  });
                }
              },
              child: isTranscribing
                  ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.teal,
                ),
              )
                  : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note,
                      size: 16, color: Colors.teal),
                  SizedBox(height: 2),
                  Text(
                    "Transcript",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],

          /// ✨ Summarize with Loading
          smallButton(
            color: Colors.deepPurple,
            onTap: isSummarizing
                ? null
                : () async {
              if (controller.text.trim().isEmpty) {
                AppToast.warning(context, "Please enter text to summarize");
                return;
              }

              setState(() {
                if (isChief) {
                  isChiefSummarizing = true;
                } else {
                  isNotesSummarizing = true;
                }
              });

              final result =
              await ApiService.summarizeText(controller.text.trim());

              if (!mounted) return;

              setState(() {
                if (isChief) {
                  isChiefSummarizing = false;
                } else {
                  isNotesSummarizing = false;
                }
              });

              if (result != null && result.isNotEmpty) {
                AppToast.success(context, "Successfully Added");
              }
            },

            child: isSummarizing
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.deepPurple,
              ),
            )
                : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome,
                    size: 16,
                    color: Colors.deepPurple),
                SizedBox(height: 2),
                Text(
                  "Summarize",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          /// 🗑 Clear
          smallButton(
            color: Colors.grey,
            onTap: () {
              controller.clear();

              setState(() {
                if (isChief) {
                  isChiefSummaryAdded = false;
                } else {
                  isNotesSummaryAdded = false;
                }
              });
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear,
                    size: 16, color: Colors.grey),
                SizedBox(height: 2),
                Text(
                  "Clear",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
                  _actionRow(
                    chiefController,
                    showTranscribe: true, // 4 buttons
                      roomName:widget.roomName
                  ),
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
                  _actionRow(
                    notesController,
                    showTranscribe: false, // Only 3 buttons
                      roomName:widget.roomName
                  ),
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
      onChanged: (_) {
        isSummaryAdded = false;
      },
      minLines: 3,
      maxLines: null, // ✅ auto expand vertically
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


