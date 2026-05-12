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
  final List<String> languages = ["Español", "English", "Català", "Français", "Português", "Deutsch", "Galego", "Euskara"];

  RxString selectedThemeName = "theme_dark".obs;
  final Map<String, ThemeMode> themeModes = {
    "theme_light": ThemeMode.light,
    "theme_dark": ThemeMode.dark,
    "theme_system": ThemeMode.system,
  };

  static const _themeToDb = {"theme_light": "light", "theme_dark": "dark", "theme_system": "system"};
  static const _dbToTheme = {"light": "theme_light", "dark": "theme_dark", "system": "theme_system"};
  static const _langToDb  = {"Español": "es", "English": "en", "Català": "ca", "Français": "fr", "Português": "pt", "Deutsch": "de", "Galego": "gl", "Euskara": "eu"};
  static const _dbToLang  = {"es": "Español", "en": "English", "ca": "Català", "fr": "Français", "pt": "Português", "de": "Deutsch", "gl": "Galego", "eu": "Euskara"};

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
    selectedThemeName.value = "theme_dark";
    selectedLanguage.value = "Español";
  }

  Future<void> changeTheme(String? themeName) async {
    if (themeName == null || !themeModes.containsKey(themeName)) return;
    selectedThemeName.value = themeName;
    Get.changeThemeMode(themeModes[themeName]!);
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await client.from('profiles').update({
        'theme': _themeToDb[themeName],
      }).eq('id_profile', uid);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  Future<void> changeLanguage(String? lang) async {
    if (lang == null) return;
    selectedLanguage.value = lang;
    final code = _langToDb[lang];
    if (code != null) Get.updateLocale(Locale(code));
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await client.from('profiles').update({
        'language': _langToDb[lang],
      }).eq('id_profile', uid);
    } catch (e) {
      debugPrint('Error saving language: $e');
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
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        )
      ],
    );
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      final user = client.auth.currentUser;
      if (user == null) return;

      final res = await client
          .from("profiles")
          .select()
          .eq("id_profile", user.id)
          .single();

      profileData.value = res;
      nameC.text = res["full_name"] ?? "";
      emailC.text = user.email ?? "";
      selectedThemeName.value = _dbToTheme[res["theme"] ?? "dark"] ?? "theme_dark";
      selectedLanguage.value  = _dbToLang[res["language"] ?? "es"] ?? "Español";

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
        compressed ??= originalFile;

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

  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: RCColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'delete_account_title'.tr,
          style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'delete_account_msg'.tr,
          style: TextStyle(color: RCColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr, style: TextStyle(color: RCColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'delete_account_confirm'.tr,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;
    try {
      await client.rpc('delete_user');
      await client.auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint("Error deleting account: $e");
      _showSnackbar('Error', 'delete_account_error'.tr, isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}