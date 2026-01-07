import 'package:flutter/material.dart';
import 'Apiservice/appointment_api_service.dart';

import 'package:flutter/material.dart';
import 'Apiservice/appointment_api_service.dart';

import 'package:flutter/material.dart';
import 'Apiservice/appointment_api_service.dart';

import 'package:flutter/material.dart';
import 'Apiservice/appointment_api_service.dart';
class TransferDoctorDialog extends StatefulWidget {
  final String appointmentId;
  final String patientName;

  const TransferDoctorDialog({
    super.key,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  State<TransferDoctorDialog> createState() =>
      _TransferDoctorDialogState();
}

class _TransferDoctorDialogState extends State<TransferDoctorDialog> {
  List<Map<String, String>> doctors = [];
  String? selectedDoctorId;

  final TextEditingController reasonCtrl = TextEditingController();

  bool loadingDoctors = true;
  bool loadingTransfer = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      doctors =
      await AppointmentApiService.fetchAvailableDoctors();
    } catch (e) {
      _toast("Failed to load doctors");
    }
    loadingDoctors = false;
    if (mounted) setState(() {});
  }

  Future<void> _confirmTransfer() async {
    if (selectedDoctorId == null) {
      _toast("Please select a doctor");
      return;
    }

    setState(() => loadingTransfer = true);

    final success =
    await AppointmentApiService.transferToDoctor(
      appointmentId: widget.appointmentId,
      doctorId: selectedDoctorId!,
    );

    setState(() => loadingTransfer = false);

    if (success) {
      Navigator.pop(context, true);
      _toast("Patient transferred successfully");
    } else {
      _toast("Transfer failed");
    }
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                const Icon(
                  Icons.swap_horiz,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Transfer Patient",
                  style: TextStyle(
                    fontSize: 16,
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

            const SizedBox(height: 10),

            /// PATIENT INFO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                "Patient: ${widget.patientName}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SELECT DOCTOR (OLD STYLE)
            const Text(
              "Select Doctor *",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            loadingDoctors
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
                : DropdownButtonFormField<String>(
              value: selectedDoctorId,
              isExpanded: true,

              decoration: InputDecoration(
                hintText: "Choose doctor",
                isDense: true,
                filled: true,                    // ✅ REQUIRED
                fillColor: Colors.white,         // ✅ FIELD WHITE
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: Colors.white,       // ✅ POPUP WHITE
              items: doctors.map((d) {
                return DropdownMenuItem<String>(
                  value: d['id'],
                  child: Container(
                    color: Colors.white,          // ✅ ITEM WHITE
                    child: Text(
                      d['name'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),

              onChanged: (v) => setState(() => selectedDoctorId = v),
            ),


        const SizedBox(height: 14),

            /// REASON
            const Text(
              "Reason (optional)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                "Reason for transfer (optional)",
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed:
                  loadingTransfer ? null : _confirmTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  child: loadingTransfer
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Confirm Transfer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    reasonCtrl.dispose();
    super.dispose();
  }
}

