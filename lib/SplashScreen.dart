import 'package:doctorclinic/MobileNumberPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LoginEntryPage.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  LoginEntryPage()),
      );
    });
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
