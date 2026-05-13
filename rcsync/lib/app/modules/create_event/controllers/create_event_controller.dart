import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rcsync/app/modules/home/controllers/home_controller.dart';
import 'package:rcsync/core/services/image_service.dart';

class CreateEventController extends GetxController {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final nameController        = TextEditingController();
  final prizeController       = TextEditingController(text: '0');
  final bonusPointsController = TextEditingController(text: '0');
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
      nameController.text        = event.name;
      prizeController.text       = event.prize.toString();
      bonusPointsController.text = event.bonusPoints.toString();
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
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedImage.value!.name}';
        Uint8List bytesToUpload;

        if (selectedImage.value!.path != null) {
          final originalFile = File(selectedImage.value!.path!);
          final compressed = await ImageService.compressEventImage(originalFile);
          bytesToUpload = compressed != null
              ? await compressed.readAsBytes()
              : selectedImage.value!.bytes!;
        } else {
          bytesToUpload = selectedImage.value!.bytes!;
        }

        await supabase.storage.from('imagenes').uploadBinary('eventosfoto/$fileName', bytesToUpload);
        finalImageUrl = supabase.storage.from('imagenes').getPublicUrl('eventosfoto/$fileName');
      }

      final eventData = {
        'name': nameController.text,
        'prize': int.tryParse(prizeController.text) ?? 0,
        'bonus_points': int.tryParse(bonusPointsController.text) ?? 0,
        'image_event': finalImageUrl,
        'description': descriptionController.text,
        'id_championship': selectedChampionshipId.value,
        'id_circuit': selectedCircuitId.value,
        'event_date_ini': eventDateIni.value?.toIso8601String(),
        'event_date_fin': eventDateFin.value?.toIso8601String(),
        'event_reg_ini': eventRegIni.value?.toIso8601String(),
        'event_reg_fin': eventRegFin.value?.toIso8601String(),
      };

      final wasEditing = isEditing.value;
      final eventName  = nameController.text;

      if (wasEditing) {
        await supabase.from('events').update(eventData).eq('id_event', editingEventId!);
      } else {
        await supabase.from('events').insert(eventData);
      }

      Get.back(result: true);

      // Defer the reload until after the navigation animation frame completes,
      // avoiding a rendering bottleneck on Windows when getEvents() triggers
      // heavy calendar widget rebuilds during the transition.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().getEvents();
        }
      });

      if (!wasEditing) {
        Future.microtask(() async {
          try {
            await supabase.rpc('send_new_event_notifications', params: {
              'p_event_name': eventName,
            });
          } catch (e) {
            debugPrint('Notification error: $e');
          }
        });
      }

    } catch (e) {
      debugPrint('Error saving event: $e');
      Get.snackbar('Error', 'No se pudo guardar el evento. Inténtalo de nuevo.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}