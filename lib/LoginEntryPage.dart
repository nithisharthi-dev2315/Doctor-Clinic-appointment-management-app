import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DoctorLoginPage.dart';
import 'privacy_policy_screen.dart';

enum LoginType { doctor, clinic }

class LoginEntryPage extends StatelessWidget {
  const LoginEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgGradientTop = Color(0xFFDFF6FF);
    const bgGradientBottom = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔹 TOP LOGO SECTION
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 70, bottom: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bgGradientTop, bgGradientBottom],
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assert/image/splashscreen.png",
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              /// 🔹 BODY CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// 📝 TITLE
                    Text(
                      "Get Started",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Choose your role to access your workspace",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 👨‍⚕️ DOCTOR LOGIN
                    _brandLoginCard(
                      title: "Doctor Login",
                      subtitle: "Secure portal for practitioners",
                      imagePath: "assert/image/doctor.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                            const Duration(milliseconds: 300),
                            pageBuilder: (_, __, ___) =>
                            const DoctorLoginPage(
                              loginType: LoginType.doctor,
                            ),
                            transitionsBuilder:
                                (_, animation, __, child) {
                              final tween = Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).chain(
                                CurveTween(
                                    curve: Curves.easeOutCubic),
                              );

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// 🏥 CLINIC LOGIN
                    _brandLoginCard(
                      title: "Clinic Login",
                      subtitle: "Access clinic administration",
                      imagePath:
                      "assert/image/office-building.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorLoginPage(
                              loginType: LoginType.clinic,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    /// ☎ SUPPORT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Need help? ",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _callSupport,
                          child: Text(
                            "Contact support",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// 🔐 PRIVACY POLICY BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Privacy Policy",
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: const Color(0xFF64748B),
                          decoration:
                          TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 PREMIUM LOGIN CARD
  Widget _brandLoginCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 5,
                height: 90,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color:
                                const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color:
                                const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFF1F5F9),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color:
                          Color(0xFF64748B),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ☎ CALL SUPPORT
Future<void> _callSupport() async {
  const phoneNumber = "9429692742";
  final Uri uri = Uri.parse("tel:$phoneNumber");

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    debugPrint("Could not launch dialer");
  }
}
