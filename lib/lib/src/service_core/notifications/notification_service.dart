import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Must be a top-level function — called when app is terminated or in background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase handles displaying the notification automatically in background/terminated.
}

class NotificationService {
  NotificationService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'dq_orders';
  static const _channelName = 'Order Notifications';

  /// Pending navigation type set when a notification is tapped while app is terminated.
  /// Read and clear this in Bottomnavigation.initState() to handle deep-link on cold start.
  static String? pendingNotificationType;

  /// Callback invoked when a notification is tapped (foreground or background).
  /// Set this after the navigation stack is ready.
  static void Function(String type)? onNotificationTap;

  /// Call once in main() before runApp().
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS: show notification banner even when app is in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _setupLocalNotifications();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Cold-start: app opened via notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      pendingNotificationType = initialMessage.data['type'];
    }
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call('order_confirmed');
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifications for order confirmations',
      importance: Importance.high,
      enableVibration: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static void _handleMessageTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    if (type != null) {
      onNotificationTap?.call(type);
    }
  }

  /// Returns the current FCM token.
  static Future<String?> getToken() => _messaging.getToken();

  /// Stream that emits a new token whenever FCM rotates it.
  static Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
