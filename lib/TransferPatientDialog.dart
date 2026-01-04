import 'package:flutter/material.dart';

import 'Apiservice/appointment_api_service.dart';

class TransferPatientDialog extends StatefulWidget {
  final String appointmentId;
  final String patientName;
  final String patientMobile;
  final String patientEmail;
  final int age;
  final String gender;
  final String treatment;

  const TransferPatientDialog({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.patientMobile,
    required this.patientEmail,
    required this.age,
    required this.gender,
    required this.treatment,
  });

  @override
  State<TransferPatientDialog> createState() =>
      _TransferPatientDialogState();
}

class _TransferPatientDialogState extends State<TransferPatientDialog> {
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  bool loading = false;

  /// 🔹 SEARCH STATE
  bool hasSearchResult = false;
  bool showResultHint = false;

  /// 🔹 CLINIC DATA
  List<Map<String, String>> allClinics = [];
  List<Map<String, String>> filteredClinics = [];

  String? selectedClinicId;
  String? selectedClinicName;

  @override
  void initState() {
    super.initState();
    _loadClinics();

    searchCtrl.addListener(() {
      _filterClinics(searchCtrl.text);
    });
  }

  Future<void> _loadClinics() async {
    allClinics = await AppointmentApiService.fetchClinics();
    filteredClinics = allClinics;
    setState(() {});
  }

  /// 🔍 SEARCH FILTER + INDICATION
  void _filterClinics(String query) {
    if (query.isEmpty) {
      filteredClinics = allClinics;
      hasSearchResult = false;
      showResultHint = false;
    } else {
      final q = query.toLowerCase();

      filteredClinics = allClinics.where((c) {
        return (c['name'] ?? '').toLowerCase().contains(q) ||
            (c['address'] ?? '').toLowerCase().contains(q) ||
            (c['pincode'] ?? '').contains(q) ||
            (c['state'] ?? '').toLowerCase().contains(q);
      }).toList();

      hasSearchResult = filteredClinics.isNotEmpty;
      showResultHint = true;
    }

    /// ❌ CLEAR INVALID SELECTION
    if (!filteredClinics.any((c) => c['id'] == selectedClinicId)) {
      selectedClinicId = null;
      selectedClinicName = null;
    }

    setState(() {});
  }

  Future<void> _confirmTransfer() async {
    if (selectedClinicId == null) {
      _toast("Please select a clinic");
      return;
    }

    setState(() => loading = true);

    final success =
    await AppointmentApiService.transferToClinic(
      appointmentId: widget.appointmentId,
      clinicId: selectedClinicId!,
      clinicName: selectedClinicName!,
      patientData: {
        "name": widget.patientName,
        "mobile": widget.patientMobile,
        "email": widget.patientEmail,
        "age": widget.age,
        "gender": widget.gender,
        "address": "",
      },
      treatment: widget.treatment,
      transferNotes: notesCtrl.text.trim(),
    );

    setState(() => loading = false);

    if (success) {
      Navigator.pop(context, true);
      _toast("Patient transferred successfully");
    }
  }

  // ───────────────────────── UI ─────────────────────────

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                const Icon(Icons.swap_horiz,
                    color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                const Text(
                  "Transfer Patient",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 8),

            /// PATIENT INFO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.patientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.patientMobile} • ${widget.gender}, ${widget.age} yrs",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// 🔍 SMALL SEARCH FIELD
            _section(
              title: "Search clinic",
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: searchCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                    "Search by pincode, area or clinic",
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon:
                    const Icon(Icons.search, size: 18),
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// ✅ DROPDOWN WITH SEARCH INDICATION
            _section(
              title: "Destination clinic *",
              child: InkWell(
                onTap: hasSearchResult
                    ? _openClinicPicker
                    : () => _toast(
                    "Search clinic to see available results"),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedClinicName ??
                                (hasSearchResult
                                    ? "Tap to view ${filteredClinics.length} results"
                                    : "Select a clinic"),
                            style: TextStyle(
                              fontWeight: hasSearchResult
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: hasSearchResult
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          if (showResultHint &&
                              hasSearchResult)
                            const Padding(
                              padding:
                              EdgeInsets.only(top: 2),
                              child: Text(
                                "Matching clinics found",
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                  Color(0xFF64748B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: hasSearchResult
                          ? const Color(0xFF2563EB)
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// NOTES
            _section(
              title: "Transfer notes (optional)",
              child: TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                  "Reason, urgency, special instructions",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 26),

            /// ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                loading ? null : _confirmTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Confirm Transfer",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── BOTTOM SHEET ─────────────────────────

  void _openClinicPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Select Clinic (${filteredClinics.length})",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: filteredClinics.isEmpty
                  ? const Center(
                child: Text(
                  "No clinics found",
                  style:
                  TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.separated(
                itemCount: filteredClinics.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = filteredClinics[i];
                  return ListTile(
                    title: Text(
                      c['name'] ?? '',
                      style: const TextStyle(
                          fontWeight:
                          FontWeight.w600),
                    ),
                    subtitle: Text(
                      c['address'] ?? '',
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        selectedClinicId =
                        c['id'];
                        selectedClinicName =
                        c['name'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────── HELPERS ─────────────────────────

  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border:
            Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      ],
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
