import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_notes/core/theme/rc_colors.dart';
import 'package:supabase_notes/core/widgets/rc_event_card.dart';
import 'package:supabase_notes/core/widgets/rc_primary_button.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:supabase_notes/app/modules/results/views/results_view.dart';

/// The main dashboard screen showing upcoming events with a stylish bottom bar.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Required for the floating effect of the bottom bar
      appBar: AppBar(
        title: Image.asset('assets/images/logo_rcsync.jpeg', height: 100),
        backgroundColor: RCColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              // --- TAB 0: HOME / RACES ---
              RefreshIndicator(
                onRefresh: () => controller.getEvents(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    Text(
                      "Próximas Carreras",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 20),
                    // Aquí podrías mapear controller.eventList para mostrar RCEventCard dinámicos
                    ...controller.eventList.map((event) => RCEventCard(
                          title: event.summary,
                          location: event.description,
                          date: event.startTime,
                          onTap: () {},
                        )),
                    const SizedBox(height: 10),
                    RCPrimaryButton(
                      label: "Proponer Nuevo Evento",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // --- TAB 1: Events (Calendar) ---
              SafeArea(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: RCColors.orange))
                    : Calendar(
                        startOnMonday: true,
                        weekDays: const ['Lu', 'Ma', 'Mx', 'Jv', 'Vr', 'Sa', 'Do'],
                        eventsList: controller.eventList,
                        isExpandable: true,
                        eventDoneColor: Colors.green,
                        selectedColor: RCColors.orange,
                        selectedTodayColor: RCColors.orange,
                        todayColor: Colors.blue,
                        eventColor: null,
                        locale: 'es_ES',
                        todayButtonText: 'Hoy',
                        allDayEventText: 'Todo el día',
                        multiDayEndText: 'Fin',
                        isExpanded: true,
                        expandableDateFormat: 'EEEE, dd MMMM yyyy',
                        datePickerType: DatePickerType.date,
                        dayOfWeekStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11),
                      ),
              ),

              // --- TAB 2: Ranking ---
              ResultsView(),
              // --- TAB 3: Admin ---
              const Center(
                child: Text(
                  "Admin",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              // --- TAB 4: Profile ---
              const Center(
                child: Text(
                  "Profile",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          )),
      bottomNavigationBar: Obx(() => StylishBottomBar(
            backgroundColor: RCColors.background,
            option: DotBarOptions(
              dotStyle: DotStyle.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF24E02),
                  Color(0xFFF68B28),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            fabLocation: StylishBarFabLocation.end,
            hasNotch: true,
            currentIndex: controller.selectedIndex.value,
            onTap: (index) {
              controller.changeIndex(index);
            },
            items: [
              BottomBarItem(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                title: const Text('Home'),
                backgroundColor: RCColors.orange,
                selectedColor: const Color(0xFFF24E02),
              ),
              BottomBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today_outlined),
                title: const Text('Events'),
                backgroundColor: RCColors.orange,
                selectedColor: const Color(0xFFF24E02),
              ),
              BottomBarItem(
                icon: const Icon(Icons.satellite_alt_outlined),
                title: const Text('Ranking'),
                backgroundColor: RCColors.orange,
                selectedColor: const Color(0xFFF24E02),
              ),
              BottomBarItem(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin'),
                backgroundColor: RCColors.orange,
                selectedColor: RCColors.orange,
              ),
              BottomBarItem(
                icon: const Icon(Icons.person_2_outlined),
                selectedIcon: const Icon((Icons.person_2)),
                title: const Text('Profile'),
                backgroundColor: RCColors.orange,
                selectedColor: const Color(0xFFF24E02),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the FAB
        },
        backgroundColor: const Color(0xFFF24E02),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
