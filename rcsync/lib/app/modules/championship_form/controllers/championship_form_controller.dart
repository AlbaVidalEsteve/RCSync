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

  final categoryController = TextEditingController();

  // Ahora manejamos mapas para almacenar el nombre, el id, la URL y el archivo PDF seleccionado
  var categoriesList = <Map<String, dynamic>>[].obs;

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
      if (champ['year'] != null) {
        selectedYear.value = int.tryParse(champ['year'].toString()) ?? DateTime.now().year;
      }
      _loadCategories();
    }
  }

  // Carga las categorías asociadas si estamos editando
  Future<void> _loadCategories() async {
    if (editingChampionshipId == null) return;
    try {
      final response = await supabase
          .from('championship_categories')
          .select('rulebook_url, categories(id_category, name)')
          .eq('id_championship', editingChampionshipId!);

      categoriesList.clear();
      for (var item in response) {
        final catData = item['categories'];
        if (catData != null) {
          categoriesList.add({
            'id_category': catData['id_category'],
            'name': catData['name'],
            'rulebook_url': item['rulebook_url'],
            'pdf_file': null, // Inicialmente null, a menos que el usuario suba uno nuevo
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando categorías: $e");
    }
  }

  void addCategory() {
    String catName = categoryController.text.trim().toUpperCase();
    if (catName.isNotEmpty && !categoriesList.any((c) => c['name'] == catName)) {
      categoriesList.add({
        'name': catName,
        'rulebook_url': null,
        'pdf_file': null
      });
      categoryController.clear();
    } else if (catName.isNotEmpty) {
      Get.snackbar('Atención', 'La categoría ya está en la lista', colorText: Colors.white);
    }
  }

  void removeCategory(int index) {
    categoriesList.removeAt(index);
  }

  // Permite seleccionar un PDF para una categoría específica
  Future<void> pickPdfForCategory(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      var updatedCat = Map<String, dynamic>.from(categoriesList[index]);
      updatedCat['pdf_file'] = result.files.single;
      categoriesList[index] = updatedCat;
      categoriesList.refresh(); // Refresca la vista de Obx
    }
  }

  Future<void> saveChampionship() async {
    if (!formKey.currentState!.validate()) return;
    if (categoriesList.isEmpty) {
      Get.snackbar('Error', 'Debes añadir al menos una categoría', backgroundColor: Colors.red, colorText: Colors.white);
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
        // Eliminamos las asociaciones antiguas para crear las nuevas (evita duplicados)
        // NOTA: Esto eliminará las asociaciones temporales, pero como tenemos guardada la 'rulebook_url'
        // en 'categoriesList', las volveremos a insertar intactas.
        await supabase.from('championship_categories').delete().eq('id_championship', champId);
      } else {
        final Map<String, dynamic> insertData = Map.from(champData);
        insertData['id_profile_org'] = supabase.auth.currentUser!.id;
        final response = await supabase.from('championships').insert(insertData).select().single();
        champId = response['id_championship'];
      }

      // Procesar cada categoría
      for (var cat in categoriesList) {
        String catName = cat['name'];
        int categoryId;

        // Verificar si la categoría base existe
        var catRes = await supabase.from('categories').select('id_category').eq('name', catName).maybeSingle();
        if (catRes != null) {
          categoryId = catRes['id_category'];
        } else {
          final newCat = await supabase.from('categories').insert({'name': catName}).select().single();
          categoryId = newCat['id_category'];
        }

        String? finalRulebookUrl = cat['rulebook_url'];
        PlatformFile? pdfFile = cat['pdf_file'];

        // Si se seleccionó un nuevo PDF, lo subimos a Supabase Storage
        if (pdfFile != null && pdfFile.path != null) {
          final file = File(pdfFile.path!);
          // El nombre base del archivo
          final fileName = 'reglamento_${champId}_${categoryId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          // La ruta completa incluyendo la carpeta dentro del bucket
          final fullPath = 'reglamentos/$fileName';

          try {
            // 1. Apuntamos al bucket 'imagenes' y subimos a la ruta 'reglamentos/...'
            await supabase.storage.from('imagenes').upload(fullPath, file);

            // 2. Pedimos la URL pública apuntando al mismo bucket y ruta
            finalRulebookUrl = supabase.storage.from('imagenes').getPublicUrl(fullPath);
          } catch (e) {
            debugPrint('Error subiendo PDF para $catName: $e');
            Get.snackbar('Error de subida', 'No se pudo subir el PDF de $catName', backgroundColor: Colors.red, colorText: Colors.white);
          }
        }

        // Crear la relación campeonato <-> categoría con la URL del PDF (nueva o la que ya existía)
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
      Get.snackbar('Error', 'No se pudo guardar: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}