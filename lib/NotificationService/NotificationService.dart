import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("✅ BACKGROUND MESSAGE RECEIVED");
  debugPrint("🔔 ${message.notification?.title}");
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  bool hasReceivedMessage = false;
  void Function(RemoteMessage message)? onMessageReceived;

  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotification();
    _initFirebaseListeners();
  }

  /// 🔐 Permission
  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotification() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);
  }
  void _initFirebaseListeners() {
    // FOREGROUND
    FirebaseMessaging.onMessage.listen((message) {
      hasReceivedMessage = true;
      _showCustomNotification(message);
      onMessageReceived?.call(message);
    });

    // OPENED FROM NOTIFICATION
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      hasReceivedMessage = true;
      onMessageReceived?.call(message);
    });

    // BACKGROUND
    FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler);
  }
  Future<void> _showCustomNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'No delay important alerts',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.green,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        '',
        contentTitle: '',
        summaryText: 'Zeromedixine',
      ),
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Zeromedixine',
      message.notification?.body ?? '',
      details,
    );
  }

  bool isMessageReceived() => hasReceivedMessage;
}

