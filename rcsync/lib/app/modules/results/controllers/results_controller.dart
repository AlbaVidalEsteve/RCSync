import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/ranking_model.dart';

class ResultsController extends GetxController {
  final _supabase = Supabase.instance.client;

  RxString selectedYear = "2025".obs;
  RxString selectedMainCategory = "".obs;
  RxString selectedSubFilter = "General".obs;
  RxBool isChampionshipActive = true.obs;

  // NUEVO: Lista dinámica de categorías desde la base de datos
  RxList<String> availableCategories = <String>[].obs;

  RxList<RankingEntry> allEntries = <RankingEntry>[].obs;
  RxList<RankingEntry> filteredEntries = <RankingEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategoriesAndRanking(); // Cambiamos la llamada inicial
  }

  // NUEVO: Función maestra que carga las categorías antes del ranking
  Future<void> fetchCategoriesAndRanking() async {
    try {
      print("🔍 Buscando campeonato para el año: ${selectedYear.value}");

      // 1. Buscamos el campeonato usando el nombre exacto de la columna: id_championship
      final champResponse = await _supabase
          .from('championships')
          .select('id_championship, is_active') // <--- CORREGIDO
          .eq('year', int.parse(selectedYear.value))
          .limit(1);

      if (champResponse.isNotEmpty) {
        final champData = champResponse.first;
        isChampionshipActive.value = champData['is_active'] ?? true;
        int champId = champData['id_championship']; // <--- CORREGIDO

        print("✅ Campeonato encontrado. ID: $champId. Buscando categorías...");

        // 2. Buscamos las categorías usando el nombre exacto de la llave foránea: id_championship
        final catData = await _supabase
            .from('categories')
            .select('name')
            .eq('id_championship', champId); // <--- CORREGIDO

        List<String> fetchedCats = (catData as List).map((c) => c['name'].toString()).toList();
        print("✅ Categorías encontradas: $fetchedCats");

        availableCategories.assignAll(fetchedCats);

      } else {
        print("⚠️ No hay campeonato para el año ${selectedYear.value}.");
        isChampionshipActive.value = true;
        availableCategories.clear();
      }

      // 3. Seleccionamos la primera categoría por defecto
      if (availableCategories.isNotEmpty) {
        if (!availableCategories.contains(selectedMainCategory.value)) {
          selectedMainCategory.value = availableCategories.first;
        }
        await fetchRanking();
      } else {
        selectedMainCategory.value = "";
        allEntries.clear();
        filteredEntries.clear();
      }

    } catch (e) {
      print("❌ Error crítico cargando categorías: $e");
    }
  }

  // La función de ranking ahora solo se encarga de traer los puntos
  Future<void> fetchRanking() async {
    if (selectedMainCategory.value.isEmpty) return;

    try {
      final response = await _supabase
          .from('v_ranking_general')
          .select()
          .eq('year', int.parse(selectedYear.value))
          .eq('category_name', selectedMainCategory.value); // Filtro exacto

      Map<String, RankingEntry> grouped = {};
      final List<dynamic> data = response;

      for (var row in data) {
        final String id = row['id_profile'];
        final int pos = row['position_final'] ?? 0;
        final int pts = row['points'] ?? 0;

        if (!grouped.containsKey(id)) {
          grouped[id] = RankingEntry(
            idProfile: id,
            fullName: row['full_name'],
            isJunior: row['is_junior'] ?? false,
            points: [],
            positions: [],
          );
        }

        if (pos > 0) {
          grouped[id]!.points.add(pts);
          grouped[id]!.positions.add(pos);
        }
      }

      allEntries.assignAll(grouped.values.toList());
      applyFilters();

    } catch (e) {
      print("Error en fetchRanking: $e");
    }
  }

  void applyFilters() {
    List<RankingEntry> temp = List.from(allEntries);

    if (selectedSubFilter.value == "Junior") {
      temp = temp.where((p) => p.isJunior).toList();
    } else if (selectedSubFilter.value == "Stock") {
      temp = temp.where((p) => p.calculatedLevel == "STOCK").toList();
    } else if (selectedSubFilter.value == "Superstock") {
      temp = temp.where((p) => p.calculatedLevel == "SUPERSTOCK").toList();
    }

    var list = temp;
    list.sort((a, b) => !isChampionshipActive.value
        ? b.totalNet.compareTo(a.totalNet)
        : b.totalGross.compareTo(a.totalGross));

    filteredEntries.assignAll(list);
  }
}