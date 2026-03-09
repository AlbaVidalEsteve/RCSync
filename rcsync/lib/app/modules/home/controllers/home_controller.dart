import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_notes/app/data/models/supermercats_model.dart';

class HomeController extends GetxController {
  RxList<Supermercat> allSupermarkets = <Supermercat>[].obs;
  RxBool isLoading = false.obs;
  SupabaseClient client = Supabase.instance.client;

  Future<void> getAllSupermarquets() async {
    try {
      final response = await client
          .from("supermercats")
          .select()
          .order("id", ascending: false);
      
      allSupermarkets.assignAll(Supermercat.fromJsonList(response));
    } catch (e) {
      print("Error fetching supermarkets: $e");
    }
  }

  Future<void> deleteSupermercat(int id) async {
    try {
      await client.from("supermercats").delete().eq("id", id);
      allSupermarkets.removeWhere((element) => element.id == id);
      Get.snackbar("Success", "Supermercat eliminat correctament");
    } catch (e) {
      print("Error deleting supermarket: $e");
      Get.snackbar("Error", "No s'ha pogut eliminar el supermercat");
    }
  }
}
