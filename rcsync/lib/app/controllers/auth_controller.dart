import 'package:get/get.dart';
import 'package:rcsync/app/routes/app_pages.dart';
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
