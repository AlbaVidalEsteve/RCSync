import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/core/services/image_service.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isEditMode = false.obs;
  RxBool isTranspondersExpanded = false.obs;

  var profileData = <String, dynamic>{}.obs;

  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController newTransponderNumberC;
  late TextEditingController newTransponderLabelC;

  RxList<Map<String, dynamic>> transponders = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> originalTransponders = [];
  var transponderControllers = <String, Map<String, TextEditingController>>{}.obs;

  RxString selectedLanguage = "Español".obs;
  final List<String> languages = ["Español", "English", "Català"];

  RxString selectedThemeName = "Sistema".obs;
  final Map<String, ThemeMode> themeModes = {
    "Claro": ThemeMode.light,
    "Oscuro": ThemeMode.dark,
    "Sistema": ThemeMode.system,
  };

  SupabaseClient client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    newTransponderNumberC = TextEditingController();
    newTransponderLabelC = TextEditingController();
    _initThemeName();
    getProfile();
    getTransponders();
  }

  void _initThemeName() {
    selectedThemeName.value = "Sistema";
  }

  void changeTheme(String? themeName) {
    if (themeName != null && themeModes.containsKey(themeName)) {
      selectedThemeName.value = themeName;
      Get.changeThemeMode(themeModes[themeName]!);
    }
  }

  void changeLanguage(String? lang) {
    if (lang != null) {
      selectedLanguage.value = lang;
      if (lang == "Español") {
        Get.updateLocale(const Locale('es'));
      } else if (lang == "English") {
        Get.updateLocale(const Locale('en'));
      } else if (lang == "Català") {
        Get.updateLocale(const Locale('ca'));
      }
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    newTransponderNumberC.dispose();
    newTransponderLabelC.dispose();
    _disposeTransponderControllers();
    super.onClose();
  }

  void _disposeTransponderControllers() {
    for (var controllers in transponderControllers.values) {
      controllers["number"]?.dispose();
      controllers["label"]?.dispose();
    }
    transponderControllers.clear();
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : RCColors.orange,
      colorText: Colors.white,
      borderRadius: 15,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        )
      ],
    );
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
      debugPrint("Error fetching profile: $e");
      _showSnackbar("Error", "No se pudo cargar el perfil", isError: true);
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

      var list = List<Map<String, dynamic>>.from(res);
      transponders.assignAll(list);
      originalTransponders = list.map((e) => Map<String, dynamic>.from(e)).toList();
      _initTransponderControllers();
    } catch (e) {
      debugPrint("Error fetching transponders: $e");
    }
  }

  void _initTransponderControllers() {
    _disposeTransponderControllers();
    for (var t in transponders) {
      String id = t["id_transponder"].toString();
      transponderControllers[id] = {
        "number": TextEditingController(text: t["number"].toString()),
        "label": TextEditingController(text: t["label"] ?? ""),
      };
    }
  }

  void toggleEdit() {
    isEditMode.value = true;
    originalTransponders = transponders.map((e) => Map<String, dynamic>.from(e)).toList();
    _initTransponderControllers();
  }

  void cancelEdit() {
    isEditMode.value = false;
    getProfile();
    transponders.assignAll(originalTransponders.map((e) => Map<String, dynamic>.from(e)).toList());
    _initTransponderControllers();
    newTransponderNumberC.clear();
    newTransponderLabelC.clear();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        isLoading.value = true;
        File originalFile = File(image.path);

        // Comprimir imagen perfil
        File? compressed = await ImageService.compressProfileImage(originalFile);
        if (compressed == null) compressed = originalFile;

        final userId = client.auth.currentUser!.id;
        final fileExt = 'jpg';
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'perfilfoto/$fileName';

        await client.storage.from('imagenes').upload(
          filePath,
          compressed,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

        final publicUrl = client.storage.from('imagenes').getPublicUrl(filePath);

        await client.from("profiles").update({
          "image_profile": publicUrl,
        }).eq("id_profile", userId);

        profileData.update("image_profile", (_) => publicUrl);

        _showSnackbar("Éxito", "Foto de perfil actualizada correctamente");
      } catch (e) {
        debugPrint("Error uploading image: $e");
        _showSnackbar("Error", "No se pudo subir la imagen", isError: true);
      } finally {
        isLoading.value = false;
      }
    }
  }

  void addTransponder() {
    final numberStr = newTransponderNumberC.text.trim();
    final label = newTransponderLabelC.text.trim();
    final number = int.tryParse(numberStr);

    if (number != null && label.isNotEmpty) {
      final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
      var newT = {
        "id_transponder": tempId,
        "number": number,
        "label": label,
      };

      transponders.insert(0, newT);
      transponderControllers[tempId] = {
        "number": TextEditingController(text: numberStr),
        "label": TextEditingController(text: label),
      };

      newTransponderNumberC.clear();
      newTransponderLabelC.clear();
    } else {
      _showSnackbar("Error", "ts_error".tr, isError: true);
    }
  }

  void removeTransponder(String idTransponder) {
    transponders.removeWhere((t) => t["id_transponder"].toString() == idTransponder);
    transponderControllers[idTransponder]?["number"]?.dispose();
    transponderControllers[idTransponder]?["label"]?.dispose();
    transponderControllers.remove(idTransponder);
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final userId = client.auth.currentUser!.id;

      await client.from("profiles").update({
        "full_name": nameC.text,
      }).eq("id_profile", userId);

      List<String> currentExistingIds = transponders
          .where((t) => !t["id_transponder"].toString().startsWith("temp_"))
          .map((t) => t["id_transponder"].toString())
          .toList();

      List<String> originalIds = originalTransponders.map((t) => t["id_transponder"].toString()).toList();
      List<String> toDelete = originalIds.where((id) => !currentExistingIds.contains(id)).toList();

      if (toDelete.isNotEmpty) {
        await client.from("transponders").delete().filter("id_transponder", "in", toDelete);
      }

      final pendingNumStr = newTransponderNumberC.text.trim();
      final pendingLabel = newTransponderLabelC.text.trim();
      final pendingNum = int.tryParse(pendingNumStr);

      if (pendingNum != null && pendingLabel.isNotEmpty) {
        await client.from("transponders").insert({
          "number": pendingNum,
          "label": pendingLabel,
          "id_profile": userId,
        });
        newTransponderNumberC.clear();
        newTransponderLabelC.clear();
      }

      for (var t in transponders) {
        String id = t["id_transponder"].toString();
        var controllers = transponderControllers[id];
        if (controllers == null) continue;

        String lab = controllers["label"]!.text.trim();

        if (id.startsWith("temp_")) {
          String numStr = controllers["number"]!.text.trim();
          int? numValue = int.tryParse(numStr);
          if (numValue == null) continue;

          await client.from("transponders").insert({
            "number": numValue,
            "label": lab,
            "id_profile": userId,
          });
        } else {
          var original = originalTransponders.firstWhere((ot) => ot["id_transponder"].toString() == id);
          bool hasChanged = lab != (original["label"] ?? "");
          if (hasChanged) {
            await client.from("transponders").update({
              "label": lab,
            }).eq("id_transponder", id);
          }
        }
      }

      isEditMode.value = false;
      _showSnackbar("Éxito", "ts_success".tr);
      await getTransponders();
    } catch (e) {
      debugPrint("Error updating profile: $e");
      _showSnackbar("Error", "No se pudo actualizar el perfil", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}