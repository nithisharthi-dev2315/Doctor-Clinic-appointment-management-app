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
  late List<bool> manualTimeEdited;

  final String _createSessionUrl =
      "https://srv1090011.hstgr.cloud/api/add_sessions/create";

  @override
  void initState() {
    super.initState();

    sessionDates =
    List<DateTime?>.filled(widget.sessionsCount, null);
    sessionTimes =
    List<TimeOfDay?>.filled(widget.sessionsCount, null);
    manualTimeEdited =
    List<bool>.filled(widget.sessionsCount, false);
  }

  // ───────────── FORMATTERS ─────────────

  String _dateText(DateTime? d) =>
      d == null ? "Select date" : DateFormat("dd MMM yyyy").format(d);

  String _uiTime12(TimeOfDay? t) {
    if (t == null) return "Select time";
    final now = DateTime.now();
    final dt =
    DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat("hh:mm a").format(dt);
  }

  String _apiDate(DateTime d) =>
      DateFormat("yyyy-MM-dd").format(d);

  String _apiTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  // ───────────── AUTO APPLY LOGIC (FIXED) ─────────────

  void _applyDatesOnly() {
    if (baseDate == null) return;

    for (int i = 0; i < widget.sessionsCount; i++) {
      sessionDates[i] =
          baseDate!.add(Duration(days: i * intervalDays));
    }
    setState(() {});
  }

  void _applyFromBase() {
    if (baseDate == null || baseTime == null) return;

    for (int i = 0; i < widget.sessionsCount; i++) {
      sessionDates[i] =
          baseDate!.add(Duration(days: i * intervalDays));

      if (!manualTimeEdited[i]) {
        sessionTimes[i] = baseTime;
      }
    }
    setState(() {});
  }

  // ───────────── BUILD PAYLOAD ─────────────

  List<Map<String, dynamic>> _buildSessions() {
    final List<Map<String, dynamic>> list = [];

    for (int i = 0; i < widget.sessionsCount; i++) {
      if (sessionDates[i] == null || sessionTimes[i] == null) {
        return [];
      }

      list.add({
        "index": i + 1,
        "date": _apiDate(sessionDates[i]!),
        "time": _apiTime(sessionTimes[i]!),
      });
    }
    return list;
  }

  // ───────────── SAVE ─────────────

  Future<void> _saveSessions() async {
    final sessions = _buildSessions();
    if (sessions.isEmpty) {
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
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        _toast(data["message"] ?? "Failed");
      }
    } catch (e) {
      _toast("Server error");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ───────────── UI (UNCHANGED) ─────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: double.infinity,
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
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                value: autoApply,
                activeColor: const Color(0xFF2563EB), // ✅ BLUE
                activeTrackColor: const Color(0xFF93C5FD), // light blue track
                contentPadding: EdgeInsets.zero,
                title: const Text("Auto apply from Session 1"),
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
                        onChanged: (v) {
                          intervalDays = int.tryParse(v) ?? 1;
                          if (autoApply && baseDate != null) {
                            _applyDatesOnly();
                          }
                        },
                        decoration: InputDecoration(
                          isDense: true,
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
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
                          : const Text("Save"),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Session ${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
                      lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) {
                      sessionDates[index] = d;
                      if (index == 0) {
                        baseDate = d;
                        if (autoApply) _applyDatesOnly();
                      }
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
                    );
                    if (t != null) {
                      sessionTimes[index] = t;
                      manualTimeEdited[index] = true;

                      if (index == 0) {
                        baseTime = t;
                        if (autoApply) _applyFromBase();
                      }
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
  }) {
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
      SnackBar(content: Text(msg)),
    );
  }
}
