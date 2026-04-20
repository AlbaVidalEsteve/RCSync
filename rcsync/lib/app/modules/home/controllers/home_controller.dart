import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:rcsync/app/data/models/profiles_model.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  SupabaseClient client = Supabase.instance.client;

  var selectedIndex = 0.obs;

  final RxList<RaceEventModel> rawEvents = <RaceEventModel>[].obs;
  final RxList<NeatCleanCalendarEvent> eventList = <NeatCleanCalendarEvent>[].obs;
  
  final Rxn<ProfileModel> userProfile = Rxn<ProfileModel>();

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

  bool get isAdminOrOrganizer {
    final role = userProfile.value?.rol.toLowerCase() ?? 'piloto';
    return role == 'admin' || role == 'organizador';
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
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
      debugPrint("Error fetching user profile: $e");
    }
  }

  void goToCreateEvent() {
    if (userProfile.value == null) {
      Get.snackbar("Error", "No se pudo cargar tu perfil");
      return;
    }
    if (isAdminOrOrganizer) {
      Get.toNamed(Routes.CREATE_EVENT);
    } else {
      Get.snackbar(
        "access_denied_title".tr, 
        "access_denied_msg".tr,
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
      
      final List<RaceEventModel> fetchedEvents = RaceEventModel.fromJsonList(response);
      rawEvents.assignAll(fetchedEvents);

      eventList.assignAll(fetchedEvents.map((e) => NeatCleanCalendarEvent(
        e.name,
        startTime: e.eventDateIni ?? DateTime.now(),
        endTime: e.eventDateFin ?? (e.eventDateIni ?? DateTime.now()).add(const Duration(hours: 8)),
        description: e.circuitName ?? e.description ?? '',
        color: Colors.blueAccent,
      )).toList());
    } catch (e) {
      debugPrint("Error fetching events: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPERS PARA EL CALENDARIO ---
  
  List<RaceEventModel> get eventsOfCurrentMonth {
    return rawEvents.where((e) {
      if (e.eventDateIni == null) return false;
      return e.eventDateIni!.year == currentMonth.value.year && 
             e.eventDateIni!.month == currentMonth.value.month;
    }).toList();
  }

  List<RaceEventModel> get futureEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return rawEvents.where((e) {
      if (e.eventDateIni == null) return false;
      return e.eventDateIni!.isAfter(today.subtract(const Duration(seconds: 1)));
    }).toList();
  }

  List<RaceEventModel> eventsOfDay(DateTime date) {
    return rawEvents.where((e) {
      if (e.eventDateIni == null) return false;
      return e.eventDateIni!.year == date.year && 
             (e.eventDateIni!.month == date.month) && 
             (e.eventDateIni!.day == date.day);
    }).toList();
  }

  String get listTitle {
    if (showAllFutureEvents.value) {
      return "home_future_events".tr;
    }
    
    String lang = Get.locale?.languageCode ?? 'es';
    String country = Get.locale?.countryCode ?? '';
    String fullLocale = country.isEmpty ? lang : "${lang}_$country";
    
    String title = "home_events_title".tr;
    
    if (isDaySelected.value) {
      String connector = "home_events_on".tr;
      return "$title $connector ${DateFormat('dd MMMM', fullLocale).format(selectedDate.value)}";
    } else {
      String connector = "home_events_of".tr;
      return "$title $connector ${DateFormat('MMMM', fullLocale).format(currentMonth.value)}";
    }
  }

  void handleDateSelected(DateTime date) {
    showAllFutureEvents.value = false;
    if (isDaySelected.value && 
        selectedDate.value.year == date.year && 
        selectedDate.value.month == date.month && 
        selectedDate.value.day == date.day) {
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
