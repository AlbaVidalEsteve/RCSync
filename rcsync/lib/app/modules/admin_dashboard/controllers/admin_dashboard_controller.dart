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

  String currentUserId = '';
  final RxString currentUserRole = ''.obs;

  bool get isAdmin => currentUserRole.value == 'admin';

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
    _loadUserInfo().then((_) => loadAllData());
  }

  Future<void> _loadUserInfo() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    currentUserId = user.id;
    try {
      final role = await supabase.rpc('get_my_role');
      currentUserRole.value = role?.toString() ?? '';
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Future<void> loadAllData() async {
    await fetchChampionships();
    await fetchEvents();
    await fetchPendingRegistrations();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchChampionships() async {
    isLoadingChamps.value = true;
    try {
      final response = isAdmin
          ? await supabase.from('championships').select('*').order('year', ascending: false)
          : await supabase.from('championships').select('*').eq('id_profile_org', currentUserId).order('year', ascending: false);
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
      late List<dynamic> response;
      if (isAdmin) {
        response = await supabase.from('events').select('*, circuits(name)');
      } else {
        final ownChampIds = championshipsList.map((c) => c['id_championship']).toList();
        if (ownChampIds.isEmpty) {
          eventsList.value = [];
          groupedEvents.value = {};
          return;
        }
        response = await supabase
            .from('events')
            .select('*, circuits(name)')
            .filter('id_championship', 'in', '(${ownChampIds.join(",")})');
      }
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
      const sel = '*, profiles(full_name, image_profile), events(name), categories(name)';

      if (!isAdmin) {
        // Organizador: solo inscripciones de eventos de su campeonato
        final ownEventIds = eventsList.map((e) => e.idEvent).whereType<int>().toList();
        if (ownEventIds.isEmpty) {
          pendingRegistrationsList.value = [];
          approvedRegistrationsList.value = [];
          deniedRegistrationsList.value = [];
          return;
        }
        final eventFilter = '(${ownEventIds.join(",")})';
        pendingRegistrationsList.value  = await supabase.from('registrations').select(sel).eq('status', 'pending').filter('id_event', 'in', eventFilter);
        approvedRegistrationsList.value = await supabase.from('registrations').select(sel).eq('status', 'approved').filter('id_event', 'in', eventFilter);
        deniedRegistrationsList.value   = await supabase.from('registrations').select(sel).eq('status', 'denied').filter('id_event', 'in', eventFilter);
      } else {
        pendingRegistrationsList.value  = await supabase.from('registrations').select(sel).eq('status', 'pending');
        approvedRegistrationsList.value = await supabase.from('registrations').select(sel).eq('status', 'approved');
        deniedRegistrationsList.value   = await supabase.from('registrations').select(sel).eq('status', 'denied');
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoadingRegs.value = false;
    }
  }

  // Aceptar inscripcion
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

  // Rechazar inscripcion
  Future<void> denyRegistration(int idRegistration) async {
    try {
      // Mostrar mensaje de confirmacion
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

  // Cancelar/Borrar inscripcion
  Future<void> cancelRegistration(int idRegistration) async {
    try {

      // Mostrar dialogo de confirmacion
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

  Future<int> _countResults(List<int> eventIds) async {
    if (eventIds.isEmpty) return 0;
    try {
      final res = await supabase
          .from('registrations')
          .select('id_registration')
          .filter('id_event', 'in', eventIds)
          .not('position_final', 'is', null);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<bool?> _showDeleteDialog({
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: RCColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: confirmColor),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(content, style: TextStyle(color: RCColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('adm_cancel'.tr, style: TextStyle(color: RCColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteEvent(int idEvent, String eventName) async {
    final resultCount = await _countResults([idEvent]);
    final hasResults  = resultCount > 0;

    final content = hasResults
        ? 'adm_delete_event_results'.tr
            .replaceFirst('%n', '$resultCount')
            .replaceFirst('%e', eventName)
        : 'adm_delete_event_confirm'.tr.replaceFirst('%e', eventName);

    final confirmed = await _showDeleteDialog(
      title:         hasResults ? 'adm_delete_event_with_results_title'.tr : 'adm_delete_event_title'.tr,
      content:       content,
      confirmLabel:  hasResults ? 'adm_delete_anyway'.tr : 'adm_delete_confirm'.tr,
      confirmColor:  Colors.red,
    );

    if (confirmed != true) return;

    try {
      await supabase.from('registrations').delete().eq('id_event', idEvent);
      await supabase.from('events').delete().eq('id_event', idEvent);
      Get.snackbar('adm_success'.tr, 'adm_delete_event_ok'.tr,
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      loadAllData();
    } catch (e) {
      debugPrint('Error deleting event: $e');
      Get.snackbar('Error', 'adm_err_delete_event'.tr,
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteChampionship(int idChampionship, String champName) async {
    // Obtener eventos del campeonato antes del diálogo para la comprobación
    List<int> eventIds = [];
    try {
      final events = await supabase
          .from('events')
          .select('id_event')
          .eq('id_championship', idChampionship);
      eventIds = (events as List).map((e) => e['id_event'] as int).toList();
    } catch (e) {
      debugPrint('Error fetching events for championship: $e');
    }

    final resultCount = await _countResults(eventIds);
    final hasResults  = resultCount > 0;

    final content = hasResults
        ? 'adm_delete_champ_results'.tr
            .replaceFirst('%n', '$resultCount')
            .replaceFirst('%c', champName)
        : 'adm_delete_champ_confirm'.tr.replaceFirst('%c', champName);

    final confirmed = await _showDeleteDialog(
      title:        hasResults ? 'adm_delete_champ_with_results_title'.tr : 'adm_delete_champ_title'.tr,
      content:      content,
      confirmLabel: hasResults ? 'adm_delete_anyway'.tr : 'adm_delete_confirm'.tr,
      confirmColor: Colors.red,
    );

    if (confirmed != true) return;

    try {
      if (eventIds.isNotEmpty) {
        await supabase.from('registrations').delete().filter('id_event', 'in', eventIds);
      }
      await supabase.from('events').delete().eq('id_championship', idChampionship);
      await supabase.from('championship_categories').delete().eq('id_championship', idChampionship);
      await supabase.from('championships').delete().eq('id_championship', idChampionship);

      Get.snackbar('adm_success'.tr, 'adm_delete_champ_ok'.tr,
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      loadAllData();
    } catch (e) {
      debugPrint('Error deleting championship: $e');
      Get.snackbar('Error', 'adm_err_delete_champ'.tr,
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}