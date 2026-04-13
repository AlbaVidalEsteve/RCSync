import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is RaceEventModel) {
      event = (Get.arguments as RaceEventModel).obs;
      fetchRegisteredPilots();
    }
  }

  String get formattedDate => event.value.eventDateIni == null
      ? "Fecha por definir"
      : DateFormat('dd MMM yyyy', 'es_ES').format(event.value.eventDateIni!);

  Future<void> fetchRegisteredPilots() async {
    isLoading.value = true;
    try {
      // Llamada a la versión v8 con lógica de descarte inteligente
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

      registeredPilots.assignAll(grouped);
    } catch (e) {
      print("Error en ranking v8: $e");
    } finally {
      isLoading.value = false;
    }
  }
}