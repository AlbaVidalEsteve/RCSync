import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  Timer? authTimer;
  SupabaseClient client = Supabase.instance.client;
  RxBool isPasswordRecoveryMode = false.obs;

  StreamSubscription<AuthState>? _authSubscription;

  static const _themeMap = {
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
    'system': ThemeMode.system,
  };

  static const _localeMap = {
    'es': Locale('es'),
    'en': Locale('en'),
    'ca': Locale('ca'),
    'fr': Locale('fr'),
    'pt': Locale('pt'),
    'de': Locale('de'),
    'gl': Locale('gl'),
    'eu': Locale('eu'),
  };

  @override
  void onInit() {
    super.onInit();

    // Sesión ya activa al arrancar
    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      _applyPreferences(currentUser.id);
      NotificationService.instance.subscribeToNotifications(currentUser.id);
    }

    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        isPasswordRecoveryMode.value = true;
        Get.offAllNamed(Routes.RESET_PASSWORD);
      }
      if ((data.event == AuthChangeEvent.signedIn ||
              data.event == AuthChangeEvent.initialSession) &&
          data.session?.user != null) {
        NotificationService.instance.subscribeToNotifications(data.session!.user.id);
        _applyPreferences(data.session!.user.id);
      }
      if (data.event == AuthChangeEvent.signedOut) {
        NotificationService.instance.unsubscribeFromNotifications();
      }
    });
  }

  Future<void> _applyPreferences(String userId) async {
    try {
      final res = await client
          .from('profiles')
          .select('theme, language')
          .eq('id_profile', userId)
          .single();

      final theme = res['theme'] as String? ?? 'dark';
      final lang = res['language'] as String? ?? 'es';

      Get.changeThemeMode(_themeMap[theme] ?? ThemeMode.dark);
      Get.updateLocale(_localeMap[lang] ?? const Locale('es'));
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
  Future<void> logout() async {
    try {
      await client.auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint('Error on logout: $e');
      Get.snackbar('Error', 'error_logout'.tr);
    }
  }

  Future<void> autoLogout() async {
    if (authTimer != null) {
      authTimer!.cancel();
    }
    //Logout despues de 1h
    authTimer = Timer(const Duration(seconds: 36000), () async {
      await client.auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    });
  }

  Future<void> resetTimer() async {
    if (authTimer != null) {
      authTimer!.cancel();
      authTimer = null;
    }
  }
}
