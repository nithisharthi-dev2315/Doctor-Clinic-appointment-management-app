import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LoginEntryPage.dart';
import 'MainScreen.dart';
import 'NotificationService/fcm_token_manager.dart';
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
    debugPrint("🔐 AutoLogin check started...");

    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = AppPreferences.isLoggedIn();
    final clinicId = AppPreferences.getClinicId();
    final doctorId = AppPreferences.getDoctorId();
    final username = AppPreferences.getUsername();
    final email = AppPreferences.getEmail();
    final mobile = AppPreferences.getMobile();
    final role = AppPreferences.getRole();

    // 🔍 PRINT ALL VALUES
    debugPrint("🔐 isLoggedIn: $isLoggedIn");
    debugPrint("🏥 clinicId: $clinicId");
    debugPrint("👨‍⚕️ doctorId: $doctorId");
    debugPrint("👤 username: $username");
    debugPrint("📧 email: $email");
    debugPrint("📱 mobile: $mobile");
    debugPrint("🎭 role: $role");

    if (!mounted) {
      debugPrint("❌ Widget not mounted, stopping auto-login");
      return;
    }

    if (isLoggedIn && clinicId.isNotEmpty && role == "clinic")
    {
      debugPrint("✅ AUTO LOGIN AS CLINIC");

      final user = UserModel(
        id: clinicId,
        username: username,
        email: email,
        mobileNo: mobile,
        role: role,
      );

      FcmTokenManager.init(
        userId:clinicId,
        role: role,
        clinicId: null,
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
      debugPrint("✅ AUTO LOGIN AS DOCTOR");

      final user = UserModel(
        id: doctorId,
        username: username,
        email: email,
        mobileNo: mobile,
        role: role,
      );

      FcmTokenManager.init(
        userId: doctorId,
        role: role,
        clinicId: null,
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

    debugPrint("❌ AUTO LOGIN FAILED → Redirecting to Login");

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

