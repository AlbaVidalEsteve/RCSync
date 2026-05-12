import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHiddenNew = true.obs;
  RxBool isHiddenConfirm = true.obs;
  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmC = TextEditingController();

  final SupabaseClient _client = Supabase.instance.client;

  @override
  void onClose() {
    passwordC.dispose();
    confirmC.dispose();
    super.onClose();
  }

  Future<void> updatePassword() async {
    final password = passwordC.text.trim();
    final confirm = confirmC.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar('ERROR', 'reset_empty'.tr);
      return;
    }
    if (password.length < 6) {
      Get.snackbar('ERROR', 'reset_too_short'.tr);
      return;
    }
    if (password != confirm) {
      Get.snackbar('ERROR', 'reset_mismatch'.tr);
      return;
    }

    isLoading.value = true;
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      await _client.auth.signOut();
      isLoading.value = false;
      Get.snackbar(
        'reset_success_title'.tr,
        'reset_success_msg'.tr,
        duration: const Duration(seconds: 3),
      );
      Get.offAllNamed(Routes.LOGIN);
    } on AuthException catch (e) {
      isLoading.value = false;
      debugPrint('AuthException on reset password: ${e.message}');
      Get.snackbar('Error', 'reset_error'.tr);
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error on reset password: $e');
      Get.snackbar('Error', 'reset_error'.tr);
    }
  }
}
