import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyRaceResult {
  final String eventName;
  final DateTime? eventDate;
  final String categoryName;
  final String? championshipName;
  final int? championshipYear;
  final int? positionFinal;
  final int? qualyPosition;
  final int idEvent;
  final int? idCategory;
  int totalParticipants;

  MyRaceResult({
    required this.eventName,
    this.eventDate,
    required this.categoryName,
    this.championshipName,
    this.championshipYear,
    this.positionFinal,
    this.qualyPosition,
    required this.idEvent,
    this.idCategory,
    this.totalParticipants = 1,
  });

  double? get relativeScore {
    if (positionFinal == null || totalParticipants <= 1) return null;
    return (totalParticipants - positionFinal!) / (totalParticipants - 1) * 100;
  }
}

class _Pt {
  final double x, y;
  const _Pt(this.x, this.y);
}

Map<String, double>? _linearRegression(List<_Pt> pts) {
  final n = pts.length.toDouble();
  if (n < 2) return null;
  final sx  = pts.fold(0.0, (s, p) => s + p.x);
  final sy  = pts.fold(0.0, (s, p) => s + p.y);
  final sxy = pts.fold(0.0, (s, p) => s + p.x * p.y);
  final sx2 = pts.fold(0.0, (s, p) => s + p.x * p.x);
  final denom = n * sx2 - sx * sx;
  if (denom == 0) return null;
  final slope = (n * sxy - sx * sy) / denom;
  final intercept = (sy - slope * sx) / n;
  return {'slope': slope, 'intercept': intercept};
}

class MyResultsController extends GetxController {
  final _supabase = Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  RxBool isLoading = false.obs;
  final List<MyRaceResult> _allResults = [];

  RxString selectedChampionship = ''.obs;
  RxString selectedCategory     = ''.obs;
  RxList<String> championships  = <String>[].obs;
  RxList<String> categories     = <String>[].obs;
  RxList<MyRaceResult> filteredResults = <MyRaceResult>[].obs;

  // ── stats básicas ─────────────────────────────────────────────────────────
  int get totalRaces   => filteredResults.length;
  int get totalWins    => filteredResults.where((r) => r.positionFinal == 1).length;
  int get totalPodiums => filteredResults.where((r) => r.positionFinal != null && r.positionFinal! <= 3).length;
  int? get bestPosition {
    final v = filteredResults.where((r) => r.positionFinal != null).map((r) => r.positionFinal!).toList();
    return v.isEmpty ? null : v.reduce((a, b) => a < b ? a : b);
  }

  // ── stats avanzadas ───────────────────────────────────────────────────────
  List<MyRaceResult> get chronologicalResults =>
      filteredResults.reversed.where((r) => r.positionFinal != null && r.relativeScore != null).toList();

  List<_Pt> get _scorePoints => chronologicalResults
      .asMap()
      .entries
      .map((e) => _Pt(e.key.toDouble(), e.value.relativeScore!))
      .toList();

  Map<String, double>? get _regression => _linearRegression(_scorePoints);

  double? get trendSlopePerRace => _regression?['slope'];

  double get avgRelativeScore {
    final pts = _scorePoints;
    if (pts.isEmpty) return 0;
    return pts.fold(0.0, (s, p) => s + p.y) / pts.length;
  }

  double? get forecastNextScore {
    final reg = _regression;
    if (reg == null) return null;
    final n = _scorePoints.length.toDouble();
    return (reg['intercept']! + reg['slope']! * n).clamp(0.0, 100.0);
  }

  List<FlSpot> get chartSpots =>
      _scorePoints.map((p) => FlSpot(p.x, p.y)).toList();

