import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ChampionshipFormController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  var selectedYear = DateTime.now().year.obs;
  var isActive = true.obs;
  var selectedFile = Rxn<PlatformFile>();
  final categoryController = TextEditingController();
  var categoriesList = <String>[].obs;
  var isLoading = false.obs;
  var isEditing = false.obs;
  int? editingChampionshipId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isEditing.value = true;
      final champ = Get.arguments as Map<String, dynamic>;
      editingChampionshipId = champ['id_championship'];
      nameController.text = champ['name'] ?? '';
      isActive.value = champ['is_active'] ?? true;
      if (champ['year'] != null) selectedYear.value = int.tryParse(champ['year'].toString()) ?? DateTime.now().year;
    }
  }

  void addCategory() {
    String cat = categoryController.text.trim().toUpperCase();
    if (cat.isNotEmpty && !categoriesList.contains(cat)) {
      categoriesList.add(cat);
      categoryController.clear();
    }
  }

  void removeCategory(String cat) => categoriesList.remove(cat);

  Future<void> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) selectedFile.value = result.files.first;
  }

  Future<void> saveChampionship() async {
    // Evitar múltiples ejecuciones
    if (isLoading.value) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;
    
    if (categoriesList.isEmpty && !isEditing.value) {
      Get.snackbar('Error', 'Debes añadir al menos una categoría');
      return;
    }

    isLoading.value = true;
    try {
      String? pdfUrl;
      if (selectedFile.value != null) {
        final bytes = selectedFile.value!.bytes;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedFile.value!.name}';
        await supabase.storage.from('reglamentos').uploadBinary('public/$fileName', bytes!);
        pdfUrl = supabase.storage.from('reglamentos').getPublicUrl('public/$fileName');
      }

      int champId;
      if (isEditing.value && editingChampionshipId != null) {
        final updateData = <String, dynamic>{'name': nameController.text, 'year': selectedYear.value.toString(), 'is_active': isActive.value};
        if (pdfUrl != null) updateData['reglamento_url'] = pdfUrl;
        await supabase.from('championships').update(updateData).eq('id_championship', editingChampionshipId!);
        champId = editingChampionshipId!;
      } else {
        final champResponse = await supabase.from('championships').insert({'name': nameController.text, 'year': selectedYear.value.toString(), 'is_active': isActive.value, 'id_organizer': supabase.auth.currentUser!.id, 'reglamento_url': pdfUrl}).select().single();
        champId = champResponse['id_championship'];
      }

      for (String catName in categoriesList) {
        var catResponse = await supabase.from('categories').select('id_category').eq('name', catName).maybeSingle();
        int categoryId = catResponse != null ? catResponse['id_category'] : (await supabase.from('categories').insert({'name': catName}).select().single())['id_category'];
        try { await supabase.from('championships_categories').insert({'id_championship': champId, 'id_category': categoryId}); } catch (_) {}
      }

      // Solución técnica al error de MouseTracker: esperar al siguiente frame para navegar
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Get.isOverlaysOpen) Get.back(); // Cerrar posibles snacks o diálogos
        Get.back(result: true);
      });

    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'No se pudo guardar: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
