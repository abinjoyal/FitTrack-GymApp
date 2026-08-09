import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_track/services/notification_service.dart';
import 'package:flutter/foundation.dart';

/// 🔊 TOP-LEVEL BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔥 BACKGROUND MESSAGE RECEIVED: ${message.notification?.title}");
}

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 🔔 INITIALIZE FCM
  static Future<void> init() async {
    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. Request Notification Permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 Notification Permission Status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 3. Get and log FCM token
        String? token = await _messaging.getToken();
        debugPrint('🚀 [FCM Token]: $token');

        // 4. Setup foreground message listener
        _setupForegroundListener();

        // 5. Setup background messaging handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // 6. Handle notification click when app opened from terminated/background states
        _setupInteractionListeners();
      }
    } catch (e) {
      debugPrint('❌ Firebase Cloud Messaging Init Error: $e');
    }
  }

  /// 📱 FOREGROUND MESSAGE LISTENER
  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔥 FOREGROUND MESSAGE RECEIVED: ${message.notification?.title}');

      final notification = message.notification;
      if (notification != null) {
        // Trigger our existing FlutterLocalNotifications system to show a banner!
        NotificationService.showNotification(
          title: notification.title ?? 'FitTrack Notification',
          body: notification.body ?? '',
        );
      }
    });
  }

  /// 🎯 OPEN APP ACTION LISTENERS
  static void _setupInteractionListeners() {
    // 1. When the app is in the background and opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🎯 APP OPENED VIA NOTIFICATION: ${message.notification?.title}');
    });

    // 2. When the app is fully terminated and opened via notification tap
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🎯 APP OPENED FROM TERMINATED STATE VIA NOTIFICATION: ${message.notification?.title}');
      }
    });
  }
}
