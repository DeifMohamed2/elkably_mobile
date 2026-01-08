import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/fcm_helper.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel? _channel;
  String? _fcmToken;

  Future<void> initialize() async {
    // Ensure Firebase is initialized
    try {
      // If Firebase is not initialized elsewhere, we attempt to check options
      Firebase.app();
    } catch (_) {
      await Firebase.initializeApp();
    }

    await _requestPermission();
    await _initializeLocalNotifications();
    await _createAndroidChannel();
    await _obtainFcmToken();
    await _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    // Android 13+ runtime permission
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }

    // iOS/Apple permissions via Firebase Messaging
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[NOTIFICATION] Permission requested');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _onNotificationTapped(details);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    debugPrint('[NOTIFICATION] Local notifications initialized');
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse details) {
    debugPrint('[NOTIFICATION] Background tap: ${details.payload}');
    // No navigation here; app will handle once resumed.
  }

  Future<void> _createAndroidChannel() async {
    _channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel!);
    debugPrint('[NOTIFICATION] Android channel created');
  }

  Future<void> _obtainFcmToken() async {
    final token = await FcmHelper.getFcmToken();
    _fcmToken = token;
    debugPrint('[FCM] Token retrieved: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await FcmHelper.refreshToken();
      debugPrint('[FCM] Token refreshed: $_fcmToken');
    });
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('[FCM] Foreground message received: ${message.messageId}');
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Message opened app: ${message.messageId}');
      _handleNotificationTap(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App opened from terminated via notification');
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final payload = jsonEncode(message.data);

    final androidDetails = AndroidNotificationDetails(
      _channel?.id ?? 'high_importance_channel',
      _channel?.name ?? 'High Importance Notifications',
      channelDescription: _channel?.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
    debugPrint('[NOTIFICATION] Local notification shown');
  }

  void _onNotificationTapped(NotificationResponse details) {
    final payload = details.payload;
    if (payload == null) {
      return;
    }
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _routeFromData(data);
    } catch (e) {
      debugPrint('[NOTIFICATION] Tap payload parse error: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    _routeFromData(data);
  }

  void _routeFromData(Map<String, dynamic> data) {
    // TODO: Implement routing based on data contents
    // Example: navigate to announcements or specific screen
    debugPrint('[NOTIFICATION] Handle tap with data: $data');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }
}
