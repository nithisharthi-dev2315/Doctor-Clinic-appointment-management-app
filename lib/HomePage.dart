import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BookYourAppointmentpage/BookYourAppointment.dart';
import 'CommonWebViewPage.dart';
import 'PatientDetailsPage.dart';
import 'api/ApiService.dart';
import 'api/Appointment.dart';
import 'model/appointment_request.dart';

class HomePage extends StatefulWidget {
  final String doctorId;
  final String username;
  final bool isClinic;


  const HomePage({
    super.key,
    required this.doctorId,
    required this.username,
    required this.isClinic,

  });

  @override
  State<HomePage> createState() => _HomePageState();
}

enum DateFilterType { today, upcoming, custom }

class _HomePageState extends State<HomePage> {
  DateFilterType _filterType = DateFilterType.today;
  DateTime? _selectedDate;
  late Future<List<Appointment>> _appointmentsFuture;


  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    _appointmentsFuture =
        ApiService.getDoctorAppointments(widget.doctorId);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _appointmentsFuture =
          ApiService.getDoctorAppointments(widget.doctorId);
    });

    // wait for API (optional but recommended)
    await _appointmentsFuture;
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


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => BookAppointmentPage(
                doctorId: widget.doctorId,
                doctorUsername: widget.username,
                  isClinic:widget.isClinic

              ),
              transitionsBuilder: (_, animation, __, child) {
                final tween = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );

          if (result == true) {
            setState(() {
              _filterType = DateFilterType.upcoming;
              _appointmentsFuture =
                  ApiService.getDoctorAppointments(widget.doctorId);
            });
          }

        },


        // ✅ Centered white icon
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),

        // ✅ Perfect circle
        shape: const CircleBorder(),

        // ✅ Background color
        backgroundColor: const Color(0xFF2563EB),

        // Optional
        elevation: 6,
      ),


      body: Column(
        children: [
          _filterBar(context),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {

                // 🔹 LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔹 ERROR
                if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 250),
                        Center(
                          child: Text(
                            "Failed to load appointments",
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allAppointments = snapshot.data ?? [];
                final filtered = _applyDateFilter(allAppointments);

                // 🔹 EMPTY STATE
                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
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

                // 🔹 LIST
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final appt = filtered[index];
                      return AppointmentCard(
                        appointment: appt,
                        onViewDetails: () {


                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (_, __, ___) => PatientDetailsPage(
                                patient: _toAppointmentRequest(appt),
                                appointment: appt,
                                doctorId: widget.doctorId,
                              ),
                              transitionsBuilder: (_, animation, __, child) {
                                final tween = Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).chain(
                                  CurveTween(curve: Curves.easeOutCubic),
                                );

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );

                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          _filterChip("Today", DateFilterType.today),
          const SizedBox(width: 10),
          _filterChip("Upcoming", DateFilterType.upcoming),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              final DateTime yesterday =
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
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),

                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),


                      datePickerTheme: const DatePickerThemeData(
                        backgroundColor: Colors.white,
                        todayForegroundColor:
                        MaterialStatePropertyAll(Colors.grey),
                        todayBackgroundColor:
                        MaterialStatePropertyAll(Colors.transparent),
                      ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedDate == null
                        ? "Past Date"
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
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, DateFilterType type) {
    final selected = _filterType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _filterType = type;
          _selectedDate = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF64748B),
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
