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

  Future<void> initialize() async {
    if (kIsWeb) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings     = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Canal de alta prioridad (Android 8+)
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId, _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ));

    // Permiso en tiempo de ejecución (Android 13+)
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Llama al iniciar sesión para escuchar la tabla `notifications`.
  void subscribeToNotifications(String userId) {
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
        .subscribe();
  }

  /// Llama al cerrar sesión.
  void unsubscribeFromNotifications() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void _show(String title, String body) {
    if (kIsWeb) return;
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
  }
}
