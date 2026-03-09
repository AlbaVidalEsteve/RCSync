import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/supermercats_model.dart';


class EditSupermercatController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  TextEditingController titleC = TextEditingController();
  TextEditingController descC = TextEditingController();
  SupabaseClient client = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    // Cargamos los datos actuales en los controladores de texto al iniciar
    if (Get.arguments != null && Get.arguments is Supermercat) {
      Supermercat s = Get.arguments as Supermercat;
      titleC.text = s.title ?? "";
      descC.text = s.description ?? "";
    }
  }

  Future<bool> editSupermercat(int id) async {
    if (titleC.text.isNotEmpty && descC.text.isNotEmpty) {
      try {
        isLoading.value = true;
        await client
            .from("supermercats")
            .update({
          "title": titleC.text,
          "description": descC.text
        })
            .eq("id", id);

        return true;
      } catch (e) {
        Get.snackbar("Error", "No s'ha pogut actualitzar");
        return false;
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Aviso", "Els campos no pueden estar vacíos");
      return false;
    }
  }
}
