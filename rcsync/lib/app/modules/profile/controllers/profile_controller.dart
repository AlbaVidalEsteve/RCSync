import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/routes/app_pages.dart';


class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isEditMode = false.obs;
  
  // Perfil del usuario
  var profileData = <String, dynamic>{}.obs;
  
  // Controllers para los campos editables
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController newTransponderC;

  // Lista de transponders reactiva
  RxList<Map<String, dynamic>> transponders = <Map<String, dynamic>>[].obs;

  SupabaseClient client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    newTransponderC = TextEditingController();
    getProfile();
    getTransponders();
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    newTransponderC.dispose();
    super.onClose();
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      final userId = client.auth.currentUser!.id;
      
      final res = await client
          .from("profiles")
          .select()
          .eq("id_profile", userId)
          .single();
      
      profileData.value = res;
      nameC.text = res["full_name"] ?? "";
      emailC.text = client.auth.currentUser!.email ?? "";

    } catch (e) {
      print("Error fetching profile: $e");
      Get.snackbar("Error", "No se pudo cargar el perfil");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTransponders() async {
    try {
      final userId = client.auth.currentUser!.id;
      final res = await client
          .from("transponders")
          .select()
          .eq("id_profile", userId)
          .order("created_at", ascending: false);
      
      transponders.assignAll(List<Map<String, dynamic>>.from(res));
    } catch (e) {
      print("Error fetching transponders: $e");
    }
  }

  void toggleEdit() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      // Revertir cambios si cancelamos? O simplemente dejar que guarde.
      getProfile();
      getTransponders();
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        isLoading.value = true;
        final file = File(image.path);
        final userId = client.auth.currentUser!.id;
        final fileExt = image.path.split('.').last;
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'avatars/$fileName';

        // Subir a Supabase Storage
        await client.storage.from('profiles').upload(filePath, file);

        // Obtener URL pública
        final publicUrl = client.storage.from('profiles').getPublicUrl(filePath);

        // Actualizar tabla profiles
        await client.from("profiles").update({
          "image_profile": publicUrl,
        }).eq("id_profile", userId);

        profileData.update("image_profile", (_) => publicUrl);
        Get.snackbar("Éxito", "Foto de perfil actualizada");
      } catch (e) {
        print("Error uploading image: $e");
        Get.snackbar("Error", "No se pudo subir la imagen");
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> addTransponder() async {
    final number = int.tryParse(newTransponderC.text.trim());
    if (number != null) {
      try {
        final userId = client.auth.currentUser!.id;
        final res = await client.from("transponders").insert({
          "number": number,
          "id_profile": userId,
          "label": "Transponder ${transponders.length + 1}",
        }).select().single();
        
        transponders.insert(0, res);
        newTransponderC.clear();
      } catch (e) {
        Get.snackbar("Error", "No se pudo añadir el transponder");
      }
    } else {
      Get.snackbar("Error", "El número de transponder debe ser válido");
    }
  }

  Future<void> removeTransponder(String idTransponder) async {
    try {
      await client.from("transponders").delete().eq("id_transponder", idTransponder);
      transponders.removeWhere((t) => t["id_transponder"] == idTransponder);
    } catch (e) {
      Get.snackbar("Error", "No se pudo eliminar el transponder");
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final userId = client.auth.currentUser!.id;

      await client.from("profiles").update({
        "full_name": nameC.text,
      }).eq("id_profile", userId);

      isEditMode.value = false;
      Get.snackbar("Éxito", "Perfil actualizado correctamente");
    } catch (e) {
      Get.snackbar("Error", "No se pudo actualizar el perfil");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
