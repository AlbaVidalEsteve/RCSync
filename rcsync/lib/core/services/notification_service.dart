import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  RealtimeChannel? _channel;

  static const _channelId   = 'rcsync_main';
  static const _channelName = 'RCSync';
  static const _channelDesc = 'Eventos, inscripciones y resultados';

  // Only supported on mobile platforms
  static bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (!_isMobile) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings     = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // High-priority channel (Android 8+)
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId, _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ));

    // Runtime permission (Android 13+)
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Call on login to start listening to the `notifications` table.
  void subscribeToNotifications(String userId) {
    // Always cancel the previous channel before creating a new one.
    // Without this, calling subscribeToNotifications twice (which happens on
    // cold start when both the currentUser check AND initialSession event fire)
    // leaves an orphaned channel that is never closed.
    _channel?.unsubscribe();
    _channel = null;

    _channel = Supabase.instance.client
        .channel('db-notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            _show(
              record['title']?.toString() ?? 'RCSync',
              record['body']?.toString() ?? '',
            );
          },
        )
        .subscribe((status, error) {
          if (error != null) {
            debugPrint('Notification channel error: $error');
          }
          debugPrint('Notification channel status: $status');
        });
  }

  /// Call on logout to stop listening.
  void unsubscribeFromNotifications() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void _show(String title, String body) {
    if (!_isMobile) return;
    try {
      _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId, _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
}
