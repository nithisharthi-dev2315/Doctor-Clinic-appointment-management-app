import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Apiservice/appointment_api_service.dart';
import '../SessionUpdateRequest.dart';
import '../model/DoctorPayment.dart';

class EditSessionsDialog extends StatefulWidget {
  final DoctorPayment payment;

  const EditSessionsDialog({
    super.key,
    required this.payment,
  });

  @override
  State<EditSessionsDialog> createState() => _EditSessionsDialogState();
}

class _EditSessionsDialogState extends State<EditSessionsDialog> {
  bool autoApply = true;
  bool saving = false;
  int intervalDays = 1;

  final TextEditingController intervalController =
  TextEditingController(text: "1");

  late List<DateTime?> sessionDates;
  late List<TimeOfDay?> sessionTimes;

  DateTime? baseDate;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    sessionDates = widget.payment.sessions
        .map((e) => DateTime(
      e.scheduledAt.year,
      e.scheduledAt.month,
      e.scheduledAt.day,
    ))
        .toList();

    sessionTimes = widget.payment.sessions
        .map((e) => TimeOfDay(
      hour: e.scheduledAt.hour,
      minute: e.scheduledAt.minute,
    ))
        .toList();

    if (sessionDates.isNotEmpty) baseDate = sessionDates.first;
  }

  // ================= FORMATTERS =================
  String _dateText(DateTime? d) =>
      d == null ? "Select date" : DateFormat("dd MMM yyyy").format(d);

  String _uiTime12(TimeOfDay? t) {
    if (t == null) return "Select time";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat("hh:mm a").format(dt);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= HEADER =================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Sessions",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.payment.packageSnapshot.packageName,
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

            // ================= AUTO APPLY =================
            SwitchListTile(
              value: autoApply,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2563EB),
              title: const Text(
                "Auto apply from Session 1",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text("Date interval based scheduling"),
              onChanged: (v) {
                setState(() => autoApply = v);

                if (v && baseDate != null) {
                  _applyToAllDates();
                  setState(() {});
                }
              },
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
                          _applyToAllDates();
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 14),

            // ================= SESSION LIST =================
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sessionDates.length,
                itemBuilder: (_, i) => _sessionCard(i),
              ),
            ),

            const SizedBox(height: 16),

            // ================= ACTION BUTTONS =================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: saving ? null : _save,
                    child: saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                    "Update",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    ),
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

  // ================= SESSION CARD =================
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
                  onTap: () => _pickDate(index),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pickerBox(
                  text: _uiTime12(sessionTimes[index]),
                  icon: Icons.access_time,
                  onTap: () => _pickTime(index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PICKERS =================
  Future<void> _pickDate(int index) async {
    final d = await showDatePicker(
      context: context,
      initialDate: sessionDates[index] ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white, // ✅ white background
              headerBackgroundColor: Colors.white,
              headerForegroundColor: Colors.black,
              surfaceTintColor: Colors.white,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488), // teal highlight
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (d == null) return;

    sessionDates[index] = d;

    if (autoApply && index == 0) {
      baseDate = d;
      _applyToAllDates();
    }

    setState(() {});
  }


  Future<void> _pickTime(int index) async {
    final t = await showTimePicker(
      context: context,
      initialTime: sessionTimes[index] ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: Colors.white, // ✅ picker background
                hourMinuteTextColor: Colors.black,
                dayPeriodTextColor: Colors.black,
                dialHandColor: Color(0xFF0D9488), // teal hand
                dialBackgroundColor: Color(0xFFF1F5F9),
                entryModeIconColor: Colors.black,
              ),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0D9488), // OK / SELECT button
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (t == null) return;

    sessionTimes[index] = t;
    setState(() {});
  }


  // ================= AUTO APPLY DATE ONLY =================
  void _applyToAllDates() {
    if (baseDate == null) return;

    for (int i = 0; i < sessionDates.length; i++) {
      sessionDates[i] =
          baseDate!.add(Duration(days: i * intervalDays));
    }
  }

// ================= SAVE =================
  Future<void> _save() async {
    setState(() => saving = true);

    try {
      // 🔹 1. Build API payload
      final updateItems = List.generate(sessionDates.length, (i) {
        final d = sessionDates[i]!;
        final t = sessionTimes[i]!;

        return SessionUpdateItem(
          index: i + 1,
          dateTime: DateTime(
            d.year,
            d.month,
            d.day,
            t.hour,
            t.minute,
          ),
        );
      });

      // 🔹 2. Call API
      await AppointmentApiService.updateSessions(
        SessionUpdateRequest(
          addSessionId: widget.payment.id,
          sessions: updateItems,
        ),
      );

      // 🔹 3. Build UPDATED SessionSlot list (LOCAL STATE)
      final updatedSessions =
      List.generate(widget.payment.sessions.length, (i) {
        final old = widget.payment.sessions[i];
        final dt = updateItems[i].dateTime;

        return SessionSlot(
          index: old.index,
          date: DateFormat("yyyy-MM-dd").format(dt),
          time: DateFormat("HH:mm").format(dt),
          scheduledAt: dt,
          sendReminder: old.sendReminder,

          // 🔒 preserve existing values
          treatment: old.treatment,
          sessionHandled: old.sessionHandled,
          sessionHandledDisplay: old.sessionHandledDisplay,
          chiefComplaints: old.chiefComplaints,
          enquiryNotes: old.enquiryNotes,
          enquiryUpdatedBy: old.enquiryUpdatedBy,
          enquiryUpdatedAt: old.enquiryUpdatedAt,
          patientRoom: old.patientRoom,
          doctorRoom: old.doctorRoom,
        );
      });

      // 🔹 4. Return UPDATED DoctorPayment (DO NOT just return true)
      Navigator.pop(
        context,
        DoctorPayment(
          id: widget.payment.id,
          appointmentId: widget.payment.appointmentId,
          session: widget.payment.session,
          doctorAssigned: widget.payment.doctorAssigned,
          packageSnapshot: widget.payment.packageSnapshot,
          sessions: updatedSessions,
          status: widget.payment.status,
          createdAt: widget.payment.createdAt,
          updatedAt: DateTime.now(),
          customer: widget.payment.customer,
          appointment: widget.payment.appointment,
          createdByDoctor: widget.payment.createdByDoctor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update sessions")),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }


  // ================= PICKER BOX =================
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
}






