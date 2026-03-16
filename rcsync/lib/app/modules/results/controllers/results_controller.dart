import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/ranking_model.dart';

class ResultsController extends GetxController {
  final _supabase = Supabase.instance.client;

  RxString selectedYear = "".obs;
  RxString selectedMainCategory = "".obs;
  RxString selectedSubFilter = "General".obs;
  RxBool isChampionshipActive = true.obs;
  RxList<String> availableYears = <String>[].obs;

  // Lista dinamica de categorías desde la base de datos
  RxList<String> availableCategories = <String>[].obs;

  RxList<RankingEntry> allEntries = <RankingEntry>[].obs;
  RxList<RankingEntry> filteredEntries = <RankingEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAvailableYears();
  }

  // Carga las categorias vinculadas al año seleccionado
  Future<void> fetchCategoriesAndRanking() async {
    try {
      final champResponse = await _supabase
          .from('championships')
          .select('id_championship, is_active')
          .eq('year', int.parse(selectedYear.value))
          .limit(1);

      if (champResponse.isNotEmpty) {
        final champData = champResponse.first;
        isChampionshipActive.value = champData['is_active'] ?? true;
        int champId = champData['id_championship'];

        final catData = await _supabase
            .from('championship_categories')
            .select('''
              categories (
                name
              )
            ''')
            .eq('id_championship', champId);

        List<String> fetchedCats = (catData as List)
            .map((c) => c['categories']['name'].toString())
            .toList();

        availableCategories.assignAll(fetchedCats);
      } else {
        availableCategories.clear();
      }

      if (availableCategories.isNotEmpty) {
        if (selectedMainCategory.value.isEmpty || !availableCategories.contains(selectedMainCategory.value)) {
          selectedMainCategory.value = availableCategories.first;
        }
        await fetchRanking();
      } else {
        selectedMainCategory.value = "";
        allEntries.clear();
        filteredEntries.clear();
      }
    } catch (e) {
      print("❌ Error cargando categorías: $e");
    }
  }

  // Obtiene los datos de la vista v_ranking_general
  Future<void> fetchRanking() async {
    if (selectedMainCategory.value.isEmpty) return;

    try {
      final response = await _supabase
          .from('v_ranking_general')
          .select()
          .eq('year', int.parse(selectedYear.value))
          .eq('category_name', selectedMainCategory.value);

      Map<String, RankingEntry> grouped = {};
      final List<dynamic> data = response;

      for (var row in data) {
        final String id = row['id_profile'];
        final int pos = row['position_final'] ?? 0;
        final int pts = row['points'] ?? 0;

        // Leemos el nivel de ESA carrera específica.
        final String currentRaceLevel = row['calculated_level'] ?? "STOCK";

        if (!grouped.containsKey(id)) {
          // Si es la primera vez que vemos al piloto, lo creamos
          grouped[id] = RankingEntry(
            idProfile: id,
            fullName: row['full_name'],
            isJunior: row['is_junior'] ?? false,
            calculatedLevel: currentRaceLevel,
            points: [],
            positions: [],
          );
        } else {
          // Si ya existe y en esta carrera era SUPERSTOCK, actualizamos su nivel final
          if (currentRaceLevel == 'SUPERSTOCK' && grouped[id]!.calculatedLevel != 'SUPERSTOCK') {
            grouped[id] = RankingEntry(
              idProfile: id,
              fullName: grouped[id]!.fullName,
              isJunior: grouped[id]!.isJunior,
              calculatedLevel: 'SUPERSTOCK',
              points: grouped[id]!.points,
              positions: grouped[id]!.positions,
            );
          }
        }

        // Añadimos los puntos y posiciones de esta carrera
        if (pos > 0) {
          grouped[id]!.points.add(pts);
          grouped[id]!.positions.add(pos);
        }
      }

      allEntries.assignAll(grouped.values.toList());
      applyFilters();
    } catch (e) {
      print("❌ Error en fetchRanking: $e");
    }
  }

  // Aplica los filtros de la interfaz (General, Stock, Superstock, Junior)
  void applyFilters() {
    List<RankingEntry> temp = List.from(allEntries);

    if (selectedSubFilter.value == "Junior") {
      temp = temp.where((p) => p.isJunior).toList();
    } else if (selectedSubFilter.value == "Stock") {
      temp = temp.where((p) => p.calculatedLevel == "STOCK").toList();
    } else if (selectedSubFilter.value == "Superstock") {
      temp = temp.where((p) => p.calculatedLevel == "SUPERSTOCK").toList();
    }

    temp.sort((a, b) => !isChampionshipActive.value
        ? b.totalNet.compareTo(a.totalNet)
        : b.totalGross.compareTo(a.totalGross));

    filteredEntries.assignAll(temp);
  }

  // Busca los años disponibles con campeonato
  Future<void> fetchAvailableYears() async {
    try {
      final response = await _supabase
          .from('championships')
          .select('year')
          .order('year', ascending: false);

      if (response.isNotEmpty) {
        final Set<String> yearsSet = {};
        for (var row in response) {
          yearsSet.add(row['year'].toString());
        }

        availableYears.assignAll(yearsSet.toList());
        selectedYear.value = availableYears.first;
        await fetchCategoriesAndRanking();
      }
    } catch (e) {
      print("❌ Error cargando años: $e");
    }
  }
}