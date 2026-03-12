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

  // NUEVO: Lista dinámica de categorías desde la base de datos
  RxList<String> availableCategories = <String>[].obs;

  RxList<RankingEntry> allEntries = <RankingEntry>[].obs;
  RxList<RankingEntry> filteredEntries = <RankingEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Cambiamos la llamada inicial para que primero busque los años
    fetchAvailableYears();
  }

  // NUEVO: Función maestra que carga las categorías antes del ranking
  Future<void> fetchCategoriesAndRanking() async {
    try {
      print("🔍 Buscando categorías para el año: ${selectedYear.value}");

      // 1. Buscamos el ID del campeonato y si está activo
      final champResponse = await _supabase
          .from('championships')
          .select('id_championship, is_active')
          .eq('year', int.parse(selectedYear.value))
          .limit(1);

      if (champResponse.isNotEmpty) {
        final champData = champResponse.first;
        isChampionshipActive.value = champData['is_active'] ?? true;
        int champId = champData['id_championship'];

        // 2. NUEVA LÓGICA: Buscamos las categorías a través de la tabla intermedia
        // Hacemos un join con la tabla 'categories' para traer el nombre
        final catData = await _supabase
            .from('championship_categories')
            .select('''
              categories (
                name
              )
            ''')
            .eq('id_championship', champId);

        // Extraemos los nombres de la respuesta anidada
        List<String> fetchedCats = (catData as List)
            .map((c) => c['categories']['name'].toString())
            .toList();

        print("✅ Categorías encontradas para este año: $fetchedCats");
        availableCategories.assignAll(fetchedCats);

      } else {
        print("⚠️ No hay campeonato para el año ${selectedYear.value}.");
        availableCategories.clear();
      }

      // 3. Selección por defecto
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

  // NUEVO: Función para buscar qué años tienen campeonato
  Future<void> fetchAvailableYears() async {
    try {
      print("🔍 Buscando años de campeonatos disponibles...");

      final response = await _supabase
          .from('championships')
          .select('year')
          .order('year', ascending: false); // Los más recientes primero

      if (response.isNotEmpty) {
        // Extraemos los años, usamos un Set para evitar duplicados si hay varios campeonatos el mismo año
        final Set<String> yearsSet = {};
        for (var row in response) {
          yearsSet.add(row['year'].toString());
        }

        availableYears.assignAll(yearsSet.toList());

        // Seleccionamos el año más reciente por defecto
        selectedYear.value = availableYears.first;
        print("✅ Años cargados: $availableYears. Seleccionado por defecto: ${selectedYear.value}");

        // Una vez tenemos el año, ya podemos buscar sus categorías y resultados
        await fetchCategoriesAndRanking();
      } else {
        print("⚠️ No hay campeonatos en la base de datos.");
      }
    } catch (e) {
      print("❌ Error crítico cargando años: $e");
    }
  }
}