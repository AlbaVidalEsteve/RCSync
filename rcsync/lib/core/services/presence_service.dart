import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  PresenceService._();
  static final PresenceService instance = PresenceService._();

  RealtimeChannel? _channel;
  final RxList<Map<String, dynamic>> onlineUsers         = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentlyOfflineUsers = <Map<String, dynamic>>[].obs;

  void startTracking(String userId, String fullName, {String? imageUrl}) {
    _channel?.unsubscribe();
    _channel = Supabase.instance.client.channel('app-presence');
    _channel!
        .onPresenceSync((_) {
          final state = _channel!.presenceState();
          final newOnline = state
              .expand((s) => s.presences)
              .map((p) => Map<String, dynamic>.from(p.payload))
              .toList();

          // Detectar quién acaba de desconectarse comparando con el estado anterior
          final newIds = newOnline
              .map((u) => u['user_id']?.toString())
              .whereType<String>()
              .toSet();

          for (final user in List<Map<String, dynamic>>.from(onlineUsers)) {
            final uid = user['user_id']?.toString();
            if (uid != null && !newIds.contains(uid)) {
              final offlineEntry = Map<String, dynamic>.from(user)
                ..['offline_at'] = DateTime.now().toIso8601String();
              recentlyOfflineUsers.removeWhere(
                (u) => u['user_id']?.toString() == uid,
              );
              recentlyOfflineUsers.insert(0, offlineEntry);
              if (recentlyOfflineUsers.length > 5) {
                recentlyOfflineUsers.removeRange(5, recentlyOfflineUsers.length);
              }
            }
          }

          onlineUsers.assignAll(newOnline);
        })
        .subscribe((status, error) async {
          if (error != null) debugPrint('Presence error: $error');
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _channel!.track({
              'user_id':  userId,
              'full_name': fullName,
              'image_url': imageUrl ?? '',
              'online_at': DateTime.now().toIso8601String(),
            });
          }
        });
  }

  void stopTracking() {
    _channel?.unsubscribe();
    _channel = null;
    onlineUsers.clear();
  }
}
