import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
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

  // Metodo para seleccionar archivo Excel o CSV
  Future<void> pickAndImportFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final extension = result.files.single.extension?.toLowerCase();

      if (extension == 'csv') {
        await importCsvFile(path);
      } else {
        await importExcelFile(path);
      }
    }
  }

  // Importacion desde CSV
  Future<void> importCsvFile(String filePath) async {
    isLoading.value = true;
    try {
      String input;
      try {
        input = File(filePath).readAsStringSync(encoding: utf8);
      } catch (e) {
        input = File(filePath).readAsStringSync(encoding: latin1);
      }

      final csvRows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(input);

      if (csvRows.isEmpty) throw Exception('El archivo CSV está vacío');

      final headers = csvRows.first.map((e) => e?.toString().trim() ?? '').toList();
      final dataRows = csvRows.skip(1).toList();

      // Detectar columnas
      int? idPilotoCol;
      int? nombreCol;
      int? transponderCol;
      int? clasificacionCol;
      int? vueltasCol;
      int? puntosCol;

      for (int i = 0; i < headers.length; i++) {
        final lowerHeader = headers[i].toLowerCase();
        if (lowerHeader.contains('id piloto') || lowerHeader == 'id_piloto') idPilotoCol = i;
        if (lowerHeader.contains('piloto') || lowerHeader.contains('nombre')) nombreCol = i;
        if (lowerHeader.contains('transponder')) transponderCol = i;
        if (lowerHeader == 'clasificacion') clasificacionCol = i;
        if (lowerHeader.contains('vuelta') || lowerHeader == 'laps') vueltasCol = i;
        if (lowerHeader.contains('puntos') || lowerHeader == 'points') puntosCol = i;
      }

      if (idPilotoCol == null) {
        throw Exception('No se encontró la columna "ID Piloto" en el CSV.');
      }

      final results = <RaceResultImport>[];
      final preview = <Map<String, dynamic>>[];
      int globalPosition = 0;

      for (var row in dataRows) {
        final rawId = row.length > idPilotoCol! ? row[idPilotoCol]?.toString().trim() : null;
        if (rawId == null || rawId.isEmpty) continue;

        if (!_isValidUuid(rawId)) {
          debugPrint('ID inválido: $rawId');
          continue;
        }

        globalPosition++;

        final pilotName = (nombreCol != null && row.length > nombreCol)
            ? row[nombreCol]?.toString().trim() ?? ''
            : '';
        final transponderStr = (transponderCol != null && row.length > transponderCol)
            ? row[transponderCol]?.toString().trim()
            : null;
        final vueltasStr = (vueltasCol != null && row.length > vueltasCol)
            ? row[vueltasCol]?.toString().trim()
            : null;
        final puntosStr = (puntosCol != null && row.length > puntosCol)
            ? row[puntosCol]?.toString().trim()
            : null;

        int? qualyPos;
        if (clasificacionCol != null && row.length > clasificacionCol) {
          final rawQualy = row[clasificacionCol]?.toString().trim();
          if (rawQualy != null && rawQualy.isNotEmpty) {
            qualyPos = int.tryParse(rawQualy);
            if (qualyPos != 1) qualyPos = null;
          }
        }

        final pilot = await _fetchPilotById(rawId);

        results.add(RaceResultImport(
          position: globalPosition,
          pilotName: pilotName.isNotEmpty ? pilotName : (pilot?['full_name'] ?? ''),
          transponderNumber: int.tryParse(transponderStr ?? '0'),
          laps: int.tryParse(vueltasStr ?? '0'),
          points: int.tryParse(puntosStr ?? '0'),
          idProfile: rawId,
          qualyPosition: qualyPos,
        ));

        preview.add({
          'position': globalPosition,
          'pilot_name': pilotName.isNotEmpty ? pilotName : (pilot?['full_name'] ?? ''),
          'transponder': transponderStr,
          'laps': vueltasStr,
          'points': puntosStr,
          'matched': pilot != null,
          'id_profile': rawId,
          'qualy_position': qualyPos,
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
      Get.snackbar('Error', 'Error al leer el CSV: $e');
      debugPrint('Error importing CSV: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidUuid(String uuid) {
    final regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);
    return regex.hasMatch(uuid);
  }

  Future<Map<String, dynamic>?> _fetchPilotById(String idProfile) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id_profile, full_name')
          .eq('id_profile', idProfile)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching pilot by ID: $e');
      return null;
    }
  }

  // Importación desde Excel
  Future<void> importExcelFile(String filePath) async {
    isLoading.value = true;
    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) {
        throw Exception('No se encontraron datos en el archivo');
      }

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

      var results = <RaceResultImport>[];
      var preview = <Map<String, dynamic>>[];

      for (var i = 1; i < sheet.rows.length; i++) {
        var row = sheet.rows[i];
        if (row.isEmpty) continue;

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
          idProfile: pilot?['id_profile'],
          qualyPosition: null,
        );

        results.add(result);
        preview.add({
          'position': result.position,
          'pilot_name': result.pilotName,
          'transponder': result.transponderNumber,
          'laps': result.laps,
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
      if (transponder != null && transponder.isNotEmpty) {
        final response = await supabase
            .from('profiles')
            .select('id_profile, full_name')
            .eq('id_profile', transponder)
            .maybeSingle();

        if (response != null) return response;
      }

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
      int updated = 0;
      for (var result in importResults) {
        String? pilotId = result.idProfile;
        Map<String, dynamic>? pilot;

        if (pilotId != null) {
          pilot = await _fetchPilotById(pilotId);
        } else {
          pilot = await findPilot(result.pilotName, result.transponderNumber?.toString());
          pilotId = pilot?['id_profile'];
        }

        if (pilotId == null) {
          debugPrint('Piloto no encontrado: ${result.pilotName}');
          continue;
        }

        var existing = await supabase
            .from('registrations')
            .select('id_registration')
            .eq('id_event', selectedEvent.value!.idEvent)
            .eq('id_profile', pilotId)
            .eq('id_category', selectedCategory.value!['id_category'])
            .maybeSingle();

        final qualyPos = (result.qualyPosition == 1) ? 1 : null;

        if (existing != null) {
          await supabase
              .from('registrations')
              .update({
            'position_final': result.position,
            'qualy_position': qualyPos,
          })
              .eq('id_registration', existing['id_registration']);
        } else {
          await supabase.from('registrations').insert({
            'id_event': selectedEvent.value!.idEvent,
            'id_profile': pilotId,
            'id_category': selectedCategory.value!['id_category'],
            'position_final': result.position,
            'qualy_position': qualyPos,
            'status': 'approved',
          });
        }
        updated++;
      }

      Get.back(result: true);
      Get.snackbar('Éxito', 'Se importaron $updated resultados correctamente');

    } catch (e) {
      Get.snackbar('Error', 'Error al guardar resultados: $e');
      debugPrint('Error saving results: $e');
    } finally {
      isLoading.value = false;
    }
  }
}