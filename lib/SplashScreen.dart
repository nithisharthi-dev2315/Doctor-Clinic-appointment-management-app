import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LoginEntryPage.dart';
import 'MainScreen.dart';
import 'Preferences/AppPreferences.dart';
import 'api/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = AppPreferences.isLoggedIn();

    final clinicId = AppPreferences.getClinicId();
    final doctorId = AppPreferences.getDoctorId();

    final username = AppPreferences.getUsername();
    final email = AppPreferences.getEmail();
    final mobile = AppPreferences.getMobile();
    final role = AppPreferences.getRole();

    if (!mounted) return;

    if (isLoggedIn && clinicId.isNotEmpty && role == "clinic") {
      /// 🏥 CLINIC LOGIN
      final user = UserModel(
        id: clinicId,
        username: username,
        email: email,
        mobileNo: mobile,
        role: role,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            doctorId: clinicId,
            user: user,
          ),
        ),
      );
      return;
    }

    if (isLoggedIn && doctorId.isNotEmpty && role == "doctor") {
      /// 👨‍⚕️ DOCTOR LOGIN
      final user = UserModel(
        id: doctorId,
        username: username,
        email: email,
        mobileNo: mobile,
        role: role,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            doctorId: doctorId,
            user: user,
          ),
        ),
      );
      return;
    }

    /// ❌ NOT LOGGED IN
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginEntryPage(),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assert/image/splashscreen.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

