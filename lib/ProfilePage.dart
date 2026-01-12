import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoginEntryPage.dart';
import 'Preferences/AppPreferences.dart';
import 'api/user_model.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  /// 🔑 ROLE CHECK
  bool get isClinic => user.role == "clinic";

  /// 🔑 DISPLAY NAME
  String get displayName =>
      isClinic ? user.username : "Dr. ${user.username}";

  /// 🔑 ID LABEL
  String get idLabel => isClinic ? "Clinic ID" : "Doctor ID";

  /// 🔑 ROLE TEXT
  String get roleText => isClinic ? "CLINIC" : "DOCTOR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ------------------------------------------------------------------
            // 🔹 HEADER
            // ------------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 46,
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Color(0xFF2563EB),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// ✅ NAME (Doctor / Clinic)
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ✅ ROLE
                  Text(
                    roleText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ ID (Doctor / Clinic)
            _profileTile(
              icon: Icons.badge_outlined,
              title: idLabel,
              value: user.id,
            ),

            _profileTile(
              icon: Icons.phone_outlined,
              title: "Phone Number",
              value: user.mobileNo,
              onTap: () => _callNumber(user.mobileNo),
            ),

            _profileTile(
              icon: Icons.email_outlined,
              title: "Email Address",
              value: user.email,
              onTap: () => _sendEmail(user.email),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------------------------
            // 🔹 LOGOUT BUTTON
            // ------------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🔹 LOGOUT DIALOG
  // --------------------------------------------------------------------------
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false, // ✅ important
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 42,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Confirm Logout",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Are you sure you want to logout from your account?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(false),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(true),
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true && context.mounted) {
      await AppPreferences.logout();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginEntryPage()),
            (_) => false,
      );
    }
  }


  // --------------------------------------------------------------------------
  // 🔹 PROFILE TILE
  // --------------------------------------------------------------------------
  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
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



  // --------------------------------------------------------------------------
  Future<void> _callNumber(String number) async {
    final uri = Uri.parse("tel:$number");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse("mailto:$email");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
