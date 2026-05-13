import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  RxInt passwordStrength = 0.obs;

  final fullNameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient client = Supabase.instance.client;

  static final _emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final _digitOrSymbolRegex = RegExp(r'[0-9!@#\$%^&*()\-_=+,.?":{}|<>]');

  @override
  void onInit() {
    super.onInit();
    passwordC.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final p = passwordC.text;
    if (p.isEmpty) { passwordStrength.value = 0; return; }
    if (p.length < 8) { passwordStrength.value = 1; return; }
    passwordStrength.value = _digitOrSymbolRegex.hasMatch(p) ? 3 : 2;
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> signUp() async {
    final name     = fullNameC.text.trim();
    final email    = emailC.text.trim();
    final password = passwordC.text;
    final confirm  = confirmPasswordC.text;

    if (name.length < 2) {
      Get.snackbar('Error', 'reg_name_too_short'.tr); return;
    }
    if (!_emailRegex.hasMatch(email)) {
      Get.snackbar('Error', 'reg_email_invalid'.tr); return;
    }
    if (password.length < 8) {
      Get.snackbar('Error', 'reg_pass_too_short'.tr); return;
    }
    if (!_digitOrSymbolRegex.hasMatch(password)) {
      Get.snackbar('Error', 'reg_pass_needs_number'.tr); return;
    }
    if (password != confirm) {
      Get.snackbar('Error', 'reg_pass_mismatch'.tr); return;
    }

    isLoading.value = true;
    try {
      // Crear usuario en auth
      final AuthResponse res = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
        emailRedirectTo: kIsWeb ? null : 'rcsync://login',
      );

      if (res.user == null) throw "Error al crear el usuario";
      final String userId = res.user!.id;

      // El trigger handle_new_user() ya crea el perfil con full_name.
      // Solo actualizamos image_profile si el usuario subió foto Y hay sesión
      // activa (sin confirmación por email). Con email confirmation, res.session
      // es null y cualquier llamada autenticada fallaría (usuario es anon todavía).
      if (profileImage.value != null && res.session != null) {
        try {
          final fileExt = profileImage.value!.path.split('.').last;
          final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final filePath = 'avatars/$fileName';

          await client.storage.from('profiles').upload(filePath, profileImage.value!);
          final imageUrl = client.storage.from('profiles').getPublicUrl(filePath);

          await client.from("profiles").update({
            "image_profile": imageUrl,
          }).eq("id_profile", userId);
        } catch (e) {
          debugPrint("Error subiendo imagen de perfil: $e");
        }
      }

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
      debugPrint("Error: $e");
      Get.snackbar("Error", "Error inesperado al crear el perfil.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordC.removeListener(_updatePasswordStrength);
    fullNameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }
}
