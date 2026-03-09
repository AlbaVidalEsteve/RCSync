import 'package:get/get.dart';
import 'package:supabase_notes/app/routes/app_pages.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  Timer? authTimer;
  SupabaseClient client = Supabase.instance.client;
  Future<void> logout() async {
    try {
      await client.auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar("ERROR", "No se pudo cerrar sesión: $e");
    }
  }

  Future<void> autoLogout() async {
    if (authTimer != null) {
      authTimer!.cancel();
    }

    authTimer = Timer(const Duration(seconds: 36000), () async {
      await client.auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    }); // after login will run auto logout after 1 hours
  }

  Future<void> resetTimer() async {
    if (authTimer != null) {
      authTimer!.cancel();
      authTimer = null;
    }
  }
}
