import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_event_card.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:rcsync/app/modules/results/views/results_view.dart';
import 'package:rcsync/app/modules/profile/views/profile_view.dart';
import 'package:rcsync/app/modules/admin_dashboard/views/admin_dashboard_view.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() {
        // Soporte multitema
        Theme.of(context); 

        // Lista de vistas dinámica según rol
        List<Widget> views = [
          _buildCalendarTab(context),
          if (controller.isAdminOrOrganizer) const AdminDashboardView(), 
          const ResultsView(),
          const ProfileView(),
        ];

        return IndexedStack(
          index: controller.selectedIndex.value,
          children: views,
        );
      }),
      bottomNavigationBar: Obx(() {
        Theme.of(context);

        // Items de navegación dinámicos
        List<BottomBarItem> navItems = [
          BottomBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            selectedColor: RCColors.orange,
            unSelectedColor: RCColors.iconSecondary,
            title: Text("home_title".tr), 
          ),
          if (controller.isAdminOrOrganizer)
            BottomBarItem(
              icon: const Icon(Icons.shield_outlined),
              selectedIcon: const Icon(Icons.shield),
              selectedColor: RCColors.orange,
              unSelectedColor: RCColors.iconSecondary,
              title: const Text("Gestión"), // Pendiente añadir clave si se desea
            ),
          BottomBarItem(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            selectedColor: RCColors.orange,
            unSelectedColor: RCColors.iconSecondary,
            title: const Text("Resultados"),
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            selectedColor: RCColors.orange,
            unSelectedColor: RCColors.iconSecondary,
            title: Text("profile_title".tr),
          ),
        ];

        return StylishBottomBar(
          backgroundColor: RCColors.background,
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.changeIndex(index),
          option: AnimatedBarOptions(
            iconSize: 24,
            barAnimation: BarAnimation.fade,
            iconStyle: IconStyle.simple,
          ),
          items: navItems,
        );
      }),
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
                  Text(
                    "home_title".tr,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.settings_outlined, color: Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).toInt()),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "home_search_hint".tr,
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => controller.goToCreateEvent(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Calendario con soporte de tema
        Expanded(
          child: Container(
            color: RCColors.background,
            child: Obx(() {
              Theme.of(context);
              return Calendar(
                startOnMonday: true,
                weekDays: const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
                eventsList: controller.eventList.toList(),
                isExpandable: true,
                eventDoneColor: Colors.green,
                selectedColor: RCColors.orange,
                selectedTodayColor: RCColors.orange,
                todayColor: Colors.blueAccent,
                locale: Get.locale?.languageCode == 'es' ? 'es_ES' : (Get.locale?.languageCode == 'ca' ? 'ca_ES' : 'en_US'),
                isExpanded: true,
                expandableDateFormat: 'EEEE, dd MMMM yyyy',
                dayOfWeekStyle: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 11),
                defaultDayColor: RCColors.textPrimary,
                displayMonthTextStyle: TextStyle(color: RCColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                todayButtonText: "Hoy",
                bottomBarColor: RCColors.surface, 
                bottomBarTextStyle: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                bottomBarArrowColor: RCColors.textPrimary, 
                showEventListViewIcon: true,

                onDateSelected: (date) => controller.handleDateSelected(date),
                onMonthChanged: (date) => controller.handleMonthChanged(date),
                onListViewStateChanged: (state) => controller.toggleAllFutureEvents(),

                eventListBuilder: (context, events) {
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
                              style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.filter_list, color: RCColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (displayEvents.isEmpty)
                           Center(child: Padding(
                             padding: const EdgeInsets.all(20.0),
                             child: Text("home_no_events".tr, style: TextStyle(color: RCColors.textSecondary.withOpacity(0.5))),
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
