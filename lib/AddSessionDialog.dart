import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ScheduleSessionDialog extends StatefulWidget {
  final String customerName;
  final int sessionsCount;
  final String appointmentId;
  final String sessionId;
  final String assigned;

  const ScheduleSessionDialog({
    super.key,
    required this.customerName,
    required this.sessionsCount,
    required this.appointmentId,
    required this.sessionId,
    required this.assigned,
  });

  @override
  State<ScheduleSessionDialog> createState() => _ScheduleSessionDialogState();
}

class _ScheduleSessionDialogState extends State<ScheduleSessionDialog> {
  bool autoApply = true;
  bool loading = false;

  int intervalDays = 1;

  DateTime? baseDate;
  TimeOfDay? baseTime;

  final TextEditingController intervalController =
  TextEditingController(text: "1");

  late List<DateTime?> sessionDates;
  late List<TimeOfDay?> sessionTimes;

  final String _createSessionUrl =
      "https://srv1090011.hstgr.cloud/api/add_sessions/create";

  @override
  void initState() {
    super.initState();
    sessionDates = List<DateTime?>.filled(widget.sessionsCount, null);
    sessionTimes = List<TimeOfDay?>.filled(widget.sessionsCount, null);
  }

  String _dateText(DateTime? d) =>
      d == null ? "Select date" : DateFormat("dd MMM yyyy").format(d);

  String _uiTime12(TimeOfDay? t) {
    if (t == null) return "Select time";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat("hh:mm a").format(dt);
  }

  String _apiTime24(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String _apiDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

  List<Map<String, dynamic>> _buildSessions() {
    final List<Map<String, dynamic>> list = [];
    for (int i = 0; i < widget.sessionsCount; i++) {
      if (sessionDates[i] == null || sessionTimes[i] == null) continue;
      list.add({
        "index": i + 1,
        "date": _apiDate(sessionDates[i]!),
        "time": _apiTime24(sessionTimes[i]!),
      });
    }
    return list;
  }

  void _applyToAll() {
    if (baseDate == null || baseTime == null) {
      _toast("Select Session 1 date & time");
      return;
    }
    for (int i = 0; i < widget.sessionsCount; i++) {
      sessionDates[i] = baseDate!.add(Duration(days: i * intervalDays));
      sessionTimes[i] = baseTime;
    }
    setState(() {});
  }

  Future<void> _saveSessions() async {
    final sessions = _buildSessions();
    if (sessions.length != widget.sessionsCount) {
      _toast("Please select all sessions");
      return;
    }

    setState(() => loading = true);

    final body = {
      "appointmentId": widget.appointmentId,
      "doctorAssigned": widget.assigned,
      "notes": "",
      "sessionId": widget.sessionId,
      "sessions": sessions,
    };

    try {
      /// 🔹 PRINT REQUEST DETAILS
      debugPrint("📤 API URL: $_createSessionUrl");
      debugPrint("📤 REQUEST HEADERS:");
      debugPrint(
        const JsonEncoder.withIndent('  ').convert({
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );

      debugPrint("📤 REQUEST BODY:");
      debugPrint(const JsonEncoder.withIndent('  ').convert(body));

      final response = await http.post(
        Uri.parse(_createSessionUrl),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      /// 🔹 PRINT RESPONSE DETAILS
      debugPrint("📥 STATUS CODE: ${response.statusCode}");
      debugPrint("📥 RAW RESPONSE BODY:");
      debugPrint(response.body);

      /// 🔹 PARSE RESPONSE
      final data = jsonDecode(response.body);

      /// 🔹 PRINT PARSED RESPONSE (PRETTY)
      debugPrint("📥 PARSED RESPONSE:");
      debugPrint(const JsonEncoder.withIndent('  ').convert(data));

      if (response.statusCode == 200 && data["success"] == true) {
        if (!mounted) return;

        Navigator.pop(context, true);

        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0D9488), // 🔥 teal / green
              behavior: SnackBarBehavior.floating,
              content: Text(
                data["message"] ?? "Sessions scheduled successfully",
                style: const TextStyle(
                  color: Colors.white, // ✅ white text
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );

        });
      } else {
        _toast(data["message"] ?? "Failed to schedule sessions");
      }
    } catch (e, stack) {
      /// 🔹 PRINT FULL ERROR
      debugPrint("❌ API ERROR: $e");
      debugPrint("❌ STACK TRACE: $stack");
      _toast("Server error. Please try again.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      /// 🔥 WIDER DIALOG
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 8, // 👈 smaller = wider
        vertical: 16,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: SizedBox(
        width: double.infinity, // 🔥 FULL WIDTH
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Schedule Sessions",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                value: autoApply,
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF2563EB),
                title: const Text(
                  "Auto apply from Session 1",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text("Interval based scheduling"),
                onChanged: (v) => setState(() => autoApply = v),
              ),

              if (autoApply)
                Row(
                  children: [
                    const Text("Interval (days)"),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: intervalController,
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                        intervalDays = int.tryParse(v) ?? 1,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 14),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.sessionsCount,
                  itemBuilder: (_, i) => _sessionCard(i),
                ),
              ),

              const SizedBox(height: 16),

              /// ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569), // old text color
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB), // old border color
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // 🔥 OLD BLUE
                        foregroundColor: Colors.white,            // WHITE TEXT
                        elevation: 0,                             // OLD FLAT STYLE
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: loading ? null : _saveSessions,
                      child: loading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        "Save",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Session ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _pickerBox(
                  text: _dateText(sessionDates[index]),
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.blue,      // header & selected date
                              onPrimary: Colors.white,   // header text
                              surface: Colors.white,     // dialog background
                              onSurface: Colors.black,   // calendar text
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (d != null) {
                      if (index == 0) baseDate = d;
                      sessionDates[index] = d;
                      if (autoApply && index == 0) _applyToAll();
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pickerBox(
                  text: _uiTime12(sessionTimes[index]),
                  icon: Icons.access_time,
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.blue,      // clock hand & OK button
                              onPrimary: Colors.white,
                              surface: Colors.white,     // dialog background
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (t != null) {
                      if (index == 0) baseTime = t;
                      sessionTimes[index] = t;
                      if (autoApply && index == 0) _applyToAll();
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pickerBox({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  })
  {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            Icon(icon, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D9488), // 🔥 teal
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white, // ✅ white text
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


}

