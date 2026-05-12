import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  PresenceService._();
  static final PresenceService instance = PresenceService._();

  RealtimeChannel? _channel;
  final RxList<Map<String, dynamic>> onlineUsers = <Map<String, dynamic>>[].obs;

  void startTracking(String userId, String fullName, {String? imageUrl}) {
    _channel?.unsubscribe();
    _channel = Supabase.instance.client.channel('app-presence');
    _channel!
        .onPresenceSync((_) {
          final state = _channel!.presenceState();
          onlineUsers.assignAll(
            state.expand((s) => s.presences).map((p) => p.payload).toList(),
          );
        })
        .subscribe((status, error) async {
          if (error != null) debugPrint('Presence error: $error');
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _channel!.track({
              'user_id': userId,
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
