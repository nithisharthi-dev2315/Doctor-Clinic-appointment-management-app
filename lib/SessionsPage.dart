import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Apiservice/appointment_api_service.dart';
import 'SessionDetailsPage.dart';
import 'model/DoctorPayment.dart';

enum DateFilterType { today, upcoming, custom }

class SessionsPage extends StatefulWidget {
  final String doctorId;
  final String username;

  const SessionsPage({
    super.key,
    required this.doctorId,
    required this.username,
  });

  @override
  State<SessionsPage> createState() => SessionsPageState();
}

class SessionsPageState extends State<SessionsPage> {
  DateFilterType _filterType = DateFilterType.today;
  DateTime? _selectedDate;

  bool _loading = true;
  List<DoctorPayment> _allSessions = [];
  List<DoctorPayment> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  // =========================
  // 🔹 LOAD SESSIONS
  // =========================
  Future<void> loadSessions() async {
    setState(() => _loading = true);

    try {
      final data = await AppointmentApiService.getDoctorPayments(
        doctorId: widget.doctorId,
        username: widget.username,
      );

      _allSessions = data;
      _applyFilter();
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

  // =========================
  // 🔹 APPLY FILTER
  // =========================
  void _applyFilter() {
    final now = DateTime.now();

    switch (_filterType) {
      case DateFilterType.today:
        _filteredSessions = _allSessions.where((e) {
          final d = e.createdAt;
          return d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
        }).toList();
        break;

      case DateFilterType.upcoming:
        _filteredSessions =
            _allSessions.where((e) => e.createdAt.isAfter(now)).toList();
        break;

      case DateFilterType.custom:
        _filteredSessions = _allSessions.where((e) {
          final d = e.createdAt;
          return d.year == _selectedDate!.year &&
              d.month == _selectedDate!.month &&
              d.day == _selectedDate!.day;
        }).toList();
        break;
    }
  }

  // =========================
  // 🔹 STATUS HELPERS
  // =========================
  Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF2563EB);
      case 'completed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  // =========================
  // 🔹 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Session History",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        iconTheme:
        const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Column(
        children: [
          _filterBar(context),
          Expanded(child: _sessionsList()),
        ],
      ),
    );
  }

  // =========================
  // 🔹 FILTER BAR
  // =========================
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
          _pastDatePicker(context),
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
          _applyFilter();
        });
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB)
              : const Color(0xFFF1F5F9),
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

  Widget _pastDatePicker(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final yesterday =
        DateTime.now().subtract(const Duration(days: 1));

        final picked = await showDatePicker(
          context: context,
          initialDate: yesterday,
          firstDate: DateTime(2000),
          lastDate: yesterday,
        );

        if (picked != null) {
          setState(() {
            _filterType = DateFilterType.custom;
            _selectedDate = picked;
            _applyFilter();
          });
        }
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  : DateFormat("dd MMM yyyy")
                  .format(_selectedDate!),
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

  // =========================
  // 🔹 SESSIONS LIST
  // =========================
  Widget _sessionsList() {
    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: loadSessions,
      child: _loading
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 250),
          Center(child: CircularProgressIndicator()),
        ],
      )
          : _filteredSessions.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assert/image/session.png",
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No payment history found",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      )

          : ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSessions.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = _filteredSessions[index];
          final statusColor =
          getPaymentStatusColor(item.status);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// CUSTOMER + STATUS
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.customer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6),
                      decoration: BoxDecoration(
                        color:
                        statusColor.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            getPaymentStatusIcon(
                                item.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "📞 ${item.customer.contact}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  item.packageSnapshot.packageName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),

                Text(
                  item.packageSnapshot.concern,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      "${item.sessions.length} session(s)",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat(
                          "dd MMM yyyy, hh:mm a")
                          .format(item.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                        const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



