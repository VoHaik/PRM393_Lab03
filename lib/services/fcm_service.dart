import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Model lưu trữ một notification đã nhận
class AppNotification {
  final String title;
  final String body;
  final DateTime receivedAt;

  AppNotification({
    required this.title,
    required this.body,
    required this.receivedAt,
  });
}

/// Xử lý nhận thông báo Firebase Cloud Messaging (FCM)
/// và lưu trữ danh sách notification trong bộ nhớ.
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Danh sách các notification đã nhận (in-memory)
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Callback để notify ViewModel khi có tin nhắn mới
  VoidCallback? onNewNotification;

  Future<void> initialize() async {
    // 1. Yêu cầu quyền nhận thông báo (quan trọng trên iOS, Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Lấy FCM Token của thiết bị (để test gửi thông báo từ Console)
    final token = await _messaging.getToken();
    debugPrint('[FCM] Device Token: $token');

    // 3. Nhận thông báo khi app đang foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message received: ${message.notification?.title}');
      _addNotification(message);
    });

    // 4. Nhận thông báo khi user tap vào notification (app ở background rồi mở lên)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Opened from notification: ${message.notification?.title}');
      _addNotification(message);
    });

    // 5. Kiểm tra nếu app được mở từ terminated state bằng notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _addNotification(initialMessage);
    }
  }

  void _addNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _notifications.insert(
      0, // Thêm mới nhất lên đầu danh sách
      AppNotification(
        title: notification.title ?? 'No Title',
        body: notification.body ?? '',
        receivedAt: DateTime.now(),
      ),
    );
    onNewNotification?.call();
  }

  void clearNotifications() {
    _notifications.clear();
    onNewNotification?.call();
  }
}
