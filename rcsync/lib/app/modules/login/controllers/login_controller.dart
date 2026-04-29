import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/core/theme/rc_colors.dart';


class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();

  SupabaseClient client = Supabase.instance.client;

  Future<bool?> login() async {
    if (emailC.text.isNotEmpty && passwordC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        await client.auth
            .signInWithPassword(email: emailC.text, password: passwordC.text);
        isLoading.value = false;

        Get.defaultDialog(
            barrierDismissible: false,
            title: "Login success",
            middleText: "Will be redirect to Home Page",
            backgroundColor: RCColors.orange);

        await Future.delayed(const Duration(milliseconds: 1500));

        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.offAllNamed(Routes.HOME);

        return true;

      } catch (e) {
        isLoading.value = false;
        Get.snackbar("ERROR", e.toString());
      }
    } else {
      Get.snackbar("ERROR", "Email and password are required");
    }
    return null;
  }
}
