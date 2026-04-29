import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/modules/profile/controllers/profile_controller.dart';

class EventRegistrationController extends GetxController {
  final supabase = Supabase.instance.client;

  EventDetailsController get eventDetailsController => Get.find<EventDetailsController>();
  ProfileController get profileController => Get.find<ProfileController>();

  var isLoading = false.obs;
  var isRegistering = false.obs;

  // Guardar ID para el INSERT
  var categoriesMap = <String, int>{}.obs;
  var availableCategories = <String>[].obs;

  var selectedCategory = "".obs;
  var selectedTransponderId = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      // Obtener categorías del campeonato
      final response = await supabase
          .from('championship_categories')
          .select('categories(id_category, name)')
          .eq('id_championship', eventDetailsController.event.value.idChampionship ?? 0);

      final List<dynamic> data = response as List<dynamic>;
      Map<String, int> tempMap = {};
      List<String> names = [];

      for (var item in data) {
        final cat = item['categories'];
        if (cat != null) {
          tempMap[cat['name']] = cat['id_category'];
          names.add(cat['name']);
        }
      }

      categoriesMap.assignAll(tempMap);
      availableCategories.assignAll(names);

      if (availableCategories.isNotEmpty) {
        selectedCategory.value = availableCategories.first;
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar las categorías");
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedTransponder(String? transponderId) => selectedTransponderId.value = transponderId ?? "";
  void setSelectedCategory(String? categoryName) => selectedCategory.value = categoryName ?? "";

  Future<void> registerPilot() async {
    if (selectedCategory.value.isEmpty || selectedTransponderId.value.isEmpty) {
      Get.snackbar("Campos incompletos", "Por favor, selecciona categoría y transponder",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final String pilotId = profileController.profileData['id_profile'];
    final int categoryId = categoriesMap[selectedCategory.value]!;
    final int eventId = eventDetailsController.event.value.idEvent;

    isRegistering.value = true;
    try {
      //Evitar duplicados
      final checkExisting = await supabase
          .from('registrations')
          .select('id_registration')
          .eq('id_event', eventId)
          .eq('id_profile', pilotId)
          .eq('id_category', categoryId)
          .maybeSingle();

      if (checkExisting != null) {
        Get.snackbar("Aviso", "Ya estás inscrito en esta categoría para este evento",
            backgroundColor: Colors.amber, colorText: Colors.black);
        isRegistering.value = false;
        return;
      }

      // Insertar
      await supabase.from('registrations').insert({
        'id_event': eventId,
        'id_profile': pilotId,
        'id_category': categoryId,
        'transponder_id': selectedTransponderId.value,
        'subcategory': profileController.profileData['subcategory'] ?? 'STOCK',
        'status': 'pending'
      });

      // Navegacion y cierre
      Get.back();
      Get.snackbar("Éxito", "Inscripción completada correctamente",
          backgroundColor: Colors.green, colorText: Colors.white);

      eventDetailsController.fetchRegisteredPilots();

    } catch (e) {
      Get.snackbar("Error", "Hubo un problema con el registro: $e");
    } finally {
      isRegistering.value = false;
    }
  }
}