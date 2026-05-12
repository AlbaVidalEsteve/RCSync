import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/routes/app_pages.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();

  SupabaseClient client = Supabase.instance.client;

  Future<bool?> login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar('login_error_title'.tr, 'login_fields_required'.tr);
      return null;
    }

    isLoading.value = true;
    try {
      await client.auth.signInWithPassword(email: emailC.text.trim(), password: passwordC.text);
      Get.offAllNamed(Routes.HOME);
      return true;
    } on AuthException catch (e) {
      debugPrint('AuthException on login: ${e.message}');
      Get.snackbar('login_error_title'.tr, 'login_wrong_credentials'.tr);
    } catch (e) {
      debugPrint('Error on login: $e');
      Get.snackbar('login_error_title'.tr, 'error_generic'.tr);
    } finally {
      isLoading.value = false;
    }
    return null;
  }
}
