import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProducteController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  TextEditingController titleC = TextEditingController();
  TextEditingController descC = TextEditingController();
  SupabaseClient client = Supabase.instance.client;

  Future<bool> editProducte(int id) async {
    if (titleC.text.isNotEmpty && descC.text.isNotEmpty) {
      isLoading.value = true;
      await client
          .from("llista_compra")
          .update({"producte": titleC.text, "quantitat": descC.text}).match({
        "id": id,
      });
      return true;
    } else {
      return false;
    }
  }
}
