import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ChampionshipFormController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  var selectedYear = DateTime.now().year.obs;
  var isActive = true.obs;

  // Controlador para nueva categoría
  final newCategoryController = TextEditingController();

  // Lista de categorías disponibles en la BD
  var availableCategories = <Map<String, dynamic>>[].obs;

  // Categorías seleccionadas para este campeonato
  var selectedCategories = <Map<String, dynamic>>[].obs;

  // Control para el dropdown de categorías existentes
  var selectedExistingCategory = Rxn<Map<String, dynamic>>();

  var isLoading = false.obs;
  var isEditing = false.obs;
  int? editingChampionshipId;

  @override
  void onInit() {
    super.onInit();
    loadAvailableCategories();
    if (Get.arguments != null) {
      isEditing.value = true;
      final champ = Get.arguments as Map<String, dynamic>;
      editingChampionshipId = champ['id_championship'];
      nameController.text = champ['name'] ?? '';
      isActive.value = champ['is_active'] ?? true;
      if (champ['year'] != null) {
        selectedYear.value = int.tryParse(champ['year'].toString()) ?? DateTime.now().year;
      }
      _loadSelectedCategories();
    }
  }

  // Cargar todas las categorías disponibles en la BD
  Future<void> loadAvailableCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select('id_category, name')
          .order('name');

      availableCategories.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error cargando categorías: $e");
    }
  }

  // Cargar las categorías ya seleccionadas si estamos editando
  Future<void> _loadSelectedCategories() async {
    if (editingChampionshipId == null) return;
    try {
      final response = await supabase
          .from('championship_categories')
          .select('''
            id_championship_category,
            rulebook_url,
            categories!inner(id_category, name)
          ''')
          .eq('id_championship', editingChampionshipId!);

      for (var item in response) {
        final catData = item['categories'];
        if (catData != null) {
          selectedCategories.add({
            'id_category': catData['id_category'],
            'name': catData['name'],
            'rulebook_url': item['rulebook_url'],
            'id_championship_category': item['id_championship_category'],
            'pdf_file': null,
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando categorías seleccionadas: $e");
    }
  }

  // Añadir categoría existente desde el dropdown
  void addExistingCategory() {
    final category = selectedExistingCategory.value;
    if (category != null) {
      final catName = category['name'];
      if (!selectedCategories.any((c) => c['name'] == catName)) {
        selectedCategories.add({
          'id_category': category['id_category'],
          'name': catName,
          'rulebook_url': null,
          'pdf_file': null,
          'is_new': false,
        });
        selectedExistingCategory.value = null;
      } else {
        Get.snackbar('Atención', 'La categoría ya está en la lista',
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    }
  }

  // Crear y añadir nueva categoría
  Future<void> addNewCategory() async {
    final catName = newCategoryController.text.trim().toUpperCase();
    if (catName.isEmpty) {
      Get.snackbar('Error', 'Ingresa un nombre de categoría',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedCategories.any((c) => c['name'] == catName)) {
      Get.snackbar('Atención', 'La categoría ya está en la lista',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // Verificar si ya existe en la BD
      var existingCat = availableCategories.firstWhereOrNull(
              (c) => c['name'].toString().toUpperCase() == catName);

      int categoryId;
      bool isNew = false;

      if (existingCat != null) {
        categoryId = existingCat['id_category'];
        Get.snackbar('Info', 'La categoría ya existe, se añadirá al campeonato',
            backgroundColor: Colors.blue, colorText: Colors.white);
      } else {
        // Crear nueva categoría
        final newCat = await supabase
            .from('categories')
            .insert({'name': catName})
            .select()
            .single();
        categoryId = newCat['id_category'];
        isNew = true;
        // Recargar lista de categorías disponibles
        await loadAvailableCategories();
      }

      selectedCategories.add({
        'id_category': categoryId,
        'name': catName,
        'rulebook_url': null,
        'pdf_file': null,
        'is_new': isNew,
      });

      newCategoryController.clear();
      Get.snackbar('Éxito', 'Categoría añadida correctamente',
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear la categoría: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void removeCategory(int index) {
    selectedCategories.removeAt(index);
  }

  // Permite seleccionar un PDF para una categoría específica
  Future<void> pickPdfForCategory(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      var updatedCat = Map<String, dynamic>.from(selectedCategories[index]);
      updatedCat['pdf_file'] = result.files.single;
      selectedCategories[index] = updatedCat;
      selectedCategories.refresh();
    }
  }

  Future<void> saveChampionship() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCategories.isEmpty) {
      Get.snackbar('Error', 'Debes añadir al menos una categoría',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final champData = {
        'name': nameController.text.trim(),
        'year': selectedYear.value,
        'is_active': isActive.value,
      };

      int champId;

      if (isEditing.value && editingChampionshipId != null) {
        await supabase.from('championships').update(champData).eq('id_championship', editingChampionshipId!);
        champId = editingChampionshipId!;
        // Eliminar las asociaciones antiguas
        await supabase.from('championship_categories').delete().eq('id_championship', champId);
      } else {
        final insertData = Map.from(champData);
        insertData['id_profile_org'] = supabase.auth.currentUser!.id;
        final response = await supabase.from('championships').insert(insertData).select().single();
        champId = response['id_championship'];
      }

      // Procesar cada categoría seleccionada
      for (var cat in selectedCategories) {
        final categoryId = cat['id_category'];
        String? finalRulebookUrl = cat['rulebook_url'];
        PlatformFile? pdfFile = cat['pdf_file'];

        // Si se seleccionó un nuevo PDF, lo subimos a Supabase Storage
        if (pdfFile != null && pdfFile.path != null) {
          final file = File(pdfFile.path!);
          final fileName = 'reglamento_${champId}_${categoryId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final fullPath = 'reglamentos/$fileName';

          try {
            await supabase.storage.from('imagenes').upload(fullPath, file);
            finalRulebookUrl = supabase.storage.from('imagenes').getPublicUrl(fullPath);
          } catch (e) {
            debugPrint('Error subiendo PDF: $e');
          }
        }

        // Crear la relación campeonato <-> categoría
        await supabase.from('championship_categories').insert({
          'id_championship': champId,
          'id_category': categoryId,
          'rulebook_url': finalRulebookUrl
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (Get.isOverlaysOpen) Get.back();
      Get.back(result: true);

    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'No se pudo guardar: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    newCategoryController.dispose();
    super.onClose();
  }
}