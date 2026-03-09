import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_notes/app/data/models/productes_model.dart';
import 'package:supabase_notes/app/data/models/supermercats_model.dart';

class ListController extends GetxController {
  RxList<Producte> allProductes = <Producte>[].obs;
  SupabaseClient client = Supabase.instance.client;

  // Almacenamos el supermercado actual que viene de los argumentos
  Supermercat? currentSupermercat;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is Supermercat) {
        currentSupermercat = Get.arguments as Supermercat;
      } else {
        print("Error: Los argumentos no son de tipo Supermercats. Recibido: ${Get.arguments.runtimeType}");
      }
    }
  }

  Future<void> getAllProductes() async {
    if (currentSupermercat == null) return;
    try {
      // Filtramos por supermercat_id para que solo salgan sus productos
      final response = await client
          .from("llista_compra")
          .select()
          .eq("supermercat_id", currentSupermercat!.id!)
          .order("id", ascending: false);

      final data = response as List<dynamic>;
      allProductes.value = data.map((e) => Producte.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los productos");
      print(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await client.from("llista_compra").delete().match({"id": id});

      // Actualizamos la lista local después de borrar para que Obx reaccione
      allProductes.removeWhere((element) => element.id == id);
      Get.snackbar("Éxito", "Producto eliminado correctamente");
    } catch (e) {
      Get.snackbar("Error", "No se pudo eliminar el producto");
    }
  }
}