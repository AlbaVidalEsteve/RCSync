import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/app/data/models/race_result_import_model.dart';
import 'package:rcsync/app/modules/admin_dashboard/views/import_results_preview_view.dart';

class ImportResultsController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var events = <RaceEventModel>[].obs;
  var selectedEvent = Rxn<RaceEventModel>();
  var selectedCategory = Rxn<Map<String, dynamic>>();
  var availableCategories = <Map<String, dynamic>>[].obs;
  var importResults = <RaceResultImport>[].obs;
  var previewData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('events')
          .select('''
            *,
            circuits (*),
            championships (
              *,
              profiles (*)
            )
          ''')
          .order('event_date_ini', ascending: false);

      events.value = response.map((e) => RaceEventModel.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los eventos');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onEventSelected(RaceEventModel? event) async {
    selectedEvent.value = event;
    if (event != null && event.idChampionship != null) {
      await loadCategoriesForEvent(event.idChampionship!);
    }
  }

  Future<void> loadCategoriesForEvent(int championshipId) async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('championship_categories')
          .select('''
            id_category,
            rulebook_url,
            categories!inner(id_category, name)
          ''')
          .eq('id_championship', championshipId);

      availableCategories.value = response.map((e) => {
        'id_category': e['categories']['id_category'],
        'name': e['categories']['name'],
      }).toList();

      if (availableCategories.isNotEmpty) {
        selectedCategory.value = availableCategories.first;
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndImportExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      await importExcelFile(result.files.single.path!);
    }
  }

  Future<void> importExcelFile(String filePath) async {
    isLoading.value = true;
    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) {
        throw Exception('No se encontraron datos en el archivo');
      }

      // Obtener encabezados excel
      var headers = <String, int>{};
      var firstRow = sheet.rows.first;
      for (var i = 0; i < firstRow.length; i++) {
        final cell = firstRow[i];
        if (cell != null) {
          var cellValue = cell.value?.toString().trim() ?? '';
          if (cellValue.isNotEmpty) {
            headers[cellValue] = i;
          }
        }
      }

      // Procesar datos
      var results = <RaceResultImport>[];
      var preview = <Map<String, dynamic>>[];

      for (var i = 1; i < sheet.rows.length; i++) {
        var row = sheet.rows[i];
        if (row.isEmpty) continue;

        // Verificar si la fila está vacia
        bool isEmptyRow = true;
        for (var cell in row) {
          if (cell != null && cell.value != null && cell.value.toString().trim().isNotEmpty) {
            isEmptyRow = false;
            break;
          }
        }
        if (isEmptyRow) continue;

        var rowData = <String, dynamic>{};
        headers.forEach((key, colIndex) {
          if (colIndex < row.length) {
            final cell = row[colIndex];
            rowData[key] = cell?.value?.toString() ?? '';
          }
        });

        // Buscar piloto por nombre o transponder (SE DEBE CAMBIAR A UUID
        var pilotName = rowData['Nombre']?.toString() ?? rowData['Pilot Name']?.toString() ?? '';
        var transponderNumber = rowData['Transponder Nr 1']?.toString();

        var pilot = await findPilot(pilotName, transponderNumber);

        var result = RaceResultImport(
          position: i,
          pilotName: pilotName,
          transponderNumber: int.tryParse(transponderNumber ?? '0'),
          laps: int.tryParse(rowData['Laps']?.toString() ?? rowData['Vueltas']?.toString() ?? '0'),
          bestLap: rowData['Best Lap']?.toString() ?? rowData['Mejor Vuelta']?.toString(),
          points: int.tryParse(rowData['Points']?.toString() ?? rowData['Puntos']?.toString() ?? '0'),
        );

        results.add(result);
        preview.add({
          'position': result.position,
          'pilot_name': result.pilotName,
          'transponder': result.transponderNumber,
          'laps': result.laps,
          'best_lap': result.bestLap,
          'points': result.points,
          'matched': pilot != null,
        });
      }

      importResults.value = results;
      previewData.value = preview;

      Get.to(() => ImportResultsPreviewView(
        controller: this,
        results: results,
        preview: preview,
      ));

    } catch (e) {
      Get.snackbar('Error', 'Error al leer el archivo: $e');
      debugPrint('Error importing Excel: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> findPilot(String name, String? transponder) async {
    try {
      // Buscar por transponder
      if (transponder != null && transponder.isNotEmpty) {
        final response = await supabase
            .from('profiles')
            .select('id_profile, full_name')
            .eq('id_profile', transponder)
            .maybeSingle();

        if (response != null) return response;
      }

      // Buscar por nombre
      if (name.isNotEmpty) {
        final response = await supabase
            .from('profiles')
            .select('id_profile, full_name')
            .ilike('full_name', '%${name.trim()}%')
            .maybeSingle();

        return response;
      }

      return null;
    } catch (e) {
      debugPrint('Error finding pilot: $e');
      return null;
    }
  }

  Future<void> saveResults() async {
    if (selectedEvent.value == null || selectedCategory.value == null) {
      Get.snackbar('Error', 'Selecciona evento y categoría');
      return;
    }

    isLoading.value = true;
    try {
      for (var result in importResults) {
        var pilot = await findPilot(result.pilotName, result.transponderNumber?.toString());

        if (pilot != null) {
          // Verificar si ya existe registro
          var existing = await supabase
              .from('registrations')
              .select('id_registration')
              .eq('id_event', selectedEvent.value!.idEvent)
              .eq('id_profile', pilot['id_profile'])
              .eq('id_category', selectedCategory.value!['id_category'])
              .maybeSingle();

          if (existing != null) {
            // Actualizar resultado existente
            await supabase
                .from('registrations')
                .update({
              'position_final': result.position,
              'qualy_position': result.position,
            })
                .eq('id_registration', existing['id_registration']);
          } else {
            // Crear nuevo registro
            await supabase.from('registrations').insert({
              'id_event': selectedEvent.value!.idEvent,
              'id_profile': pilot['id_profile'],
              'id_category': selectedCategory.value!['id_category'],
              'position_final': result.position,
              'qualy_position': result.position,
              'status': 'approved',
            });
          }
        }
      }

      Get.back(result: true);
      Get.snackbar('Éxito', 'Resultados importados correctamente');

    } catch (e) {
      Get.snackbar('Error', 'Error al guardar resultados: $e');
      debugPrint('Error saving results: $e');
    } finally {
      isLoading.value = false;
    }
  }
}