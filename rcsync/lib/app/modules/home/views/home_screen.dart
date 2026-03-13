import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_event_card.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:supabase_notes/app/modules/results/views/results_view.dart';
import 'package:supabase_notes/app/modules/map/views/map_view.dart';
import 'package:supabase_notes/app/modules/profile/views/profile_view.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              // --- TAB 0: CALENDARIO Y EVENTOS ---
              _buildCalendarTab(context),

              // --- TAB 1: Map ---
              const EventLocationMap(
                lat: 41.4833,
                lng: 2.1500,
                title: "Circuito AMSA",
              ),

              // --- TAB 2: Ranking/Results ---
              ResultsView(),

              // --- TAB 3: Profile ---
              const ProfileView(),
            ],
          )),
      bottomNavigationBar: Obx(() => StylishBottomBar(
            backgroundColor: RCColors.background,
            option: DotBarOptions(
              dotStyle: DotStyle.circle,
              gradient: const LinearGradient(
                colors: [RCColors.orange, Color(0xFFF68B28)],
              ),
            ),
            currentIndex: controller.selectedIndex.value,
            onTap: (index) => controller.changeIndex(index),
            items: [
              BottomBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                title: const Text('Eventos'),
              ),
              BottomBarItem(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                title: const Text('Mapa'),
              ),
              BottomBarItem(
                icon: const Icon(Icons.satellite_alt_outlined),
                title: const Text('Resultados'),
              ),
              BottomBarItem(
                icon: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
              ),
            ],
          )),
    );
  }

  Widget _buildCalendarTab(BuildContext context) {
    return Column(
      children: [
        // Header con degradado
        Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [RCColors.orange, Color(0xFFF68B28)],
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  const Text(
                    "Calendario",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.settings_outlined, color: Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).toInt()),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Buscar eventos...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Calendario
        Expanded(
          child: Container(
            color: RCColors.background,
            child: Obx(() {
              return Calendar(
                startOnMonday: true,
                weekDays: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
                eventsList: controller.eventList.toList(),
                isExpandable: true,
                eventDoneColor: Colors.green,
                selectedColor: RCColors.orange,
                selectedTodayColor: RCColors.orange,
                todayColor: Colors.blueAccent,
                locale: 'es_ES',
                isExpanded: true,
                expandableDateFormat: 'EEEE, dd MMMM yyyy',
                dayOfWeekStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                defaultDayColor: Colors.white,
                displayMonthTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                todayButtonText: "Hoy",
                bottomBarColor: const Color(0xFF1A222D), 
                bottomBarTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
                bottomBarArrowColor: Colors.white, 
                showEventListViewIcon: true,
                
                onDateSelected: (date) => controller.handleDateSelected(date),
                onMonthChanged: (date) => controller.handleMonthChanged(date),
                onListViewStateChanged: (state) => controller.toggleAllFutureEvents(),

                eventListBuilder: (context, events) {
                  // Determinamos qué lista de eventos mostrar basada en el estado del controlador
                  final displayEvents = controller.showAllFutureEvents.value 
                      ? controller.futureEvents 
                      : (controller.isDaySelected.value 
                          ? controller.eventsOfDay(controller.selectedDate.value) 
                          : controller.eventsOfCurrentMonth);

                  return Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.listTitle,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.filter_list, color: Colors.white70),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (displayEvents.isEmpty)
                           const Center(child: Padding(
                             padding: EdgeInsets.all(20.0),
                             child: Text("No hay carreras programadas", style: TextStyle(color: Colors.white54)),
                           )),
                        
                        ...displayEvents.map((event) => RCEventCard(
                          title: event.name,
                          location: event.circuitName ?? "Ubicación por definir",
                          date: event.eventDateIni ?? DateTime.now(),
                          imageUrl: event.imageEvent,
                          onTap: () => Get.toNamed(Routes.EVENT_DETAIL, arguments: event),
                        )),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
