import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/home_controller.dart';

class CreateEventController extends GetxController {
  final SupabaseClient client = Supabase.instance.client;
  final isLoading = false.obs;

  // Form keys and controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Image handling
  final ImagePicker _picker = ImagePicker();
  final Rxn<XFile> selectedImage = Rxn<XFile>();

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

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo seleccionar la imagen: $e");
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      final file = File(image.path);
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      // Nueva ruta especificada: carpeta eventosfoto dentro del bucket imagenes
      final String filePath = 'eventosfoto/$fileName';

      await client.storage.from('imagenes').upload(
        filePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String publicUrl = client.storage.from('imagenes').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
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
      
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await _uploadImage(selectedImage.value!);
        if (imageUrl == null) {
           Get.snackbar("Error", "No se pudo subir la imagen al servidor");
           isLoading.value = false;
           return;
        }
      }

      final eventData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'event_date_ini': startDate.value!.toIso8601String(),
        'event_date_fin': endDate.value!.toIso8601String(),
        'event_reg_ini': regStartDate.value?.toIso8601String(),
        'event_reg_fin': regEndDate.value?.toIso8601String(),
        'image_event': imageUrl,
        'id_circuit': selectedCircuitId.value,
        'id_championship': selectedChampionshipId.value,
        'status': 'active',
      };

      await client.from('events').insert(eventData);

      Get.back();
      Get.snackbar("Éxito", "Evento creado correctamente", backgroundColor: Colors.green, colorText: Colors.white);
      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().getEvents();
      }
      
    } on PostgrestException catch (e) {
      // Simplificado para evitar errores de compilación según la versión de la librería
      print("DATABASE ERROR: ${e.message} (Code: ${e.code})");
      
      String errorMsg = e.message;
      if (e.code == '23505') {
        errorMsg = "Ya existe un registro con estos datos. Verifica que el nombre sea único.";
      }
      
      Get.snackbar(
        "Error de Base de Datos", 
        errorMsg, 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white,
        duration: const Duration(seconds: 8)
      );
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un error inesperado: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
