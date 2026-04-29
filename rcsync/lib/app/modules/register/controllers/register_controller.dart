import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  
  final fullNameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient client = Supabase.instance.client;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> signUp() async {
    final name = fullNameC.text.trim();
    final email = emailC.text.trim();
    final password = passwordC.text.trim();
    final confirm = confirmPasswordC.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Todos los campos son obligatorios");
      return;
    }

    if (password != confirm) {
      Get.snackbar("Error", "Las contraseñas no coinciden");
      return;
    }

    isLoading.value = true;
    try {
      // Crear usuario en auth
      final AuthResponse res = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      if (res.user == null) throw "Error al crear el usuario";
      final String userId = res.user!.id;

      // subir imagen opc
      String? imageUrl;
      if (profileImage.value != null) {
        try {
          final fileExt = profileImage.value!.path.split('.').last;
          final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final filePath = 'avatars/$fileName';

          await client.storage.from('profiles').upload(filePath, profileImage.value!);
          imageUrl = client.storage.from('profiles').getPublicUrl(filePath);
        } catch (e) {
          print("Error subiendo imagen: $e");
        }
      }

      // Completar perfil
      await client.from("profiles").upsert({
        "id_profile": userId,
        "full_name": name,
        "image_profile": imageUrl,
      });

      Get.defaultDialog(
        barrierDismissible: false,
        title: "Registro con éxito",
        middleText: "Se ha enviado un correo de confirmación a $email. Por favor, confirma tu cuenta antes de iniciar sesión.",
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.back();
              Get.back();
            }, 
            child: const Text("OK")
          )
        ]
      );

    } on AuthException catch (e) {
      Get.snackbar("Error de Registro", e.message);
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Error inesperado al crear el perfil.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }
}
