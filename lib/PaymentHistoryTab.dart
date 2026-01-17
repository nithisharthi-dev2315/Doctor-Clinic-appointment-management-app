import 'package:flutter/material.dart';


import 'Apiservice/appointment_api_service.dart';
import 'SessionDetailsPage.dart';
import 'model/PaymentHistoryItem.dart';
import 'model/PaymentHistoryResponse.dart';

class PaymentHistoryTab extends StatefulWidget {
  final String doctorId;
  final String username;

  const PaymentHistoryTab({
    super.key,
    required this.doctorId,
    required this.username,
  });

  @override
  State<PaymentHistoryTab> createState() => PaymentHistoryTabState();
}

class PaymentHistoryTabState extends State<PaymentHistoryTab> {
  late Future<PaymentHistoryResponse> _future;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    _future = AppointmentApiService.getDoctorPaymentHistory(
      doctorId: widget.doctorId,
      username: widget.username,
    );
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reload();
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// APP BAR
      appBar: AppBar(
        title: const Text(
          "Payment History",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      /// BODY WITH SWIPE REFRESH
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<PaymentHistoryResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            }

            final payments = snapshot.data!.payments;

            /// 🔹 EMPTY STATE
            if (payments.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assert/image/No Data.png",
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No payment history found",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            /// 🔹 PAYMENT LIST
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, index) => _paymentCard(payments[index]),
            );
          },
        ),
      ),
    );
  }

  /// 💳 PAYMENT CARD
  Widget _paymentCard(PaymentHistoryItem p) {
    final bool isPaid = p.status.toLowerCase() == "paid";

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) =>
                SessionDetailsPage(payment: p),
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
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              isPaid
                  ? const Color(0xFFEFFDF5)
                  : const Color(0xFFFFFBEB),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PACKAGE + STATUS
/*
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.session.packageName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _statusChip(p.status),
              ],
            ),
*/

           // const SizedBox(height: 10),

            /// AMOUNT
            Text(
              "${currencySymbol(p.currency)}"
                  "${formatAmount(p.amount, p.currency)}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isPaid
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFF59E0B),
              ),
            ),

            const SizedBox(height: 8),

            /// CUSTOMER
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.customer.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// DATE
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(p.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatAmount(dynamic amount, String currency) {
    final int minorUnits = int.tryParse(amount.toString()) ?? 0;

    // Most currencies (INR, USD, EUR) use 2 decimal minor units
    final num value = minorUnits / 100;

    // Remove .00 if not needed
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency; // fallback
    }
  }


  /// STATUS CHIP
  Widget _statusChip(String status) {
    final isPaid = status.toLowerCase() == "paid";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
        isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color:
          isPaid ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}

