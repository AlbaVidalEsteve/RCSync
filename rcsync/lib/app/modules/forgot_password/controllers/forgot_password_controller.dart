import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();

  final SupabaseClient _client = Supabase.instance.client;

  @override
  void onClose() {
    emailC.dispose();
    super.onClose();
  }

  Future<void> sendResetEmail() async {
    final email = emailC.text.trim();
    if (email.isEmpty) {
      Get.snackbar('ERROR', 'forgot_password_empty'.tr);
      return;
    }
    isLoading.value = true;
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'rcsync://reset',
      );
      isLoading.value = false;
      Get.snackbar(
        'forgot_password_success_title'.tr,
        'forgot_password_success_msg'.tr,
        duration: const Duration(seconds: 4),
      );
      Get.back();
    } on AuthException catch (e) {
      isLoading.value = false;
      debugPrint('AuthException on forgot password: ${e.message}');
      Get.snackbar('Error', 'forgot_password_error'.tr);
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error on forgot password: $e');
      Get.snackbar('Error', 'forgot_password_error'.tr);
    }
  }
}
