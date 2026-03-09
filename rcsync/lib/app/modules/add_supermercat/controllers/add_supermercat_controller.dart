import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSupermercatController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  TextEditingController titleC = TextEditingController();
  TextEditingController descC = TextEditingController();
  SupabaseClient client = Supabase.instance.client;

  Future<bool> addSupermercat() async {
    if (titleC.text.isNotEmpty && descC.text.isNotEmpty) {
      try {
        isLoading.value = true;
        final res = await client
            .from("users")
            .select("id")
            .eq("uid", client.auth.currentUser!.id)
            .single();

        int id = res["id"];
        // 2. Insertar el supermercado
        await client.from("supermercats").insert({
          "user_id": id,
          "title": titleC.text,
          "description": descC.text,
        });

        return true;
      } catch (e) {
        print("Error detallado: $e");
        Get.snackbar("Error", "No se pudo añadir el supermercado");
        return false;
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("Aviso", "Todos los campos son obligatorios");
      return false;
    }
  }
}
