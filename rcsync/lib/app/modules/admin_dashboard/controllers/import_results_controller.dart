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
import 'package:rcsync/app/modules/admin_dashboard/views/import_column_selector.dart';

class ImportResultsController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var events = <RaceEventModel>[].obs;
  var selectedEvent = Rxn<RaceEventModel>();
  var selectedCategory = Rxn<Map<String, dynamic>>();
  var availableCategories = <Map<String, dynamic>>[].obs;
  var importResults = <RaceResultImport>[].obs;
  var previewData = <Map<String, dynamic>>[].obs;

  // Column selection state
  var fileHeaders     = <String>[].obs;
  var filePreviewRows = <List<String>>[].obs;
  var colUuid     = Rxn<int>();
  var colPosition = Rxn<int>();
  var colPole     = Rxn<int>();
  var hasHeader   = true.obs;
  List<List<String>> _allRawRows  = [];
  List<List<String>> _pendingRows = [];

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

  // ── Detección de separador CSV ────────────────────────────────────────────────
  String _detectDelimiter(String firstLine) {
    const candidates = [';', '\t', ',', '|'];
    int maxCount = 0;
    String best = ',';
    for (final c in candidates) {
      final count = c.allMatches(firstLine).length;
      if (count > maxCount) { maxCount = count; best = c; }
    }
    return best;
  }

  // ── Lectura CSV ──────────────────────────────────────────────────────────────
  Future<void> importCsvFile(String filePath) async {
    isLoading.value = true;
    try {
      String input;
      try {
        input = await File(filePath).readAsString(encoding: utf8);
      } catch (_) {
        input = await File(filePath).readAsString(encoding: latin1);
      }

      // Yield so the UI can render the loading indicator before parsing
      await Future<void>.delayed(Duration.zero);

      final firstNl = input.indexOf('\n');
      final firstLine = firstNl >= 0 ? input.substring(0, firstNl) : input;
      final delimiter = _detectDelimiter(firstLine);

      final csvRows = CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
        fieldDelimiter: delimiter,
      ).convert(input);
      if (csvRows.isEmpty) throw Exception('El archivo CSV está vacío');

      final allRows = csvRows
          .map((r) => r.map((c) => c?.toString().trim() ?? '').toList())
          .toList();

      _loadAllRowsAndPreview(allRows);
    } catch (e) {
      Get.snackbar('Error', 'import_err_csv'.tr);
      debugPrint('Error reading CSV: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Lectura Excel ─────────────────────────────────────────────────────────────
  Future<void> importExcelFile(String filePath) async {
    isLoading.value = true;
    try {
      final bytes = await File(filePath).readAsBytes();

      await Future<void>.delayed(Duration.zero);

      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null || sheet.rows.isEmpty) throw Exception('No se encontraron datos en el archivo');

      final allRows = sheet.rows
          .map((r) => r.map((c) => c?.value?.toString().trim() ?? '').toList())
          .toList();

      _loadAllRowsAndPreview(allRows);
    } catch (e) {
      Get.snackbar('Error', 'import_err_file'.tr);
      debugPrint('Error reading Excel: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Todas las filas + preview + selector ─────────────────────────────────────
  void _loadAllRowsAndPreview(List<List<String>> allRows) {
    _allRawRows   = allRows;
    hasHeader.value = true;
    rebuildFromRaw();
    _showColumnSelector();
  }

  void rebuildFromRaw() {
    if (_allRawRows.isEmpty) return;
    if (hasHeader.value) {
      fileHeaders.value = _allRawRows.first;
      _pendingRows = _allRawRows.skip(1)
          .where((r) => r.any((c) => c.isNotEmpty))
          .toList();
    } else {
      final colCount = _allRawRows.first.length;
      fileHeaders.value = List.generate(colCount, (i) => 'Col $i');
      _pendingRows = _allRawRows
          .where((r) => r.any((c) => c.isNotEmpty))
          .toList();
    }
    filePreviewRows.value = _pendingRows.take(4).toList();
    colUuid.value     = null;
    colPosition.value = null;
    colPole.value     = null;
    _autoDetectColumns(fileHeaders);
  }

  void _autoDetectColumns(List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].toLowerCase();
      if (h.contains('id piloto') || h == 'id_piloto' || h == 'uuid') colUuid.value = i;
      if (h == 'clasificacion' || h.contains('clasif') || h == 'pole') colPole.value = i;
      if (h.contains('posici') || h == 'pos' || h == 'position' || h == 'finish') colPosition.value = i;
    }
  }

  void _showColumnSelector() {
    Get.bottomSheet(
      ImportColumnSelectorSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  Future<void> processWithSelectedColumns() async {
    if (colUuid.value == null) return;
    Get.back();

    isLoading.value = true;
    try {
      final uuidIdx = colUuid.value!;
      final posIdx  = colPosition.value;
      final poleIdx = colPole.value;

      // Primera pasada: recoger solo las filas con UUID válido
      final validIds    = <String>[];
      final validRowsData = <List<String>>[];
      final validOrders = <int>[];
      int rowOrder = 0;
      for (final row in _pendingRows) {
        final rawId = uuidIdx < row.length ? row[uuidIdx].trim() : '';
        if (rawId.isEmpty || !_isValidUuid(rawId)) continue;
        rowOrder++;
        validIds.add(rawId);
        validRowsData.add(row);
        validOrders.add(rowOrder);
      }

      if (validIds.isEmpty) {
        Get.snackbar('Aviso', 'import_err_csv'.tr);
        return;
      }

      // Una sola consulta para todos los UUIDs
      final uuids    = validIds.toSet().toList();
      final response = await supabase
          .from('profiles')
          .select('id_profile, full_name')
          .inFilter('id_profile', uuids);

      final pilotMap = <String, Map<String, dynamic>>{
        for (final p in response)
          p['id_profile'] as String: Map<String, dynamic>.from(p as Map),
      };

      // Segunda pasada: construir resultados sin más llamadas a la BD
      final results = <RaceResultImport>[];
      final preview = <Map<String, dynamic>>[];

      for (int i = 0; i < validIds.length; i++) {
        final rawId = validIds[i];
        final row   = validRowsData[i];
        final order = validOrders[i];

        final position = (posIdx != null && posIdx < row.length)
            ? int.tryParse(row[posIdx]) ?? order
            : order;

        final qualyPos = (poleIdx != null && poleIdx < row.length && row[poleIdx] == '1') ? 1 : null;
        final pilot    = pilotMap[rawId];

        results.add(RaceResultImport(
          position:      position,
          pilotName:     pilot?['full_name'] ?? '',
          idProfile:     rawId,
          qualyPosition: qualyPos,
        ));
        preview.add({
          'position':       position,
          'pilot_name':     pilot?['full_name'] ?? '',
          'matched':        pilot != null,
          'id_profile':     rawId,
          'qualy_position': qualyPos,
        });
      }

      importResults.value = results;
      previewData.value   = preview;

      Get.to(() => ImportResultsPreviewView(controller: this, results: results, preview: preview));
    } catch (e) {
      debugPrint('Error processing rows: $e');
      Get.snackbar('Error', 'import_err_csv'.tr);
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

  Future<Map<String, dynamic>?> findPilot(String name, String? transponder) async {
    try {
      // Buscar por número de transponder en la tabla transponders
      if (transponder != null && transponder.isNotEmpty) {
        final transRes = await supabase
            .from('transponders')
            .select('id_profile, profiles(id_profile, full_name)')
            .eq('number', transponder)
            .maybeSingle();

        if (transRes != null && transRes['profiles'] != null) {
          return Map<String, dynamic>.from(transRes['profiles'] as Map);
        }
      }

      // Fallback: buscar por nombre (con límite para evitar matches ambiguos)
      if (name.isNotEmpty) {
        final nameRes = await supabase
            .from('profiles')
            .select('id_profile, full_name')
            .ilike('full_name', '%${name.trim()}%')
            .limit(2);

        final matches = nameRes as List;
        if (matches.length == 1) {
          return Map<String, dynamic>.from(matches.first as Map);
        }
        // Si hay más de un match, no asumir — devolver null para que quede sin asignar
        if (matches.length > 1) {
          debugPrint('findPilot: múltiples coincidencias para "$name", se omite la asignación automática');
        }
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
      Get.snackbar('Error', 'import_err_save'.tr);
      debugPrint('Error saving results: $e');
    } finally {
      isLoading.value = false;
    }
  }
}