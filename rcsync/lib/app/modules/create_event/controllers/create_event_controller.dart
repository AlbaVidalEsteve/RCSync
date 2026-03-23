import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/home_controller.dart';

class CreateEventController extends GetxController {
  final SupabaseClient client = Supabase.instance.client;
  final isLoading = false.obs;

  // Form keys and controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final prizeController = TextEditingController();
  final imageUrlController = TextEditingController();

  // Selected values
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final Rxn<DateTime> regStartDate = Rxn<DateTime>();
  final Rxn<DateTime> regEndDate = Rxn<DateTime>();

  final RxList<Map<String, dynamic>> circuits = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> championships = <Map<String, dynamic>>[].obs;

  final RxnInt selectedCircuitId = RxnInt();
  final RxnInt selectedChampionshipId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      final circuitsData = await client.from('circuits').select('id_circuit, name');
      final championshipsData = await client.from('championships').select('id_championship, name');
      
      circuits.assignAll(List<Map<String, dynamic>>.from(circuitsData));
      championships.assignAll(List<Map<String, dynamic>>.from(championshipsData));
    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar la información inicial: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDate(BuildContext context, Rxn<DateTime> dateTarget) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTarget.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateTarget.value = picked;
    }
  }

  Future<void> createEvent() async {
    if (!formKey.currentState!.validate()) return;
    
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar("Error", "Debes seleccionar las fechas del evento");
      return;
    }

    try {
      isLoading.value = true;
      
      final eventData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'event_date_ini': startDate.value!.toIso8601String(),
        'event_date_fin': endDate.value!.toIso8601String(),
        'event_reg_ini': regStartDate.value?.toIso8601String(),
        'event_reg_fin': regEndDate.value?.toIso8601String(),
        'prize': double.tryParse(prizeController.text) ?? 0.0,
        'image_event': imageUrlController.text,
        'id_circuit': selectedCircuitId.value,
        'id_championship': selectedChampionshipId.value,
      };

      await client.from('events').insert(eventData);

      Get.back();
      Get.snackbar("Éxito", "Evento creado correctamente", backgroundColor: Colors.green, colorText: Colors.white);
      
      // Actualizar la lista de la Home
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().getEvents();
      }
      
    } catch (e) {
      Get.snackbar("Error", "No se pudo crear el evento: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    prizeController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }
}
