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
  State<ScheduleSessionDialog> createState() =>
      _ScheduleSessionDialogState();
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
    sessionDates =
    List<DateTime?>.filled(widget.sessionsCount, null);
    sessionTimes =
    List<TimeOfDay?>.filled(widget.sessionsCount, null);
  }

  // ───────────────── FORMATTERS ─────────────────

  String _dateText(DateTime? d) =>
      d == null ? "Select date" : DateFormat("dd MMM yyyy").format(d);

  String _uiTime12(TimeOfDay? t) {
    if (t == null) return "Select time";
    final now = DateTime.now();
    return DateFormat("hh:mm a").format(
      DateTime(now.year, now.month, now.day, t.hour, t.minute),
    );
  }

  String _apiTime24(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String _apiDate(DateTime d) =>
      DateFormat("yyyy-MM-dd").format(d);

  // ───────────────── SESSION BUILD ─────────────────

  List<Map<String, dynamic>> _buildSessions() {
    final List<Map<String, dynamic>> list = [];
    for (int i = 0; i < widget.sessionsCount; i++) {
      final date = sessionDates[i];
      final time = sessionTimes[i];
      if (date == null || time == null) continue;
      list.add({
        "index": i + 1,
        "date": _apiDate(date),
        "time": _apiTime24(time),
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
      sessionDates[i] =
          baseDate!.add(Duration(days: i * intervalDays));
      sessionTimes[i] = baseTime;
    }
    setState(() {});
  }

  // ───────────────── SAVE API ─────────────────

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
      final response = await http.post(
        Uri.parse(_createSessionUrl),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        _toast("Sessions scheduled successfully");
        Navigator.pop(context, true);
      } else {
        _toast(data["message"] ?? "Failed to schedule");
      }
    } catch (_) {
      _toast("Server error. Please try again.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // ✅ pure white background
      insetPadding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// HEADER
            Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Schedule Sessions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.customerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 14),

            /// AUTO APPLY
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: autoApply,
              onChanged: (v) => setState(() => autoApply = v),
              title: const Text(
                "Auto apply from Session 1",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text("Interval based scheduling"),
            ),

            if (autoApply)
              Row(
                children: [
                  const Text("Interval (days):"),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: TextField(
                      controller: intervalController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                      intervalDays = int.tryParse(v) ?? 1,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 14),

            /// SESSION LIST
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
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : _saveSessions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white, // ✅ white text
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  Widget _sessionCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Session ${index + 1}",
              style: const TextStyle(
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (d != null) {
                      if (index == 0) baseDate = d;
                      sessionDates[index] = d;
                      if (autoApply && index == 0)
                        _applyToAll();
                      setState(() {});
                    }
                  },
                  child: _inputBox(
                      _dateText(sessionDates[index]),
                      Icons.calendar_today),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) =>
                          MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(
                                alwaysUse24HourFormat:
                                false),
                            child: child!,
                          ),
                    );
                    if (t != null) {
                      if (index == 0) baseTime = t;
                      sessionTimes[index] = t;
                      if (autoApply && index == 0)
                        _applyToAll();
                      setState(() {});
                    }
                  },
                  child: _inputBox(
                      _uiTime12(sessionTimes[index]),
                      Icons.access_time),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _inputBox(String text, IconData icon) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          Icon(icon, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