  List<FlSpot> get forecastChartSpots {
    final reg = _regression;
    if (reg == null || _scorePoints.isEmpty) return [];
    final lastX = _scorePoints.last.x;
    final a = reg['intercept']!;
    final b = reg['slope']!;
    return [
      FlSpot(lastX,     (a + b * lastX).clamp(0.0, 100.0)),
      FlSpot(lastX + 1, (a + b * (lastX + 1)).clamp(0.0, 100.0)),
      FlSpot(lastX + 2, (a + b * (lastX + 2)).clamp(0.0, 100.0)),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    _loadAllResults();
  }

  Future<void> _loadAllResults() async {
    final uid = _userId;
    if (uid == null) return;

    isLoading.value = true;
    try {
      // 1 ── Resultados del usuario
      final res = await _supabase
          .from('registrations')
          .select('id_event, id_category, position_final, qualy_position, '
              'events!inner(name, event_date_ini, championships(name, year)), '
              'categories(name)')
          .eq('id_profile', uid);

      _allResults.clear();
      for (final row in res as List) {
        final event    = row['events'] as Map<String, dynamic>?;
        final category = row['categories'] as Map<String, dynamic>?;
        final champ    = event?['championships'] as Map<String, dynamic>?;

        DateTime? eventDate;
        if (event?['event_date_ini'] != null) {
          eventDate = DateTime.tryParse(event!['event_date_ini'].toString());
        }

        _allResults.add(MyRaceResult(
          eventName:        event?['name']?.toString() ?? '',
          eventDate:        eventDate,
          categoryName:     category?['name']?.toString() ?? '',
          championshipName: champ?['name']?.toString(),
          championshipYear: champ?['year'] as int?,
          positionFinal:    row['position_final'] as int?,
          qualyPosition:    row['qualy_position'] as int?,
          idEvent:          row['id_event'] as int? ?? 0,
          idCategory:       row['id_category'] as int?,
        ));
      }

      // 2 ── Contar participantes por (evento, categoría)
      final eventIds = _allResults.map((r) => r.idEvent).toSet().toList();
      if (eventIds.isNotEmpty) {
        final countRes = await _supabase
            .from('registrations')
            .select('id_event, id_category')
            .inFilter('id_event', eventIds);

        final Map<String, int> countMap = {};
        for (final row in countRes as List) {
          final key = '${row['id_event']}_${row['id_category']}';
          countMap[key] = (countMap[key] ?? 0) + 1;
        }
        for (final r in _allResults) {
          r.totalParticipants = countMap['${r.idEvent}_${r.idCategory}'] ?? 1;
        }
      }

      _allResults.sort((a, b) {
        if (a.eventDate == null && b.eventDate == null) return 0;
        if (a.eventDate == null) return 1;
        if (b.eventDate == null) return -1;
        return b.eventDate!.compareTo(a.eventDate!);
      });

      // 3 ── Extraer campeonatos únicos
      final champSet = <String>{};
      for (final r in _allResults) {
        if (r.championshipName != null) {
          champSet.add('${r.championshipName} ${r.championshipYear ?? ''}'.trim());
        }
      }
      championships.assignAll(champSet.toList());

      if (championships.isNotEmpty) {
        selectedChampionship.value = championships.first;
        _updateCategories();
      }
    } catch (e) {
      debugPrint('Error loading my results: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onChampionshipChanged(String? champ) {
    if (champ == null) return;
    selectedChampionship.value = champ;
    selectedCategory.value = '';
    _updateCategories();
  }

  void _updateCategories() {
    final champKey = selectedChampionship.value;
    final catSet = <String>{};
    for (final r in _allResults) {
      final key = r.championshipName != null
          ? '${r.championshipName} ${r.championshipYear ?? ''}'.trim() : '';
      if (key == champKey) catSet.add(r.categoryName);
    }
    categories.assignAll(catSet.toList());
    if (categories.isNotEmpty) selectedCategory.value = categories.first;
    _applyFilters();
  }

  void onCategoryChanged(String? cat) {
    if (cat == null) return;
    selectedCategory.value = cat;
    _applyFilters();
  }

  void _applyFilters() {
    final champKey = selectedChampionship.value;
    final cat = selectedCategory.value;
    filteredResults.assignAll(_allResults.where((r) {
      final key = r.championshipName != null
          ? '${r.championshipName} ${r.championshipYear ?? ''}'.trim() : '';
      return key == champKey && (cat.isEmpty || r.categoryName == cat);
    }).toList());
  }
}
