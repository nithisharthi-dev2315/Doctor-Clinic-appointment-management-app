import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Apiservice/appointment_api_service.dart';
import 'model/BookSessionPackage.dart';
import 'model/CreatePaymentLinkRequest.dart';

class BookSessionDialog extends StatefulWidget {
  final String appointmentId;
  final String patientName;
  final String phone;
  final String concern;
  final String doctorUsername;
  final String email;

  const BookSessionDialog({
    super.key,
    required this.appointmentId,
    required this.patientName,
    required this.phone,
    required this.concern,
    required this.doctorUsername,
    required this.email,
  });

  @override
  State<BookSessionDialog> createState() => _BookSessionDialogState();
}

class _BookSessionDialogState extends State<BookSessionDialog> {
  SessionPackage? selectedPackage;
  final TextEditingController notesController = TextEditingController();

  bool loadingPackages = true;
  bool submitting = false;

  String selectedCurrency = "INR";
  List<SessionPackage> packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final sessionPackages =
      await AppointmentApiService.getSessionsByConcern(
        widget.concern,
      );

      final dietPackages =
      await AppointmentApiService.getDietPackages();

      setState(() {
        packages = [
          ...sessionPackages,
          ...dietPackages,
        ];
        loadingPackages = false;
      });

      debugPrint("✅ Total packages: ${packages.length}");
    } catch (e) {
      loadingPackages = false;
    }
  }


  // ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (selectedPackage == null) {
      _toast("Please select a package");
      return;
    }

    setState(() => submitting = true);

    try {
      final added =
      await AppointmentApiService.addSessionToAppointment(
        appointmentId: widget.appointmentId,
        sessionId: selectedPackage!.id,
        assignedBy: widget.doctorUsername,
        notes: notesController.text.trim(),
      );

      if (!added) {
        _toast("Failed to add session");
        return;
      }

      final price = selectedCurrency == "INR"
          ? selectedPackage!.priceInr
          : selectedPackage!.priceUsd;

      final paymentRequest = CreatePaymentLinkRequest(
        appointmentId: widget.appointmentId,
        sessionId: selectedPackage!.id,
        amount: price,
        currency: selectedCurrency,
        description:
        "Payment for ${selectedPackage!.packageName}",
        assignedBy: widget.doctorUsername,
        sendWhatsApp: true,
        customer: PaymentCustomer(
          name: widget.patientName,
          email: widget.email,
          contact: widget.phone,
        ),
      );

      final paymentResponse =
      await AppointmentApiService.createPaymentLink(
        paymentRequest,
      );

      if (paymentResponse.success) {
        _toast("Session booked successfully");
        Navigator.pop(context, true);
      } else {
        _toast(paymentResponse.message);
      }
    } catch (e) {
      _toast("Something went wrong");
    } finally {
      setState(() => submitting = false);
    }
  }

  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: loadingPackages
          ? const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ───── HEADER ─────
            Row(
              children: [
                const Icon(
                  Icons.video_camera_front,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Book Session",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 4),
            Text(
              "${widget.patientName} • ${widget.phone}",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 18),

            /// ───── CURRENCY SELECT ─────
            _section(
              title: "Currency",
              child: Row(
                children: [
                  _currencyChip("INR", "₹"),
                  const SizedBox(width: 8),
                  _currencyChip("USD", "\$"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ───── PACKAGE SELECT ─────
            _section(
              title: "Session Package",
              child: InkWell(
                onTap: _showPackageSheet,
                child: _selectorTile(
                  text: selectedPackage == null
                      ? "Select session package"
                      : selectedPackage!.packageName,
                ),
              ),
            ),

            if (selectedPackage != null) ...[
              const SizedBox(height: 6),
              Text(
                selectedPackage!.notes,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Price: ${selectedCurrency == "INR" ? "₹" : "\$"}"
                    "${selectedCurrency == "INR" ? selectedPackage!.priceInr : selectedPackage!.priceUsd}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 18),

            /// ───── NOTES ─────
            _section(
              title: "Notes (optional)",
              child: TextField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                  "Payment info, start date, instructions",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 26),

            /// ───── ACTION BUTTON ─────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: submitting
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
                  "Book Session",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
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

  // ─────────────────────────────────────────────────────────────

  void _showPackageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // ✅ white background
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: packages.map((pkg) {
            final price = selectedCurrency == "INR"
                ? pkg.priceInr
                : pkg.priceUsd;

            return ListTile(
              title: Text(
                pkg.packageName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Text(pkg.notes),
              trailing: Text(
                "${selectedCurrency == "INR" ? "₹" : "\$"}$price",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                setState(() => selectedPackage = pkg);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────

  Widget _currencyChip(String value, String symbol) {
    final selected = selectedCurrency == value;

    return Expanded(
      child: InkWell(
        onTap: () =>
            setState(() => selectedCurrency = value),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2563EB)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            "$value ($symbol)",
            style: TextStyle(
              color:
              selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
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

  Widget _selectorTile({required String text}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down),
      ],
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
    notesController.dispose();
    super.dispose();
  }
}


