import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart';
import 'PaymentHistoryTab.dart';
import 'ProfilePage.dart';
import 'SessionsPage.dart';
import 'api/user_model.dart';


import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String doctorId;
  final UserModel user;

  const MainScreen({
    super.key,
    required this.doctorId,
    required this.user,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /// 🔑 KEYS
  final GlobalKey<SessionsPageState> _sessionsKey =
  GlobalKey<SessionsPageState>();
  final GlobalKey<PaymentHistoryTabState> _paymentKey =
  GlobalKey<PaymentHistoryTabState>();

  late final List<Widget> _pages;

  /// 🎨 COLORS
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color inactiveColor = Color(0xFF94A3B8);
  static const Color bgColor = Colors.white;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePage(
        doctorId: widget.doctorId,
        username: widget.user.username,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      /// 🔻 ANIMATED BOTTOM BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: bgColor,

        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: bgColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: inactiveColor,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: _onTabChanged,
          items: [
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

    if (index == 2) {
      debugPrint("🔁 Reload Sessions");
      _sessionsKey.currentState?.loadSessions();
    }

    if (index == 1) {
      debugPrint("🔁 Reload Payment History");
      _paymentKey.currentState?.reload();
    }
  }

  /// 🎯 ANIMATED NAV ITEM
  BottomNavigationBarItem _navItem(
      IconData icon,
      String label,
      int index,
      ) {
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
        child: Icon(
          icon,
          size: isSelected ? 26 : 22,
        ),
      ),
    );
  }
}






