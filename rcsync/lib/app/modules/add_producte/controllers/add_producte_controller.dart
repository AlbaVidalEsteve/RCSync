import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_notes/app/data/models/supermercats_model.dart';


class AddProducteController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController producteC = TextEditingController();
  TextEditingController quantitatC = TextEditingController();
  SupabaseClient client = Supabase.instance.client;

  // Usamos un tipo opcional para evitar errores si los argumentos fallan
  Supermercat? supermercat;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Supermercat) {
      supermercat = Get.arguments as Supermercat;
    } else {
      print("Error: No se recibió el objeto Supermercats en los argumentos");
    }
  }

  Future<bool> addProducte() async {
    // 1. Verificación básica
    if (producteC.text.isEmpty || quantitatC.text.isEmpty || supermercat == null) {
      Get.snackbar("Error", "Faltan datos o el supermercado no es válido");
      return false;
    }

    try {
      isLoading.value = true;

      // 2. Obtener el ID interno del usuario
      final userRes = await client
          .from("users")
          .select("id")
          .eq("uid", client.auth.currentUser!.id)
          .single();

      int userId = userRes["id"];

      // 3. Insertar el producto vinculado al supermercado
      await client.from("llista_compra").insert({
        "user_id": userId,
        "producte": producteC.text,
        "quantitat": quantitatC.text,
        "supermercat_id": supermercat!.id,
        "created_at": DateTime.now().toIso8601String(),
      });

      return true; // Éxito
    } catch (e) {
      print("Error al insertar producto: $e");
      Get.snackbar("Error", "No se pudo guardar el producto");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}