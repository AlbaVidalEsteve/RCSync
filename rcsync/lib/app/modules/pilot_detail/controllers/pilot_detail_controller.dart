import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/ranking_model.dart';

class PilotResult {
  final String eventName;
  final DateTime? eventDate;
  final String categoryName;
  final String? championshipName;
  final int? championshipYear;
  final int? positionFinal;
  final int? qualyPosition;
  final int idEvent;
  final int? idCategory;
  int totalParticipants; // rellenado en segundo paso

  PilotResult({
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

  /// Percentil: 100 = victoria, 0 = último. Nulo si no hay posición.
  double? get relativeScore {
    if (positionFinal == null || totalParticipants <= 1) return null;
    return (totalParticipants - positionFinal!) / (totalParticipants - 1) * 100;
  }
}

// ─── helpers de regresión ───────────────────────────────────────────────────
class _Pt {
  final double x, y;
  const _Pt(this.x, this.y);
}

/// Regresión lineal simple (mínimos cuadrados). Devuelve {slope, intercept}.
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
// ────────────────────────────────────────────────────────────────────────────

class PilotDetailController extends GetxController {
  final _supabase = Supabase.instance.client;

  late final RankingEntry pilot;
  int rankPosition = 0;
  String? categoryFilter;

  RxBool isLoading = false.obs;
  RxList<PilotResult> results = <PilotResult>[].obs;
  RxList<String> champKeys = <String>[].obs;
  final Map<String, List<PilotResult>> groupedResults = {};

  // ── stats básicas ─────────────────────────────────────────────────────────
  int get totalRaces    => results.length;
  int get totalWins     => results.where((r) => r.positionFinal == 1).length;
  int get totalPodiums  => results.where((r) => r.positionFinal != null && r.positionFinal! <= 3).length;
  int? get bestPosition {
    final v = results.where((r) => r.positionFinal != null).map((r) => r.positionFinal!).toList();
    return v.isEmpty ? null : v.reduce((a, b) => a < b ? a : b);
  }

  // ── resultados cronológicos con posición y percentil ──────────────────────
  List<PilotResult> get chronologicalResults =>
      results.reversed.where((r) => r.positionFinal != null && r.relativeScore != null).toList();

  // ── regresión y estadísticas avanzadas ────────────────────────────────────
  List<_Pt> get _scorePoints => chronologicalResults
      .asMap()
      .entries
      .map((e) => _Pt(e.key.toDouble(), e.value.relativeScore!))
      .toList();

  Map<String, double>? get _regression => _linearRegression(_scorePoints);

  /// Pendiente de la tendencia en % de percentil por carrera.
  double? get trendSlopePerRace => _regression?['slope'];

  /// Percentil medio de todas las carreras (0–100).
  double get avgRelativeScore {
    final pts = _scorePoints;
    if (pts.isEmpty) return 0;
    return pts.fold(0.0, (s, p) => s + p.y) / pts.length;
  }

  /// Pronóstico para la próxima carrera (clampado 0–100).
  double? get forecastNextScore {
    final reg = _regression;
    if (reg == null) return null;
    final n = _scorePoints.length.toDouble();
    return (reg['intercept']! + reg['slope']! * n).clamp(0.0, 100.0);
  }

  // ── puntos para el gráfico ────────────────────────────────────────────────
  List<FlSpot> get chartSpots =>
      _scorePoints.map((p) => FlSpot(p.x, p.y)).toList();

  /// Línea discontinua de pronóstico (conecta desde el último punto real).
  List<FlSpot> get forecastChartSpots {
    final reg = _regression;
    if (reg == null || _scorePoints.isEmpty) return [];
    final lastX = _scorePoints.last.x;
    final a = reg['intercept']!;
    final b = reg['slope']!;
    return [
      FlSpot(lastX, (a + b * lastX).clamp(0.0, 100.0)),
      FlSpot(lastX + 1, (a + b * (lastX + 1)).clamp(0.0, 100.0)),
      FlSpot(lastX + 2, (a + b * (lastX + 2)).clamp(0.0, 100.0)),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      pilot = args['entry'] as RankingEntry;
      rankPosition = (args['position'] as int?) ?? 0;
      categoryFilter = args['category'] as String?;
    } else {
      pilot = args as RankingEntry;
    }
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    isLoading.value = true;
    try {
      // 1 ── Resultados del piloto
      final res = await _supabase
          .from('registrations')
          .select('id_event, id_category, position_final, qualy_position, '
              'events!inner(name, event_date_ini, championships(name, year)), '
              'categories(name)')
          .eq('id_profile', pilot.idProfile);

      final List<PilotResult> loaded = [];
      for (final row in res as List) {
        final event    = row['events'] as Map<String, dynamic>?;
        final category = row['categories'] as Map<String, dynamic>?;
        final champ    = event?['championships'] as Map<String, dynamic>?;

        DateTime? eventDate;
        if (event?['event_date_ini'] != null) {
          eventDate = DateTime.tryParse(event!['event_date_ini'].toString());
        }

        loaded.add(PilotResult(
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
      final eventIds = loaded.map((r) => r.idEvent).toSet().toList();
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
        for (final r in loaded) {
          r.totalParticipants = countMap['${r.idEvent}_${r.idCategory}'] ?? 1;
        }
      }

      // 3 ── Ordenar y filtrar
      loaded.sort((a, b) {
        if (a.eventDate == null && b.eventDate == null) return 0;
        if (a.eventDate == null) return 1;
        if (b.eventDate == null) return -1;
        return b.eventDate!.compareTo(a.eventDate!);
      });

      final filtered = (categoryFilter != null && categoryFilter!.isNotEmpty)
          ? loaded.where((r) => r.categoryName == categoryFilter).toList()
          : loaded;

      results.assignAll(filtered);

      // 4 ── Agrupar por campeonato
      groupedResults.clear();
      for (final r in filtered) {
        final key = r.championshipName != null
            ? '${r.championshipName} ${r.championshipYear ?? ''}'.trim()
            : 'pilot_no_champ'.tr;
        groupedResults.putIfAbsent(key, () => []).add(r);
      }
      champKeys.assignAll(groupedResults.keys.toList());
    } catch (e) {
      debugPrint('Error fetching pilot results: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
