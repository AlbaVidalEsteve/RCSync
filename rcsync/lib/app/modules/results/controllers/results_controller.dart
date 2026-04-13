import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/ranking_model.dart';

class ResultsController extends GetxController {
  final _supabase = Supabase.instance.client;

  // Selecciones del usuario
  RxString selectedChampionshipName = "".obs;
  RxString selectedYear = "".obs;
  RxString selectedCategory = "".obs;
  RxString selectedSubFilter = "General".obs;

  RxBool isChampionshipActive = true.obs;

  // Opciones disponibles para los combos
  RxList<String> availableChampionships = <String>[].obs;
  RxList<String> availableYears = <String>[].obs;
  RxList<String> availableCategories = <String>[].obs;

  RxList<RankingEntry> allEntries = <RankingEntry>[].obs;
  RxList<RankingEntry> filteredEntries = <RankingEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChampionshipNames();
  }

  Future<void> fetchChampionshipNames() async {
    try {
      final response = await _supabase.from('championships').select('name');

      if (response != null) {
        final List<String> champs = (response as List)
            .map((row) => row['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();

        availableChampionships.assignAll(champs);

        if (champs.isNotEmpty && !champs.contains(selectedChampionshipName.value)) {
          selectedChampionshipName.value = champs.first;
        }
        fetchAvailableYears();
      }
    } catch (e) {
      print("❌ Error fetching championship names: $e");
    }
  }

  Future<void> fetchAvailableYears() async {
    if (selectedChampionshipName.value.isEmpty) return;

    try {
      final response = await _supabase
          .from('championships')
          .select('year')
          .eq('name', selectedChampionshipName.value.trim())
          .order('year', ascending: false);

      if (response != null) {
        final List<String> years = (response as List)
            .map((row) => row['year']?.toString() ?? '')
            .where((year) => year.isNotEmpty)
            .toSet()
            .toList();

        availableYears.assignAll(years);

        if (years.isNotEmpty && !years.contains(selectedYear.value)) {
          selectedYear.value = years.first;
        } else if (years.isEmpty) {
          selectedYear.value = "";
        }

        fetchCategoriesForChampionship();
      }
    } catch (e) {
      print("❌ Error fetching available years: $e");
    }
  }

  Future<void> fetchCategoriesForChampionship() async {
    if (selectedChampionshipName.value.isEmpty || selectedYear.value.isEmpty) return;

    try {
      final champData = await _supabase
          .from('championships')
          .select('id_championship, is_active')
          .eq('name', selectedChampionshipName.value.trim())
          .eq('year', int.parse(selectedYear.value))
          .maybeSingle();

      if (champData != null) {
        isChampionshipActive.value = champData['is_active'] ?? true;
        final champId = champData['id_championship'];

        final catResponse = await _supabase
            .from('championship_categories')
            .select('categories(name)')
            .eq('id_championship', champId);

        if (catResponse != null && (catResponse as List).isNotEmpty) {
          final List<String> cats = (catResponse as List)
              .map((c) {
            final categoryMap = c['categories'] as Map<String, dynamic>?;
            return categoryMap?['name']?.toString() ?? '';
          })
              .where((name) => name.isNotEmpty)
              .toList();

          availableCategories.assignAll(cats);

          if (cats.isNotEmpty && !cats.contains(selectedCategory.value)) {
            selectedCategory.value = cats.first;
          } else if (cats.isEmpty) {
            selectedCategory.value = "";
          }

          fetchRanking();
        } else {
          _limpiarDatos();
        }
      } else {
        _limpiarDatos();
      }
    } catch (e) {
      print("❌ Error fetching categories via N:M: $e");
      _limpiarDatos();
    }
  }

  Future<void> fetchRanking() async {
    if (selectedYear.value.isEmpty || selectedCategory.value.isEmpty || selectedChampionshipName.value.isEmpty) {
      allEntries.clear();
      filteredEntries.clear();
      return;
    }

    try {
      final response = await _supabase.rpc('get_championship_ranking', params: {
        'p_championship_name': selectedChampionshipName.value.trim(),
        'p_year': int.parse(selectedYear.value),
        'p_category_name': selectedCategory.value,
      });

      if (response != null) {
        final List<RankingEntry> loaded = (response as List).map((data) {
          return RankingEntry(
            idProfile: data['id_profile']?.toString() ?? '',
            fullName: data['full_name']?.toString() ?? '',
            isJunior: data['is_junior'] ?? false,
            calculatedLevel: data['calculated_level']?.toString() ?? 'STOCK',
            imageProfile: data['image_profile']?.toString(),
            // BLINDAJE ANDROID: Usamos la función extractora segura
            points: _parseToIntList(data['points']),
            positions: _parseToIntList(data['positions']),
          );
        }).toList();

        allEntries.assignAll(loaded);
        applyFilters();
      }
    } catch (e) {
      print("❌ Error en fetchRanking: $e");
    }
  }

  void applyFilters() {
    Iterable<RankingEntry> temp = allEntries;

    if (selectedSubFilter.value == "Junior") {
      temp = temp.where((p) => p.isJunior);
    } else if (selectedSubFilter.value == "Stock") {
      temp = temp.where((p) => p.calculatedLevel == "STOCK");
    } else if (selectedSubFilter.value == "Superstock") {
      temp = temp.where((p) => p.calculatedLevel == "SUPERSTOCK");
    }

    final sortedList = temp.toList();

    sortedList.sort((a, b) => !isChampionshipActive.value
        ? b.totalNet.compareTo(a.totalNet)
        : b.totalGross.compareTo(a.totalGross));

    filteredEntries.assignAll(sortedList);
  }

  void _limpiarDatos() {
    availableCategories.clear();
    selectedCategory.value = "";
    allEntries.clear();
    filteredEntries.clear();
  }

  // --- FUNCIÓN SALVAVIDAS PARA EL PARSEO EN ANDROID/IOS ---
  List<int> _parseToIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      // Extrae cada elemento, lo pasa a texto y luego a entero,
      // ignorando cualquier error estricto de tipos de Android.
      return value.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }
    return [];
  }
}