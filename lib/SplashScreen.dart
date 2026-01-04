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

    final savedUsername = AppPreferences.getUsername();
    final savedPassword = AppPreferences.getPassword();
    final doctorId = AppPreferences.getDoctorId();
    final isLoggedIn = AppPreferences.isLoggedIn();
    final email = AppPreferences.getEmail();
    final mobile = AppPreferences.getMobile();
    final role = AppPreferences.getRole();

    debugPrint('savedUsername: $savedUsername');
    debugPrint('savedPassword: $savedPassword');
    debugPrint('doctorId: $doctorId');
    debugPrint('isLoggedIn: $isLoggedIn');

    if (!mounted) return;

    if (savedUsername.isNotEmpty &&
        savedPassword.isNotEmpty &&
        doctorId.isNotEmpty &&
        isLoggedIn) {
      final user = UserModel(
        id: doctorId,
        username: savedUsername,
        email: email,
        mobileNo: mobile,
        role: role,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(doctorId: doctorId,user:user),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginEntryPage(),
        ),
      );
    }
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

