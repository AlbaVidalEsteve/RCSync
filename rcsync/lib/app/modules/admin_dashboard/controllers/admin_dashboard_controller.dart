import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/core/theme/rc_colors.dart';

class AdminDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var currentTabIndex = 0.obs;

  final supabase = Supabase.instance.client;

  var eventsList = <RaceEventModel>[].obs;
  var groupedEvents = <String, List<RaceEventModel>>{}.obs;
  var championshipsList = <Map<String, dynamic>>[].obs;
  var activeChampionshipsList = <Map<String, dynamic>>[].obs;
  var pendingRegistrationsList = <Map<String, dynamic>>[].obs;
  var approvedRegistrationsList = <Map<String, dynamic>>[].obs;
  var deniedRegistrationsList = <Map<String, dynamic>>[].obs;

  var isLoadingEvents = false.obs;
  var isLoadingChamps = false.obs;
  var isLoadingRegs = false.obs;

  // Control para pestañas de inscripciones
  var regTabIndex = 0.obs;
  final List<String> regTabs = ['Pendientes', 'Aprobados', 'Rechazados'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() => currentTabIndex.value = tabController.index);
    loadAllData();
  }

  Future<void> loadAllData() async {
    await fetchChampionships();
    await fetchEvents();
    fetchPendingRegistrations();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchChampionships() async {
    isLoadingChamps.value = true;
    try {
      final response = await supabase.from('championships').select('*').order('year', ascending: false);
      championshipsList.value = response;
      activeChampionshipsList.value = response.where((c) => c['is_active'] == true).toList();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoadingChamps.value = false;
    }
  }

  Future<void> fetchEvents() async {
    isLoadingEvents.value = true;
    try {
      final response = await supabase.from('events').select('*, circuits(name)');
      eventsList.value = response.map((e) => RaceEventModel.fromJson(e)).toList();
      _groupEventsByChampionship();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoadingEvents.value = false;
    }
  }

  void _groupEventsByChampionship() {
    var grouped = <String, List<RaceEventModel>>{};
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (var event in eventsList) {
      if (event.eventDateIni != null && event.eventDateIni!.isBefore(today)) continue;
      String champName = 'Eventos Independientes';
      if (event.idChampionship != null) {
        final champ = championshipsList.firstWhere((c) => c['id_championship'] == event.idChampionship, orElse: () => <String, dynamic>{});
        if (champ.isNotEmpty && champ['name'] != null) champName = champ['name'];
      }
      if (!grouped.containsKey(champName)) grouped[champName] = [];
      grouped[champName]!.add(event);
    }
    groupedEvents.value = grouped;
  }

  Future<void> fetchPendingRegistrations() async {
    isLoadingRegs.value = true;
    try {
      // Pendientes
      final pending = await supabase
          .from('registrations')
          .select('*, profiles(full_name, image_profile), events(name), categories(name)')
          .eq('status', 'pending');
      pendingRegistrationsList.value = pending;

      // Aprobados
      final approved = await supabase
          .from('registrations')
          .select('*, profiles(full_name, image_profile), events(name), categories(name)')
          .eq('status', 'approved');
      approvedRegistrationsList.value = approved;

      // Rechazados
      final denied = await supabase
          .from('registrations')
          .select('*, profiles(full_name, image_profile), events(name), categories(name)')
          .eq('status', 'denied');
      deniedRegistrationsList.value = denied;

    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoadingRegs.value = false;
    }
  }

  // Aceptar inscripción (status -> approved)
  Future<void> confirmRegistration(int idRegistration) async {
    try {
      await supabase
          .from('registrations')
          .update({'status': 'approved'})
          .eq('id_registration', idRegistration);

      Get.snackbar(
        'Éxito',
        'Inscripción confirmada',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchPendingRegistrations();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo confirmar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Rechazar inscripción (status -> denied)
  Future<void> denyRegistration(int idRegistration) async {
    try {
      // Mostrar diálogo de confirmación
      final result = await Get.dialog<bool>(
        Dialog(
          backgroundColor: RCColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel_outlined, color: Colors.orange, size: 60),
                const SizedBox(height: 20),
                Text(
                  'Rechazar inscripción',
                  style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  '¿Estás seguro de que quieres rechazar esta inscripción?\n\nEl estado cambiará a "denegado" y el piloto verá el rechazo.',
                  style: TextStyle(color: RCColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text('No', style: TextStyle(color: RCColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Sí, rechazar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (result != true) return;

      await supabase
          .from('registrations')
          .update({'status': 'denied'})
          .eq('id_registration', idRegistration);

      Get.snackbar(
        'Éxito',
        'Inscripción rechazada',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchPendingRegistrations();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo rechazar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cancelar/Borrar inscripción (DELETE)
  Future<void> cancelRegistration(int idRegistration) async {
    try {
      // Verificar que el usuario es admin (solo admin puede borrar)
      final user = supabase.auth.currentUser;
      if (user != null) {
        final profile = await supabase
            .from('profiles')
            .select('rol')
            .eq('id_profile', user.id)
            .maybeSingle();

        if (profile != null && profile['rol'] != 'admin') {
          Get.snackbar(
            'Error',
            'Solo administradores pueden eliminar inscripciones',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Mostrar diálogo de confirmación
      final result = await Get.dialog<bool>(
        Dialog(
          backgroundColor: RCColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(
                  'Cancelar inscripción',
                  style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  '¿Estás seguro de que quieres cancelar esta inscripción?\n\n⚠️ El registro se eliminará PERMANENTEMENTE de la base de datos. Esta acción no se puede deshacer.',
                  style: TextStyle(color: RCColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text('No', style: TextStyle(color: RCColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Sí, cancelar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (result != true) return;

      await supabase
          .from('registrations')
          .delete()
          .eq('id_registration', idRegistration);

      Get.snackbar(
        'Éxito',
        'Inscripción cancelada y eliminada',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchPendingRegistrations();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cancelar la inscripción: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void editChampionship(Map<String, dynamic> champ) async {
    final result = await Get.toNamed(Routes.CREATE_CHAMPIONSHIP, arguments: champ);
    if (result == true) {
      Get.snackbar('Éxito', 'Campeonato guardado', backgroundColor: Colors.green, colorText: Colors.white);
      loadAllData();
    }
  }

  void editEvent(RaceEventModel event) async {
    final result = await Get.toNamed(Routes.CREATE_EVENT, arguments: event);
    if (result == true) {
      Get.snackbar('Éxito', 'Evento guardado', backgroundColor: Colors.green, colorText: Colors.white);
      loadAllData();
    }
  }
}