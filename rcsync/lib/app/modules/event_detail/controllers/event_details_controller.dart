import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/core/theme/rc_colors.dart';


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

  // Lista de reglamentos encontrados
  var rulebooks = <Map<String, dynamic>>[].obs;
  var isRulebooksExpanded = true.obs;
  var isDescriptionExpanded = true.obs;
  var isPilotsExpanded = true.obs;

  // Verificar si el usuario actual es admin u organizador
  var isAdminOrOrganizer = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is RaceEventModel) {
      event = (Get.arguments as RaceEventModel).obs;
      fetchRegisteredPilots();
      fetchRulebooks();
      _checkAdminOrOrganizer(); // Verificar rol al iniciar
    }
  }

  String get formattedDate => event.value.eventDateIni == null
      ? "Fecha por definir"
      : DateFormat('dd MMM yyyy', 'es_ES').format(event.value.eventDateIni!);

  Future<void> fetchRulebooks() async {
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
    final Uri uri = Uri.parse(Uri.encodeFull(url));

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
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

  // Funcion abrir mapa
  Future<void> openMapsWithRoute() async {
    if (event.value.circuitLat == null || event.value.circuitLng == null) {
      Get.snackbar(
          'Error',
          'No hay coordenadas disponibles para este circuito',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
      return;
    }

    final double destLat = event.value.circuitLat!;
    final double destLng = event.value.circuitLng!;

    // URL para Google Maps con navegación desde ubicación actual
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving';

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback a navegador web
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      Get.snackbar(
          'Error',
          'No se pudo abrir la aplicación de mapas',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
    }
  }

  // registros con filtro approved
  Future<void> fetchRegisteredPilots() async {
    isLoading.value = true;
    try {
      // V9
      final response = await supabase.rpc(
          'get_event_ranking_pre_race_v9',
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
      Get.snackbar(
          'Error',
          'No se pudieron cargar los pilotos registrados',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Exportar lista de pilotos inscritos a CSV con separación por categorías
  Future<void> exportRegisteredPilots() async {
    try {
      // Mostrar indicador de carga
      Get.dialog(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: RCColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: RCColors.orange),
              SizedBox(height: 20),
              Text('Generando archivo...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Asegurar que tenemos datos actualizados
      await fetchRegisteredPilots();

      if (registeredPilots.isEmpty) {
        Get.back();
        Get.snackbar(
          'Aviso',
          'No hay pilotos inscritos para exportar',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Recopilar todos los pilotos con su información completa
      final Map<String, List<Map<String, dynamic>>> pilotsByCategory = {};

      for (var entry in registeredPilots.entries) {
        final category = entry.key;
        final List<Map<String, dynamic>> categoryPilots = [];

        for (var pilot in entry.value) {
          // Obtener transponder del piloto
          String transponder = '';
          try {
            final response = await supabase
                .from('profiles')
                .select('''
                id_profile,
                full_name,
                transponders (number, label)
              ''')
                .eq('full_name', pilot.fullName)
                .maybeSingle();

            if (response != null) {
              final transpondersList = response['transponders'] as List? ?? [];
              if (transpondersList.isNotEmpty) {
                transponder = transpondersList.first['number']?.toString() ?? '';
              }
            }
          } catch (e) {
            debugPrint('Error obteniendo transponder para ${pilot.fullName}: $e');
          }

          categoryPilots.add({
            'nombre': pilot.fullName,
            'ranking': pilot.totalPoints,
            'categoria': pilot.subCategory,
            'transponder': transponder,
            'posicion': categoryPilots.length + 1,
          });
        }

        // Ordenar por ranking dentro de la categoría
        categoryPilots.sort((a, b) => b['ranking'].compareTo(a['ranking']));

        // Actualizar posiciones después del ordenamiento
        for (int i = 0; i < categoryPilots.length; i++) {
          categoryPilots[i]['posicion'] = i + 1;
        }

        pilotsByCategory[category] = categoryPilots;
      }

      // Crear CSV
      final StringBuffer csv = StringBuffer();
      csv.write('\u{FEFF}'); // BOM para UTF-8

      for (var entry in pilotsByCategory.entries) {
        final category = entry.key;
        final pilots = entry.value;

        // Encabezado de categoría
        csv.writeln('=== $category ===');
        csv.writeln();

        // Encabezados de columnas
        csv.writeln('Nº;Nombre;Ranking;Categoría;Transponder');

        // Datos de la categoría
        for (var pilot in pilots) {
          csv.writeln(
              '${pilot['posicion']};'
                  '${pilot['nombre']};'
                  '${pilot['ranking']};'
                  '${pilot['categoria']};'
                  '${pilot['transponder']}'
          );
        }

        csv.writeln(); // Línea en blanco entre categorías
        csv.writeln(); // Línea adicional para separar
      }

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'inscritos_${event.value.name.replaceAll(' ', '_')}_$timestamp.csv';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString(csv.toString(), encoding: utf8);

      // Cerrar diálogo de carga
      Get.back();

      // Mostrar diálogo de éxito
      Get.dialog(
        Dialog(
          backgroundColor: RCColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                Text(
                  'Exportación completada',
                  style: TextStyle(
                    color: RCColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Archivo guardado:',
                  style: TextStyle(color: RCColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  fileName,
                  style: TextStyle(
                    color: RCColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RCColors.background.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estructura del archivo:',
                        style: TextStyle(
                          color: RCColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Separado por categorías\n'
                            '• Cada categoría tiene su propio ranking\n'
                            '• Nº = Posición dentro de la categoría\n'
                            '• Ranking = Puntos totales del piloto\n'
                            '• Categoría = STOCK / SUPERSTOCK\n'
                            '• Transponder = Número del transponder',
                        style: TextStyle(color: RCColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RCColors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );

    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'No se pudo exportar la lista: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Error exporting: $e');
    }
  }

  // Metodo para verificar si el usuario es admin u organizador
  Future<void> _checkAdminOrOrganizer() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        isAdminOrOrganizer.value = false;
        return;
      }

      // Obtener el rol del usuario desde la base de datos
      final response = await supabase
          .from('profiles')
          .select('rol')
          .eq('id_profile', user.id)
          .maybeSingle();

      if (response != null) {
        final rol = response['rol']?.toString().toLowerCase() ?? '';
        isAdminOrOrganizer.value = (rol == 'admin' || rol == 'organizador');
      } else {
        isAdminOrOrganizer.value = false;
      }
    } catch (e) {
      debugPrint('Error checking role: $e');
      isAdminOrOrganizer.value = false;
    }
  }
}