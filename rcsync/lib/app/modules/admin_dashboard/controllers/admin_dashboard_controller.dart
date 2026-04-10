import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/app/routes/app_pages.dart';

class AdminDashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var currentTabIndex = 0.obs;

  final supabase = Supabase.instance.client;

  var eventsList = <RaceEventModel>[].obs;
  var groupedEvents = <String, List<RaceEventModel>>{}.obs;
  var championshipsList = <Map<String, dynamic>>[].obs;
  var activeChampionshipsList = <Map<String, dynamic>>[].obs;
  var pendingRegistrationsList = <Map<String, dynamic>>[].obs;

  var isLoadingEvents = false.obs;
  var isLoadingChamps = false.obs;
  var isLoadingRegs = false.obs;

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
      final response = await supabase.from('registrations').select('*, profiles(full_name), events(name), categories(name)').eq('status', 'pending');
      pendingRegistrationsList.value = response;
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoadingRegs.value = false;
    }
  }

  Future<void> confirmRegistration(int idRegistration) async {
    try {
      await supabase.from('registrations').update({'status': 'approved'}).eq('id_registration', idRegistration);
      Get.snackbar('Éxito', 'Inscripción confirmada', backgroundColor: Colors.green, colorText: Colors.white);
      fetchPendingRegistrations();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo confirmar', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void editChampionship(Map<String, dynamic> champ) async {
    final result = await Get.toNamed(Routes.CREATE_CHAMPIONSHIP, arguments: champ);
    // Cambiado 'Routes.CREATE_CHAMPIONampionship' a 'Routes.CREATE_CHAMPIONSHIP'
    // Asegúrate de que sea la constante correcta en tu proyecto
    // final result = await Get.toNamed(Routes.CREATE_CHAMPIONSHIP, arguments: champ);

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