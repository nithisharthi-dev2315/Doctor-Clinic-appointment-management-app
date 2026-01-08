import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'AddEnquiryPage.dart';
import 'Apiservice/appointment_api_service.dart';
import 'CommonWebViewPage.dart';
import 'EnquryDilog.dart';
import 'api/EditSessionsDialog.dart';
import 'model/DoctorPayment.dart';

class SessionDetailsDialog extends StatefulWidget {
  final DoctorPayment payment;
  final String doctorId;
  final String username;


  const SessionDetailsDialog({
    super.key,
    required this.payment,
    required this.doctorId,
    required this.username,
  });

  @override
  State<SessionDetailsDialog> createState() => _SessionDetailsDialogState();
}

class _SessionDetailsDialogState extends State<SessionDetailsDialog> {
  late List<bool> enquiryExpanded;

  List<Map<String, String>> doctors = [];
  final Map<int, Map<String, String>> selectedDoctors = {};

  bool loadingDoctors = false;

  final Map<int, TextEditingController> treatmentControllers = {};



  bool creatingRoom = false;

  /// ROOM DATA
  String? roomName;
  String? patientLink;
  String? doctorLink;
  String? handledBy;
  String? treatment;
  String? notes;
  String? complintes;
  final Map<int, _RoomCache> roomCache = {};
  late DoctorPayment payment;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    payment = widget.payment;
    enquiryExpanded =
    List<bool>.filled(payment.sessions.length, false);
    loadSessions();
    _loadDoctors();
  }



  Future<void> _createRoom(int index) async {
    if (creatingRoom) return;

    final controller = treatmentControllers[index];

    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter treatment")),
      );
      return;
    }

    setState(() => creatingRoom = true);

    try {
      final res = await AppointmentApiService.createSessionRoom(
        sessionObjectId: widget.payment.id,
        sessionIndex: index + 1,
        doctorId: widget.doctorId,
        treatment: controller.text.trim(),
      );


      print('res==========${res}');


      setState(() {
        roomCache[index] = _RoomCache(
          roomName: res.session.roomName,
          patientLink: res.session.patientLink,
          doctorLink: res.session.doctorLink,
          handledBy: res.session.handledBy,
          treatment: res.session.treatment,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room created successfully")),
      );

      /// ✅ ONLY PLACE to reload
      await _reloadDoctorPayments(index);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create room failed")),
      );
    } finally {
      if (mounted) setState(() => creatingRoom = false);
    }
  }
  Future<void> loadSessions() async {
    setState(() => _loading = true);

    try {
      final response = await AppointmentApiService.getDoctorPayments(
        doctorId: widget.doctorId,
        username: widget.username,
      );

      /// ✅ CORRECT EMPTY CHECK
      if (response.sessions.isEmpty) return;

      /// ✅ Pick correct payment (best: match by id)
      final DoctorPayment selectedPayment =
      response.sessions.firstWhere(
            (p) => p.id == widget.payment.id,
        orElse: () => response.sessions.first,
      );

      setState(() {
        payment = selectedPayment;
        enquiryExpanded =
        List<bool>.filled(payment.sessions.length, false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load sessions",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadDoctorPayments(int expandedIndex) async {
    try {
      final response = await AppointmentApiService.getDoctorPayments(
        doctorId: widget.doctorId,
        username: widget.username,
      );

      /// 🔐 SAFETY CHECK
      if (response.sessions.isEmpty) return;

      /// 👉 pick the correct DoctorPayment
      /// If you already know which payment this screen belongs to,
      /// usually it is index 0 OR matched by id
      final DoctorPayment payment = response.sessions.first;

      setState(() {
        widget.payment.sessions
          ..clear()
          ..addAll(payment.sessions);

        enquiryExpanded =
        List<bool>.filled(widget.payment.sessions.length, false);

        if (expandedIndex < enquiryExpanded.length) {
          enquiryExpanded[expandedIndex] = true;
        }

        /// ✅ SAFE DEBUG
        debugPrint(
          "UPDATED CC: ${payment.sessions[expandedIndex].chiefComplaints}",
        );
        debugPrint(
          "UPDATED NOTES: ${payment.sessions[expandedIndex].enquiryNotes}",
        );
      });
    } catch (e) {
      debugPrint("Reload failed: $e");
    }
  }



  String formatSessionDate(String date) {
    final parsed = DateTime.parse(date);
    return DateFormat("dd MMM yyyy").format(parsed);
  }

  String formatSessionTime(String time) {
    final parts = time.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final dt = DateTime(2000, 1, 1, hour, minute);
    return DateFormat("hh:mm a").format(dt);
  }


  Future<void> _setReminder(int index) async {
    final url = Uri.parse(
      "https://srv1090011.hstgr.cloud/api/add_sessions/"
          "${widget.payment.id}/session/${index + 1}/set-reminder",
    );

    _showLoading();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sendReminder": true,
        }),
      );

      Navigator.pop(context); // close loading

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        _showErrorDialog("Failed to set reminder");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Network error. Try again.");
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              "Reminder Set Successfully",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "The reminder has been sent successfully.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
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

  Future<void> _sendInvoice() async {
    final url = Uri.parse(
      "https://srv1090011.hstgr.cloud/api/add_sessions/"
          "${widget.payment.id}/generate-invoice",
    );

    _showLoading();

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      Navigator.pop(context); // close loader

      if (response.statusCode == 200) {
        _showInvoiceSuccessDialog();
      } else {
        _showErrorDialog("Failed to send invoice");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Network error. Please try again.");
    }
  }
  void _showInvoiceSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, // ✅ FORCE WHITE
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Icon(
          Icons.receipt_long,
          color: Color(0xFFF97316),
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Invoice Sent Successfully",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black, // ✅ text visible
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "The invoice has been generated and sent to the customer WhatsApp Number.",
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
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }





  Future<void> _loadDoctors() async {
    if (loadingDoctors || doctors.isNotEmpty) return;

    setState(() => loadingDoctors = true);

    try {
      final result = await AppointmentApiService.fetchAvailableDoctors();

      if (!mounted) return;

      setState(() {
        doctors = result;
      });
    } catch (e) {
      debugPrint("Doctor load error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load doctors")),
        );
      }
    } finally {
      if (mounted) setState(() => loadingDoctors = false);
    }
  }


  @override
  Widget build(BuildContext context) {



    final SessionSlot slot = widget.payment.sessions.first;

    final DateTime sessionDateTime = slot.scheduledAt;

    final String date; // "2026-01-19"
    final String time; // "23:00"

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white, // 👈 FORCE WHITE

      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= HEADER =================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Session Details",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.payment.customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "Package: ${widget.payment.packageSnapshot.packageName} | "
                    "Concern: ${widget.payment.packageSnapshot.concern} | "
                    "Total Sessions: ${widget.payment.sessions.length}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 16),

              // ================= ACTION BUTTONS =================
              Row(
                children: [
                  _topActionButton(
                    "Edit Sessions",
                    const Color(0xFFE5E7EB),
                    Colors.black,
                    onTap: () async {
                      final updatedPayment =
                      await showDialog<DoctorPayment>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => EditSessionsDialog(
                          payment: payment, // 🔥 USE LOCAL STATE
                        ),
                      );

                      // ✅ Update UI without closing SessionDetailsDialog
                      if (updatedPayment != null && mounted) {
                        setState(() {
                          payment = updatedPayment;
                          enquiryExpanded =
                          List<bool>.filled(payment.sessions.length, false);
                        });
                      }
                    },
                  ),

                  const SizedBox(width: 8),
                  _topActionButton(
                    "Send Invoice",
                    const Color(0xFFF97316),
                    Colors.white,
                    onTap: _sendInvoice,
                  ),

                  const SizedBox(width: 8),
                  _topActionButton(
                    "Close",
                    const Color(0xFF2563EB),
                    Colors.white,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= SESSIONS =================
              Text(
                "Scheduled Sessions",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),


              ...List.generate(widget.payment.sessions.length, (index) {
                final session = widget.payment.sessions[index];
                final DateTime sessionDateTime =
                session.scheduledDateTime.toLocal(); // ✅ CORRECT
                return Column(
                  key: ValueKey(
                    '${session.index}_${session.date}_${session.time}', // ✅ UNIQUE KEY
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Session ${session.index}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  formatOnlyDate(sessionDateTime), // ✅ FIX
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                Text(
                                  formatOnlyTime(sessionDateTime), // ✅ FIX
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          /// 🔹 ACTIONS
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () async {
                                  final updatedSession = await showDialog<SessionSlot>(
                                    context: context,
                                    builder: (_) => EnquiryDialog(
                                      addSessionId: payment.id,          // ✅ use local state
                                      sessionIndex: (index + 1).toString(),
                                      updatedBy: widget.doctorId,
                                      username: widget.username,
                                      payment: payment,                  // ✅ use local state
                                    ),
                                  );

                                  if (updatedSession != null && mounted) {
                                    setState(() {
                                      final updatedSessions =
                                      List<SessionSlot>.from(payment.sessions);
                                      updatedSessions[index] = updatedSession;

                                      payment = DoctorPayment(
                                        id: payment.id,
                                        appointmentId: payment.appointmentId,
                                        session: payment.session,
                                        doctorAssigned: payment.doctorAssigned,
                                        packageSnapshot: payment.packageSnapshot,
                                        sessions: updatedSessions,       // ✅ NEW LIST
                                        status: payment.status,
                                        createdAt: payment.createdAt,
                                        updatedAt: DateTime.now(),
                                        customer: payment.customer,
                                        appointment: payment.appointment,
                                        createdByDoctor: payment.createdByDoctor,
                                      );

                                      enquiryExpanded[index] = true;
                                    });

                                    debugPrint("UPDATED CC: ${updatedSession.chiefComplaints}");
                                    debugPrint("UPDATED NOTES: ${updatedSession.enquiryNotes}");
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34D399),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Enquiry",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),


                              const SizedBox(width: 6),

                              InkWell(
                                onTap: () {
                                  setState(() {
                                    enquiryExpanded[index] =
                                    !enquiryExpanded[index];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Icon(
                                    enquiryExpanded[index]
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (enquiryExpanded[index]) ...[
                      const SizedBox(height: 12),
                      _enquirySection(index),
                      const SizedBox(height: 12),
                      _existingRoomInfo(
                        index,
                        roomName,
                        patientLink,
                        doctorLink,
                        handledBy,
                        treatment,
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                );
              }),


              const Divider(height: 24),

              _infoRow("Appointment ID", widget.payment.appointmentId),
              _infoRow("Customer Contact", widget.payment.customer.contact),
              _infoRow("Doctor", widget.payment.doctorAssigned.name),
              _infoRow("Status", widget.payment.status),
              _infoRow(
                "Created",
                DateFormat("dd/MM/yyyy, hh:mm a")
                    .format(widget.payment.createdAt.toLocal()),
              ),
              _infoRow(
                "Duration",
                "${widget.payment.packageSnapshot.durationWeeks ?? 0} weeks",
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  String formatOnlyDate(DateTime dateTime) {
    return DateFormat("dd MMM yyyy").format(dateTime);
  }

  String formatOnlyTime(DateTime dateTime) {
    return DateFormat("hh:mm a").format(dateTime);
  }




  void _showAddEnquiryDialog(BuildContext context, int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "AddEnquiry",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [

              /// 🔥 BLUR BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),

              /// ✅ CENTER DIALOG
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: EnquiryDialog(
                    addSessionId: widget.payment.id,          // ✅ REQUIRED
                    sessionIndex: (index + 1).toString(),     // ✅ REQUIRED
                    updatedBy: widget.doctorId,               // or doctor name
                    username: widget.username,
                    payment: widget.payment,// or doctor name
                  ),
                ),
              ),
            ],
          ),
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }


  // ================= ENQUIRY =================
  Widget _enquirySection(int index) {
    final session = payment.sessions[index]; // ✅ CORRECT


    /// ✅ INIT session-wise controller
    treatmentControllers.putIfAbsent(
      index,
          () => TextEditingController(text: session.treatment ?? ""),
    );

    /// ✅ INIT session-wise doctor
    if (!selectedDoctors.containsKey(index) &&
        session.sessionHandled != null &&
        doctors.isNotEmpty) {
      selectedDoctors[index] = doctors.firstWhere(
            (d) =>
        d['id'] == session.sessionHandled ||
            d['name'] == session.sessionHandledDisplay,
        orElse: () => <String, String>{},
      );
    }

    final controller = treatmentControllers[index]!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Add doctor"),
          _doctorDropdown(index), // 👈 session-wise

          const SizedBox(height: 12),

          _label("Add Treatment (type)"),
          TextField(
            controller: controller, // 👈 session-wise
            decoration: InputDecoration(
              hintText: "e.g. Ortho Rehab / Pain Relief",
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: [
              _chip("Reminder: OFF"),
              _chip(
                "Not sent",
                bg: const Color(0xFFFFEDD5),
                textColor: Colors.orange,
              ),
              _chip(
                "Set Reminder",
                bg: const Color(0xFF34D399),
                textColor: Colors.white,
                onTap: () => _setReminder(index),
              ),

              ActionChip(
                backgroundColor: Colors.blue,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                label: creatingRoom
                    ? const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text("Create Room"),
                onPressed: () => _createRoom(index),
              ),

            ],
          ),

          const SizedBox(height: 12),

          _label("Chief complaints"),
          _readonlyBox(session.chiefComplaints ?? "-"),

          const SizedBox(height: 10),

          _label("Notes"),
          _readonlyBox(session.enquiryNotes ?? "-"),
        ],
      ),
    );
  }



  // ================= EXISTING ROOM INFO =================
  Widget _existingRoomInfo(
      int index,
      String? roomName,
      String? patientLink,
      String? doctorLink,
      String? handledBy,
      String? treatment,
      ) {
    final session = widget.payment.sessions[index];
    final cache = roomCache[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Existing Room Info",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _infoRow(
            "Room Name",
            cache?.roomName ?? session.patientRoom?.roomName ?? "-",
          ),

          _linkRow(
            label: "Patient Link",
            url: cache?.patientLink ?? session.patientRoom?.link,
          ),

          _linkRow(
            label: "Doctor Link",
            url: cache?.doctorLink ?? session.doctorRoom?.link,
          ),

          const Divider(height: 24),

          _infoRow(
            "Handled By",
            cache?.handledBy ?? session.sessionHandledDisplay ?? "-",
          ),

          _infoRow(
            "Treatment",
            cache?.treatment ?? session.treatment ?? "-",
          ),
        ],
      ),
    );
  }


  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : "-",
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
  Widget _linkRow({
    required String label,
    required String? url,
  }) {
    final validUrl = url != null && url.startsWith("http");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: validUrl
                ? InkWell(
              onTap: () => _openWebView(url!),
              child: Row(
                children: const [
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Open Link",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            )
                : const Text("-"),
          ),
        ],
      ),
    );
  }
  void _openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommonWebViewPage(
          url: url,
          title: "Video Consultation",
        ),
      ),
    );
  }
  Widget _doctorDropdown(int index) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: loadingDoctors
          ? const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, String>>(
          isExpanded: true,

          /// ✅ session-wise value
          value: selectedDoctors[index],

          hint: const Text(
            "-- select doctor --",
            style: TextStyle(color: Colors.black54),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
          ),
          items: doctors.map((d) {
            return DropdownMenuItem<Map<String, String>>(
              value: d,
              child: Text(
                "${d['name']} (${d['mobile']})",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),

          /// ✅ session-wise update
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedDoctors[index] = val;
              });
            }
          },
        ),
      ),
    );
  }




  Widget _topActionButton(String text, Color bg, Color textColor,
      {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 36,
            child: Center(
              child: Text(text,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
            ),
          ),
        ),
      ),
    );
  }


  Widget _label(String text) =>
      Text(text, style: GoogleFonts.poppins(fontSize: 12));

  Widget _readonlyBox(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 12)),
  );

  Widget _chip(
      String text, {
        Color bg = const Color(0xFFF1F5F9),
        Color textColor = Colors.black,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        backgroundColor: bg,
        label: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: textColor,
          ),
        ),
      ),
    );
  }
  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


}

class _RoomCache {
  final String? roomName;
  final String? patientLink;
  final String? doctorLink;
  final String? handledBy;
  final String? treatment;

  _RoomCache({
    this.roomName,
    this.patientLink,
    this.doctorLink,
    this.handledBy,
    this.treatment,
  });
}

