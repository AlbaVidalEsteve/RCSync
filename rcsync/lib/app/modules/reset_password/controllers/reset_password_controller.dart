import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHiddenNew = true.obs;
  RxBool isHiddenConfirm = true.obs;
  RxInt passwordStrength = 0.obs;

  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmC = TextEditingController();

  final SupabaseClient _client = Supabase.instance.client;

  static final _digitOrSymbolRegex = RegExp(r'[0-9!@#\$%^&*()\-_=+,.?":{}|<>]');

  @override
  void onInit() {
    super.onInit();
    passwordC.addListener(_updateStrength);
  }

  void _updateStrength() {
    final p = passwordC.text;
    if (p.isEmpty)    { passwordStrength.value = 0; return; }
    if (p.length < 8) { passwordStrength.value = 1; return; }
    passwordStrength.value = _digitOrSymbolRegex.hasMatch(p) ? 3 : 2;
  }

  @override
  void onClose() {
    passwordC.removeListener(_updateStrength);
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
    if (password.length < 8) {
      Get.snackbar('ERROR', 'reg_pass_too_short'.tr);
      return;
    }
    if (!_digitOrSymbolRegex.hasMatch(password)) {
      Get.snackbar('ERROR', 'reg_pass_needs_number'.tr);
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
