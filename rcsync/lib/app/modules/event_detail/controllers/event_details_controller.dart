import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';

class RegisteredPilot {
  final String fullName;
  final String subCategory;
  final String? imageUrl;
  final int totalPoints;

  RegisteredPilot({
    required this.fullName,
    required this.subCategory,
    this.imageUrl,
    required this.totalPoints,
  });
}

class EventDetailsController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;
  late Rx<RaceEventModel> event;

  var registeredPilots = <String, List<RegisteredPilot>>{}.obs;

  // Lista reactiva para los reglamentos encontrados
  var rulebooks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is RaceEventModel) {
      event = (Get.arguments as RaceEventModel).obs;
      fetchRegisteredPilots();
      fetchRulebooks(); // Cargar reglamentos al iniciar
    }
  }

  String get formattedDate => event.value.eventDateIni == null
      ? "Fecha por definir"
      : DateFormat('dd MMM yyyy', 'es_ES').format(event.value.eventDateIni!);

  Future<void> fetchRulebooks() async {
    // Verificamos que el evento tenga un campeonato asociado
    if (event.value.idChampionship == null) return;

    try {
      final response = await supabase
          .from('championship_categories')
          .select('rulebook_url, categories(name)')
          .eq('id_championship', event.value.idChampionship!)
          .not('rulebook_url', 'is', null);

      rulebooks.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error obteniendo reglamentos: $e");
    }
  }

  Future<void> openRulebook(String url) async {
    // Uri.encodeFull es CRÍTICO si el nombre de tu PDF tiene espacios
    final Uri uri = Uri.parse(Uri.encodeFull(url));

    try {
      if (await canLaunchUrl(uri)) {
        // Intentamos abrirlo como aplicación externa (Navegador / Lector PDF)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // En algunos Android, canLaunchUrl da false pero launchUrl directo funciona
        // Lo forzamos dentro de la app como plan B
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      Get.snackbar(
          'Error',
          'No se pudo abrir el archivo PDF. Asegúrate de tener una app para leer PDFs.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
    }
  }

  Future<void> fetchRegisteredPilots() async {
    isLoading.value = true;
    try {
      final response = await supabase.rpc(
          'get_event_ranking_pre_race_v8',
          params: {'p_event_id': event.value.idEvent}
      );

      final List<dynamic> data = response as List<dynamic>;
      Map<String, List<RegisteredPilot>> grouped = {};

      for (var item in data) {
        String catName = item['category_name'] ?? 'Otros';

        var pilot = RegisteredPilot(
          fullName: item['full_name'] ?? 'Piloto',
          subCategory: item['subcategory_name'] ?? 'STOCK',
          imageUrl: item['image_url'],
          totalPoints: (item['total_points_previo'] as num).toInt(),
        );

        grouped.putIfAbsent(catName, () => []).add(pilot);
      }

      // Ordenar por puntos (Mayor a menor)
      grouped.forEach((key, list) {
        list.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      });

      registeredPilots.value = grouped;
    } catch (e) {
      debugPrint("Error fetching pilots: $e");
    } finally {
      isLoading.value = false;
    }
  }
}