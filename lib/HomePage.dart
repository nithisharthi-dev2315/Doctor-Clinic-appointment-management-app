import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Apiservice/appointment_api_service.dart';
import 'BookYourAppointmentpage/BookYourAppointment.dart';
import 'ClinicPatientDetailsPage.dart';
import 'CommonWebViewPage.dart';
import 'PatientDetailsPage.dart';
import 'Preferences/AppPreferences.dart';
import 'api/ApiService.dart';
import 'api/Appointment.dart';
import 'model/ClinicPatientResponse.dart';
import 'model/appointment_request.dart';

class HomePage extends StatefulWidget {
  final String doctorId;
  final String username;
  final bool isClinic;
  final VoidCallback onGoToInvoiceTab; // ✅ ADD

  const HomePage({
    super.key,
    required this.doctorId,
    required this.username,
    required this.isClinic,
    required this.onGoToInvoiceTab,


  });

  @override
  State<HomePage> createState() => _HomePageState();
}

enum DateFilterType { today, upcoming, past, custom }

class _HomePageState extends State<HomePage> {
  DateFilterType _filterType = DateFilterType.today;
  DateTime? _selectedDate;
  late Future<List<Appointment>> _appointmentsFuture;

  late Future<List<ClinicPatient>> _clinicPatientsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _init();
    print('widget.doctorId==========${widget.doctorId}');
  }
  Future<void> _init() async {
    String token = await AppPreferences.getAccessToken();
    await AppointmentApiService.regenerateToken(oldToken: token);

  }

  void _loadAppointments() {
    if (widget.isClinic) {
      _clinicPatientsFuture =
          ApiService.getClinicPatients(widget.doctorId);
    } else {
      _appointmentsFuture =
          ApiService.getDoctorAppointments(widget.doctorId);
    }
  }


  Future<void> _onRefresh() async {
    setState(() {
      _loadAppointments();
    });

    if (widget.isClinic) {
      await _clinicPatientsFuture;
    } else {
      await _appointmentsFuture;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Appointments",
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButton: widget.isClinic
          ? _clinicFloatingButtons(context) // ✅ custom rounded button
          : FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookAppointmentPage(
                doctorId: widget.doctorId,
                doctorUsername: widget.username,
                isClinic: widget.isClinic,
              ),
            ),
          );

          if (result == true) {
            setState(() {
              _filterType = DateFilterType.upcoming;
              _loadAppointments();
            });
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),




      body: Column(
        children: [
          _filterBar(context),
          Expanded(
            child: widget.isClinic
                ? _clinicPatientListView()
                : _appointmentListView(),
          ),
        ],
      ),

    );
  }
  Widget _clinicFloatingButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _clinicFabButton(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookAppointmentPage(
                doctorId: widget.doctorId,
                doctorUsername: widget.username,
                isClinic: widget.isClinic,
              ),
            ),
          );

          if (result == true) {
            _onRefresh();
          }
        },
      ),
    );
  }



  Widget _clinicFabButton({
    required VoidCallback onTap,
    LinearGradient? gradient,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }



  Widget _appointmentListView() {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 250),
                Center(child: Text("Failed to load appointments")),
              ],
            ),
          );
        }

        final filtered = _applyDateFilter(snapshot.data ?? []);

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assert/image/No Data.png",
                        width: 180,
                        height: 180,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No appointments found",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final appt = filtered[index];
              return AppointmentCard(
                appointment: appt,
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailsPage(
                        patient: _toAppointmentRequest(appt),
                        appointment: appt,
                        doctorId: widget.doctorId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _clinicPatientListView() {
    return FutureBuilder<List<ClinicPatient>>(
      future: _clinicPatientsFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 250),
                Center(child: Text("Failed to load patients")),
              ],
            ),
          );
        }

        final patients =
        _applyClinicDateFilter(snapshot.data ?? []);

        if (patients.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assert/image/No Data.png",
                        width: 180,
                        height: 180,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No appointments found",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return _clinicPatientCard(p,widget.doctorId);
            },
          ),
        );
      },
    );
  }

  List<ClinicPatient> _applyClinicDateFilter(List<ClinicPatient> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = list.where((p) {
      if (p.treatmentDate == null) return false;

      final localDateTime = p.treatmentDate!.toLocal();
      final treatmentDay = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      switch (_filterType) {
        case DateFilterType.today:
          return treatmentDay == today;

        case DateFilterType.upcoming:
          return treatmentDay.isAtSameMomentAs(today) ||
              treatmentDay.isAfter(today);

        case DateFilterType.past:
          return treatmentDay.isBefore(today);

        case DateFilterType.custom:
          if (_selectedDate == null) return true;
          final selectedDay = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
          return treatmentDay == selectedDay;
      }
    }).toList();

    /// Sort by date + time
    filtered.sort((a, b) {
      final d1 = a.treatmentDate!.toLocal();
      final d2 = b.treatmentDate!.toLocal();
      final dateCompare = d1.compareTo(d2);
      if (dateCompare != 0) return dateCompare;
      return a.treatmentTime.compareTo(b.treatmentTime);
    });

    return filtered;
  }




  void logFilter(String msg) {
    debugPrint("📅 FILTER LOG → $msg");
  }

  Widget _clinicPatientCard(ClinicPatient p,doctorId) {
    final Color statusColor = const Color(0xFF2563EB); // same neutral badge color
    int _currentIndex = 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicPatientDetailsPage(
              patient: p,
              doctorId: doctorId,
            ),
          ),
        );

        if (result == "go_to_invoice_tab") {
          _onRefresh();              // refresh if needed
          widget.onGoToInvoiceTab(); // ✅ change bottom tab
        }
      },


      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 NAME + BADGE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "CLINIC",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 TREATMENT
            Text(
              p.treatment,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 14),

            /// 🔹 DATE & TIME
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  "${_formatDateDDMMYYYY(p.treatmentDate)} • "
                      "${_formatTo12Hour(p.treatmentTime)}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 MOBILE
            Row(
              children: [
                const Icon(
                  Icons.call_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  p.mobile,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final isPm = hour >= 12;
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}";
    } catch (_) {
      return time24;
    }
  }

  String _formatDateDDMMYYYY(DateTime? date) {
    if (date == null) return "--/--/----";

    final local = date.toLocal();
    return "${local.day.toString().padLeft(2, '0')}/"
        "${local.month.toString().padLeft(2, '0')}/"
        "${local.year}";
  }




  AppointmentRequest _toAppointmentRequest(Appointment a) {
    return AppointmentRequest(
      name: a.name,
      age: a.age,
      gender: a.gender,
      phone: a.phone,
      email: a.email,
      primaryConcern: a.primaryConcern ?? '',
      date: a.appointmentDate,
      time: a.appointmentTime,
      whatsAppOptIn: false,
      language: a.language,
      doctorId: widget.doctorId,
      doctorUsername: widget.username,
      couponCode: a.couponCode,
    );
  }



  Widget _filterBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _filterChip("Today", DateFilterType.today),
              const SizedBox(width: 8),
              _filterChip("Upcoming", DateFilterType.upcoming),
              const SizedBox(width: 8),
              _filterChip("Past", DateFilterType.past),
              const SizedBox(width: 8),
              _datePickerButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final yesterday =
        DateTime.now().subtract(const Duration(days: 1));

        final picked = await showDatePicker(
          context: context,
          initialDate: yesterday,
          firstDate: DateTime(2000),
          lastDate: yesterday,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF2563EB),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                ),

              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _filterType = DateFilterType.custom;
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedDate == null
                  ? ""
                  : _formatDate(_selectedDate!),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _filterChip(String label, DateFilterType type) {
    final selected = _filterType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          _filterType = type;
          _selectedDate = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }


  List<Appointment> _applyDateFilter(List<Appointment> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return list.where((a) {
      final date = DateTime.parse(a.appointmentDate);
      final apptDay = DateTime(date.year, date.month, date.day);

      switch (_filterType) {
        case DateFilterType.today:
          return apptDay == today;

        case DateFilterType.upcoming:
          return apptDay.isAtSameMomentAs(today) ||
              apptDay.isAfter(today);

        case DateFilterType.past:
          return apptDay.isBefore(today);

        case DateFilterType.custom:
          if (_selectedDate == null) return true;
          return apptDay.year == _selectedDate!.year &&
              apptDay.month == _selectedDate!.month &&
              apptDay.day == _selectedDate!.day;
      }
    }).toList();
  }


  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onViewDetails;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onViewDetails,

  });


  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'completed':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }


  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(appointment.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onViewDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    appointment.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        getStatusIcon(appointment.status),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointment.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 10),
      
            /// 🔹 PRIMARY CONCERN
            Text(
              appointment.primaryConcern ?? "No primary concern",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 14),
      
            /// 🔹 DATE & TIME
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  "${formatDateDDMMYYYY(appointment.appointmentDate)} • "
                  "${formatTo12Hour(appointment.appointmentTime)}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 16),
      
            /// 🔹 ACTION BUTTON
            if (appointment.videoLink != null &&
                appointment.videoLink!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommonWebViewPage(
                          url: appointment.videoLink!,
                          title: "Video Consultation",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_call, size: 20),
                  label: Text(
                    "Join Video Consultation",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: const Color(0xFF374151),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
      
                ),
              ),
          ],
        ),
      ),
    );
  }

  String formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final isPm = hour >= 12;
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}";
    } catch (_) {
      return time24;
    }
  }

  String formatDateDDMMYYYY(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return "${parsedDate.day.toString().padLeft(2, '0')}/"
          "${parsedDate.month.toString().padLeft(2, '0')}/"
          "${parsedDate.year}";
    } catch (_) {
      return date;
    }
  }
}
class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({super.key});

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  String? selectedPatientId;

  final TextEditingController treatmentCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  String? time24Value;

  DateTime? selectedDate; // ✅ ADD THIS



  List<ClinicPatient> patients = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }



  Future<void> _loadPatients() async {
    final clinicId = await AppPreferences.getClinicId();
    final list = await ApiService.getClinicPatients(clinicId);

    // ✅ unique patient names
    final map = <String, ClinicPatient>{};
    for (final p in list) {
      map.putIfAbsent(p.name.toLowerCase(), () => p);
    }

    if (mounted) {
      setState(() => patients = map.values.toList());
    }
  }
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // 🔹 24-hour format for API
      final hour24 = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      time24Value = "$hour24:$minute";

      // 🔹 12-hour format for UI
      final hour12 = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? "AM" : "PM";

      timeCtrl.text =
      "${hour12.toString().padLeft(2, '0')}:${minute} $period";
    }
  }


  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: media.size.height * 0.70, // 🔑 prevents overflow
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      "Add Invoice",
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
              ),

              const Divider(height: 1),

              /// 🔹 BODY (SCROLLABLE)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _label("Patient"),
                      DropdownButtonFormField<String>(
                        value: selectedPatientId,
                        hint: const Text("Select Patient"),
                        items: patients
                            .map(
                              (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedPatientId = v),
                        decoration: _inputDecoration("Select Patient"),
                      ),

                      const SizedBox(height: 14),

                      _label("Treatment"),
                      TextField(
                        controller: treatmentCtrl,
                        decoration: _inputDecoration("Treatment name"),
                      ),

                      const SizedBox(height: 14),

                      _label("Date"),
                      TextField(
                        controller: dateCtrl,
                        readOnly: true,
                        decoration: _inputDecoration(
                          "DD:MM:YYYY",
                          icon: Icons.calendar_today_outlined,
                        ),
                        onTap: _pickDate,
                      ),


                      const SizedBox(height: 14),

                      _label("Time"),
                      TextField(
                        controller: timeCtrl,
                        readOnly: true,
                        decoration: _inputDecoration(
                          "hh:mm",
                          icon: Icons.access_time,
                        ),
                        onTap: _pickTime,
                      ),

                      const SizedBox(height: 14),

                      _label("Amount"),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Amount (₹)"),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔹 ACTIONS (FIXED BOTTOM)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                        isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                        isSubmitting ? null : _createInvoice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                            : const Text(  "Create Invoice",
                          style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  Future<void> _createInvoice() async {
    if (selectedPatientId == null) {
      _showSnack("Please select patient");
      return;
    }

    if (treatmentCtrl.text.trim().isEmpty) {
      _showSnack("Please enter treatment name");
      return;
    }

    if (dateCtrl.text.trim().isEmpty) {
      _showSnack("Please select treatment date");
      return;
    }

    if (timeCtrl.text.trim().isEmpty) {
      _showSnack("Please select treatment time");
      return;
    }

    if (amountCtrl.text.trim().isEmpty) {
      _showSnack("Please enter amount");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final patient =
      patients.firstWhere((p) => p.id == selectedPatientId);

      debugPrint("🟡 OLD patientId : ${patient.id}");

      final String treatmentDateForApi =
          "${selectedDate!.year}-"
          "${selectedDate!.month.toString().padLeft(2, '0')}-"
          "${selectedDate!.day.toString().padLeft(2, '0')}";


      final patientBody = {
        "name": patient.name,
        "mobile": patient.mobile,
        "treatment": treatmentCtrl.text.trim(),
        "treatmentDate": treatmentDateForApi, // ✅ CORRECT
        "treatmentTime": timeCtrl.text.trim(),
      };

      debugPrint("📤 ADD PATIENT REQUEST:");
      patientBody.forEach((k, v) => debugPrint("   $k : $v"));

      final ClinicPatientResponse? response =
      await AppointmentApiService.addClinicPatient(patientBody);

      if (response == null) {
        throw Exception("Patient creation failed");
      }

      final String newPatientId = response.patientId;

      debugPrint("🟢 NEW patientId : $newPatientId");

      /// 2️⃣ ₹ → PAISE
      final double rupees =
          double.tryParse(amountCtrl.text.trim()) ?? 0;
      final int paise = (rupees * 100).round();

      debugPrint("📤 GENERATE INVOICE REQUEST:");
      debugPrint("   patientId : $newPatientId");
      debugPrint("   amount    : ₹$rupees ($paise paise)");

      /// 3️⃣ GENERATE INVOICE
      final bool invoiceCreated =
      await AppointmentApiService.generateInvoice(
        patientId: newPatientId,
        amount: paise.toString(),
        treatment: treatmentCtrl.text.trim(),
        notes: "",
      );

      if (!invoiceCreated) {
        throw Exception("Invoice creation failed");
      }

      if (!mounted) return;

      setState(() => isSubmitting = false);

      debugPrint("✅ PATIENT & INVOICE CREATED SUCCESSFULLY");
      await _showSuccessDialog();
    } catch (e) {
      debugPrint("❌ ERROR: $e");

      if (!mounted) return;

      setState(() => isSubmitting = false);
      _showSnack("Failed to create invoice");
    }
  }



  Future<void> showInvoiceCreatedDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  "Invoice Created Successfully",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "The invoice has been generated.",
                  style: GoogleFonts.poppins(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Text(
                      "OK",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D9488), // 🏥 Medical teal
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                size: 56,
                color: Color(0xFF16A34A),
              ),
              SizedBox(height: 12),
              Text(
                "Invoice Created",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "The invoice has been created successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);      // ✅ close success dialog
                Navigator.pop(context, true); // ✅ close invoice dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }



  /// ================= HELPERS =================

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

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      suffixIcon: icon != null ? Icon(icon, size: 18) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate = picked;
      dateCtrl.text =
      "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";
    }
  }
}


