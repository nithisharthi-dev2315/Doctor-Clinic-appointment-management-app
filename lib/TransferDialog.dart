
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Apiservice/appointment_api_service.dart';
import 'api/ApiService.dart';
import 'model/ClinicDropdown.dart';
import 'model/ConcernModel.dart';

class TransferDialog extends StatefulWidget {
  final String patientId;

  const TransferDialog({
    super.key,
    required this.patientId,
  });

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}


class _TransferDialogState extends State<TransferDialog> {
  ClinicDropdown? selectedClinic;
  ConcernModel? selectedConcern;
  final TextEditingController reasonCtrl = TextEditingController();

  late Future<List<ClinicDropdown>> clinicsFuture;
  late Future<List<ConcernModel>> concernsFuture;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    clinicsFuture = AppointmentApiService.getClinics();
    concernsFuture = AppointmentApiService.getConcerns();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
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
                Text(
                  "Transfer to Zeromedixine",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),

            const SizedBox(height: 12),

            /// 🔹 DESTINATION CLINIC
            _label("Destination Clinic"),
            FutureBuilder<List<ClinicDropdown>>(
              future: clinicsFuture,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return _loadingField();
                }
                return _dropdown<ClinicDropdown>(
                  value: selectedClinic,
                  hint: "Select Clinic",
                  items: snap.data!,
                  getLabel: (c) => c.name,
                  onChanged: (v) => setState(() => selectedClinic = v),
                );
              },
            ),

            const SizedBox(height: 14),

            /// 🔹 TREATMENT
            _label("Select Treatment"),
            FutureBuilder<List<ConcernModel>>(
              future: concernsFuture,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return _loadingField();
                }
                return _dropdown<ConcernModel>(
                  value: selectedConcern,
                  hint: "Select Concern",
                  items: snap.data!,
                  getLabel: (c) => c.concern,
                  onChanged: (v) => setState(() => selectedConcern = v),
                );
              },
            ),

            const SizedBox(height: 14),

            /// 🔹 REASON
            _label("Reason (optional)"),
            TextField(
              controller: reasonCtrl,
              maxLines: 4,
              decoration: _inputDecoration("Enter reason"),
            ),

            const SizedBox(height: 20),

            /// 🔹 ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),

                /// 🔵 TRANSFER BUTTON
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    if (selectedClinic == null || selectedConcern == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select clinic and treatment"),
                        ),
                      );
                      return;
                    }

                    setState(() => isSubmitting = true);

                    final success = await ApiService.transferPatient(
                      patientId: widget.patientId,
                      toClinicId: selectedClinic!.id,
                      concernId: selectedConcern!.id,
                      notes: reasonCtrl.text.trim(),
                    );

                    setState(() => isSubmitting = false);

                    if (success && context.mounted) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Patient transferred",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF0D9488),
                        ),
                      );

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Transfer failed. Try again",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF0D9488),
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: isSubmitting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("Transfer"),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _loadingField() {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _box(),
      child: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(getLabel(e)),
        ),
      )
          .toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFCBD5E1)),
    );
  }
}
