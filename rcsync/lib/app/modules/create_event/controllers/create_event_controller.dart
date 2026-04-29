import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rcsync/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:rcsync/core/services/image_service.dart';

class CreateEventController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final prizeController = TextEditingController(text: '0');
  final descriptionController = TextEditingController();

  var eventDateIni = Rxn<DateTime>();
  var eventDateFin = Rxn<DateTime>();
  var eventRegIni = Rxn<DateTime>();
  var eventRegFin = Rxn<DateTime>();

  var championshipsList = <Map<String, dynamic>>[].obs;
  var circuitsList = <Map<String, dynamic>>[].obs;
  var selectedChampionshipId = Rxn<int>();
  var selectedCircuitId = Rxn<int>();

  var selectedImage = Rxn<PlatformFile>();
  var existingImageUrl = RxnString();

  var isLoading = false.obs;
  var isEditing = false.obs;
  int? editingEventId;

  @override
  void onInit() {
    super.onInit();
    _loadDependencies().then((_) => _checkIfEditing());
  }

  Future<void> _loadDependencies() async {
    try {
      final champs = await supabase.from('championships').select('id_championship, name').eq('is_active', true).order('year', ascending: false);
      championshipsList.value = champs;
      final circs = await supabase.from('circuits').select('id_circuit, name');
      circuitsList.value = circs;
    } catch (e) {
      debugPrint("Error dependencias: $e");
    }
  }

  void _checkIfEditing() {
    if (Get.arguments != null && Get.arguments is RaceEventModel) {
      isEditing.value = true;
      final event = Get.arguments as RaceEventModel;
      editingEventId = event.idEvent;
      nameController.text = event.name;
      prizeController.text = event.prize.toString();
      descriptionController.text = event.description ?? '';
      eventDateIni.value = event.eventDateIni;
      eventDateFin.value = event.eventDateFin;
      eventRegIni.value = event.eventRegIni;
      eventRegFin.value = event.eventRegFin;
      existingImageUrl.value = event.imageEvent;
      if (championshipsList.any((c) => c['id_championship'] == event.idChampionship)) selectedChampionshipId.value = event.idChampionship;
      if (circuitsList.any((c) => c['id_circuit'] == event.idCircuit)) selectedCircuitId.value = event.idCircuit;
    }
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null) selectedImage.value = result.files.first;
  }

  Future<void> pickDate(BuildContext context, Rxn<DateTime> targetDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) targetDate.value = picked;
  }

  Future<void> saveEvent() async {
    if (isLoading.value) return;

    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      String? finalImageUrl = existingImageUrl.value;
      if (selectedImage.value != null && selectedImage.value!.bytes != null) {
        // comprimir imagen evetno
        if (selectedImage.value!.path != null) {
          File originalFile = File(selectedImage.value!.path!);
          File? compressed = await ImageService.compressEventImage(originalFile);
          final bytesToUpload = compressed != null ? await compressed.readAsBytes() : selectedImage.value!.bytes;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.value!.name}';
          await supabase.storage.from('imagenes').uploadBinary('eventosfoto/$fileName', bytesToUpload!);
          finalImageUrl = supabase.storage.from('imagenes').getPublicUrl('eventosfoto/$fileName');
        } else {
          // controlar error path
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.value!.name}';
          await supabase.storage.from('imagenes').uploadBinary('eventosfoto/$fileName', selectedImage.value!.bytes!);
          finalImageUrl = supabase.storage.from('imagenes').getPublicUrl('eventosfoto/$fileName');
        }
      }

      final eventData = {
        'name': nameController.text,
        'prize': int.tryParse(prizeController.text) ?? 0,
        'image_event': finalImageUrl,
        'description': descriptionController.text,
        'id_championship': selectedChampionshipId.value,
        'id_circuit': selectedCircuitId.value,
        'event_date_ini': eventDateIni.value?.toIso8601String(),
        'event_date_fin': eventDateFin.value?.toIso8601String(),
        'event_reg_ini': eventRegIni.value?.toIso8601String(),
        'event_reg_fin': eventRegFin.value?.toIso8601String(),
      };

      if (isEditing.value) {
        await supabase.from('events').update(eventData).eq('id_event', editingEventId!);
      } else {
        await supabase.from('events').insert(eventData);
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().getEvents();
      }

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.back(result: true);
      });

    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'No se pudo guardar: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}