import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/profiles_model.dart';
import 'package:rcsync/core/services/presence_service.dart';

class UserStatsController extends GetxController {
  final _supabase = Supabase.instance.client;

  final RxInt totalUsers    = 0.obs;
  final RxList<ProfileModel> lastRegistered = <ProfileModel>[].obs;
  final RxBool isLoading    = true.obs;

  RxList<Map<String, dynamic>> get onlineUsers =>
      PresenceService.instance.onlineUsers;

  RxList<Map<String, dynamic>> get recentlyOfflineUsers =>
      PresenceService.instance.recentlyOfflineUsers;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Contar usuarios reales de auth.users via función RPC
      final count = await _supabase.rpc('count_auth_users');
      totalUsers.value = (count as int?) ?? 0;

      final recent = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false)
          .limit(5);
      lastRegistered.assignAll(
        (recent as List).map((e) => ProfileModel.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
