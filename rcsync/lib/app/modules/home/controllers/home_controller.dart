import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/app/data/models/profiles_model.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import '../../../routes/app_pages.dart';
import '../../admin_dashboard/controllers/admin_dashboard_controller.dart';
import '../../results/controllers/results_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  SupabaseClient client = Supabase.instance.client;

  var selectedIndex = 0.obs;

  final RxList<RaceEventModel> rawEvents = <RaceEventModel>[].obs;
  final RxList<NeatCleanCalendarEvent> eventList = <NeatCleanCalendarEvent>[].obs;

  // Perfil del usuario actual
  final Rxn<ProfileModel> userProfile = Rxn<ProfileModel>();

  // New states for the filtering logic
  var selectedDate = DateTime.now().obs;
  var isDaySelected = false.obs;
  var currentMonth = DateTime.now().obs;
  var showAllFutureEvents = false.obs;

  @override
  void onInit() {
    super.onInit();
    getEvents();
    getCurrentUserProfile();
  }

  // Getter para verificar si es admin u organizador
  bool get isAdminOrOrganizer {
    final role = userProfile.value?.rol.toLowerCase() ?? 'piloto';
    return role == 'admin' || role == 'organizador';
  }

  // Cambiar índice y actualizar datos según la pestaña seleccionada
  void changeIndex(int index) {
    selectedIndex.value = index;
    _refreshDataByTab(index);
  }

  // Actualizar datos según la pestaña seleccionada
  void _refreshDataByTab(int index) {
    switch (index) {
      case 0: // Eventos
        getEvents();
        break;
      case 1: // Admin Dashboard (solo si es admin/organizador)
        if (isAdminOrOrganizer && Get.isRegistered<AdminDashboardController>()) {
          Get.find<AdminDashboardController>().loadAllData();
        }
        break;
      case 2: // Resultados
        if (Get.isRegistered<ResultsController>()) {
          final resultsController = Get.find<ResultsController>();
          resultsController.fetchAvailableYears();
        }
        break;
      case 3: // Perfil
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          profileController.getProfile();
          profileController.getTransponders();
        }
        break;
    }
  }

  // Refrescar todos los datos (útil cuando la app vuelve a primer plano)
  void refreshAllData() {
    getEvents();
    getCurrentUserProfile();

    if (Get.isRegistered<AdminDashboardController>()) {
      Get.find<AdminDashboardController>().loadAllData();
    }
    if (Get.isRegistered<ResultsController>()) {
      Get.find<ResultsController>().fetchAvailableYears();
    }
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      profileController.getProfile();
      profileController.getTransponders();
    }
  }

  Future<void> getCurrentUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        final response = await client
            .from('profiles')
            .select()
            .eq('id_profile', user.id)
            .single();
        userProfile.value = ProfileModel.fromJson(response);
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  void goToCreateEvent() {
    if (userProfile.value == null) {
      Get.snackbar("Error", "No se pudo cargar tu perfil");
      return;
    }

    final role = userProfile.value!.rol.toLowerCase();
    if (role == 'admin' || role == 'organizador') {
      Get.toNamed(Routes.CREATE_EVENT);
    } else {
      Get.snackbar(
        "Acceso denegado",
        "No tienes permisos para agregar un evento",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getEvents() async {
    try {
      isLoading.value = true;
      final response = await client.from("events").select('''
        *,
        circuits (*),
        championships (
          *,
          profiles (*)
        )
      ''').order("event_date_ini", ascending: true);

      final List<RaceEventModel> fetchedEvents = [];

      for (var eventJson in response) {
        int categoriesCount = 0;

        // Si el evento tiene campeonato, obtener sus categorías
        if (eventJson['id_championship'] != null) {
          final champCategories = await client
              .from('championship_categories')
              .select('id_category')
              .eq('id_championship', eventJson['id_championship']);

          categoriesCount = champCategories.length;
        }

        final enrichedEvent = {
          ...eventJson,
          'categories_count': categoriesCount,
        };

        fetchedEvents.add(RaceEventModel.fromJson(enrichedEvent));
      }

      rawEvents.assignAll(fetchedEvents);

      eventList.assignAll(fetchedEvents.map((e) => NeatCleanCalendarEvent(
        e.name,
        startTime: e.eventDateIni ?? DateTime.now(),
        endTime: e.eventDateFin ?? (e.eventDateIni ?? DateTime.now()).add(const Duration(hours: 8)),
        description: e.circuitName ?? e.description ?? '',
        color: Colors.blueAccent,
      )).toList());

    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to get events for the currently shown month
  List<RaceEventModel> get eventsOfCurrentMonth {
    return rawEvents.where((e) {
      if (e.eventDateIni == null) return false;
      return e.eventDateIni!.year == currentMonth.value.year &&
          e.eventDateIni!.month == currentMonth.value.month;
    }).toList();
  }

  // Helper to get all future events
  List<RaceEventModel> get futureEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return rawEvents.where((e) {
      if (e.eventDateIni == null) return false;
      return e.eventDateIni!.isAfter(today.subtract(const Duration(seconds: 1)));
    }).toList();
  }

  // Helper to get events for a specific day
  List<RaceEventModel> eventsOfDay(DateTime date) {
    return rawEvents.where((e) {
      if (e.eventDateIni == null) return false;
      return e.eventDateIni!.year == date.year &&
          e.eventDateIni!.month == date.month &&
          e.eventDateIni!.day == date.day;
    }).toList();
  }

  String get listTitle {
    if (showAllFutureEvents.value) {
      return "upcoming_events".tr;
    }
    if (isDaySelected.value) {
      return "${'events_of_day'.tr} ${DateFormat('dd MMMM', Get.locale?.languageCode ?? 'es').format(selectedDate.value)}";
    } else {
      return "${'events_of_month'.tr} ${DateFormat('MMMM', Get.locale?.languageCode ?? 'es').format(currentMonth.value)}";
    }
  }

  void handleDateSelected(DateTime date) {
    showAllFutureEvents.value = false;
    if (isDaySelected.value &&
        selectedDate.value.year == date.year &&
        selectedDate.value.month == date.month &&
        selectedDate.value.day == date.day) {
      // Toggle off if same day clicked
      isDaySelected.value = false;
    } else {
      selectedDate.value = date;
      isDaySelected.value = true;
    }
  }

  void handleMonthChanged(DateTime date) {
    currentMonth.value = date;
    isDaySelected.value = false;
    showAllFutureEvents.value = false;
  }

  void toggleAllFutureEvents() {
    showAllFutureEvents.value = !showAllFutureEvents.value;
    if (showAllFutureEvents.value) {
      isDaySelected.value = false;
    }
  }
}