import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_notes/app/data/models/supermercats_model.dart';
import 'package:supabase_notes/app/data/models/race_event_model.dart';
import 'package:supabase_notes/core/theme/rc_colors.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class HomeController extends GetxController {
  RxList<Supermercat> allSupermarkets = <Supermercat>[].obs;
  RxBool isLoading = false.obs;
  SupabaseClient client = Supabase.instance.client;

  // Track the current index for the stylish bottom bar
  var selectedIndex = 0.obs;

  final RxList<NeatCleanCalendarEvent> eventList = <NeatCleanCalendarEvent>[].obs;

  @override
  void onInit() {
    super.onInit();
    getEvents();
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  Future<void> getEvents() async {
    try {
      isLoading.value = true;
      final response = await client.from("events").select().order("event_date_ini", ascending: true);
      final List<RaceEventModel> fetchedEvents = RaceEventModel.fromJsonList(response);

      // Map database events to the calendar format
      eventList.assignAll(fetchedEvents.map((e) => NeatCleanCalendarEvent(
        e.name,
        startTime: e.eventDateIni ?? DateTime.now(),
        endTime: e.eventDateFin ?? (e.eventDateIni ?? DateTime.now()).add(const Duration(hours: 8)),
        description: e.description ?? '',
        color: RCColors.orange,
      )).toList());

    } catch (e) {
      print("Error fetching events: $e");
      Get.snackbar("Error", "No s'han pogut carregar els esdeveniments");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllSupermarquets() async {
    try {
      final response = await client
          .from("supermercats")
          .select()
          .order("id", ascending: false);
      
      allSupermarkets.assignAll(Supermercat.fromJsonList(response));
    } catch (e) {
      print("Error fetching supermarkets: $e");
    }
  }

  Future<void> deleteSupermercat(int id) async {
    try {
      await client.from("supermercats").delete().eq("id", id);
      allSupermarkets.removeWhere((element) => element.id == id);
      Get.snackbar("Success", "Supermercat eliminat correctament");
    } catch (e) {
      print("Error deleting supermarket: $e");
      Get.snackbar("Error", "No s'ha pogut eliminar el supermercat");
    }
  }
}
