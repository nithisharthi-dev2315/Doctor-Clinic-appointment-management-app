import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ClinicInvoiceTab.dart';
import 'HomePage.dart';
import 'PaymentHistoryTab.dart';
import 'ProfilePage.dart';
import 'SessionsPage.dart';
import 'api/user_model.dart';
class MainScreen extends StatefulWidget {
  final String doctorId;
  final UserModel user;



   MainScreen({super.key, required this.doctorId, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ClinicInvoiceTabState> _invoiceTabKey =
  GlobalKey<ClinicInvoiceTabState>();


  /// 🔑 PAGE KEYS (DOCTOR ONLY)
  final GlobalKey<SessionsPageState> _sessionsKey =
      GlobalKey<SessionsPageState>();
  final GlobalKey<PaymentHistoryTabState> _paymentKey =
      GlobalKey<PaymentHistoryTabState>();

  late final List<Widget> _pages;

  /// 🎨 COLORS
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color inactiveColor = Color(0xFF94A3B8);
  static const Color bgColor = Colors.white;

  /// 🔐 ROLE CHECK
  bool get isClinic => widget.user.role == "clinic";

  @override
  void initState() {
    super.initState();

    debugPrint("ID       : ${widget.doctorId}");
    debugPrint("Username : ${widget.user.username}");
    debugPrint("Role     : ${widget.user.role}");

    if (isClinic) {
      /// 🏥 CLINIC PAGES
      _pages = [
        HomePage(
          doctorId: widget.doctorId,
          username: widget.user.username,
          isClinic: true,
          onGoToInvoiceTab: () {
            setState(() => _currentIndex = 1);
            _invoiceTabKey.currentState?.reloadInvoices();

          },
        ),
        ClinicInvoiceTab(doctorId: widget.doctorId),
        ProfilePage(user: widget.user),
      ];
    } else {
      /// 👨‍⚕️ DOCTOR PAGES
      _pages = [
        HomePage(
          doctorId: widget.doctorId,
          username: widget.user.username,
          isClinic: false,
          onGoToInvoiceTab: () {},
        ),
        PaymentHistoryTab(
          key: _paymentKey,
          doctorId: widget.doctorId,
          username: widget.user.username,
        ),
        SessionsPage(
          key: _sessionsKey,
          doctorId: widget.doctorId,
          username: widget.user.username,
        ),
        ProfilePage(user: widget.user),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: bgColor),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: bgColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: inactiveColor,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: _onTabChanged,
          items: isClinic
              ? [
                  _navItem(Icons.event, "Home", 0),
                  _navItem(Icons.receipt_long, "Invoices", 1),
                  _navItem(Icons.person, "Profile", 2),
                ]
              : [
                  _navItem(Icons.event, "Appointments", 0),
                  _navItem(Icons.history, "Payments", 1),
                  _navItem(Icons.video_camera_front, "Sessions", 2),
                  _navItem(Icons.person, "Profile", 3),
                ],
        ),
      ),
    );
  }

  /// 🔄 TAB CHANGE HANDLER
  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);

    /// ❗ DOCTOR ONLY ACTIONS
    if (!isClinic) {
      if (index == 2) {
        debugPrint("🔁 Reload Sessions");
        _sessionsKey.currentState?.loadSessions();
      }

      if (index == 1) {
        debugPrint("🔁 Reload Payment History");
        _paymentKey.currentState?.reload();
      }
    }
  }

  /// 🎯 NAV ITEM UI
  BottomNavigationBarItem _navItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: isSelected ? 26 : 22),
      ),
    );
  }
}
