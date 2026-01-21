import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'NotificationService/NotificationService.dart';
import 'NotificationService/fcm_token_manager.dart';
import 'Preferences/AppPreferences.dart';
import 'SplashScreen.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService.instance.init();
  await AppPreferences.init();
  FcmTokenManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zeromedixine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
