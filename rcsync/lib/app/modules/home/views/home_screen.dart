import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_event_card.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/app/modules/home/controllers/home_controller.dart';
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
        final isAdmin = controller.isAdminOrOrganizer;
        final index = controller.selectedIndex.value;
        List<Widget> views = [
          _buildCalendarTab(context),
          if (isAdmin) const AdminDashboardView(),
          const ResultsView(),
          const ProfileView(),
        ];
        return IndexedStack(
          index: index,
          children: views,
        );
      }),
      bottomNavigationBar: Obx(() {
        Theme.of(context);
        List<BottomBarItem> navItems = [
          BottomBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            selectedColor: RCColors.orange,
            unSelectedColor: RCColors.iconSecondary,
            title: Text("nav_events".tr),
          ),
          if (controller.isAdminOrOrganizer)
            BottomBarItem(
              icon: const Icon(Icons.shield_outlined),
              selectedIcon: const Icon(Icons.shield),
              selectedColor: RCColors.orange,
              unSelectedColor: RCColors.iconSecondary,
              title: Text("nav_mgmt".tr),
            ),
          BottomBarItem(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            selectedColor: RCColors.orange,
            unSelectedColor: RCColors.iconSecondary,
            title: Text("nav_results".tr),
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            selectedColor: RCColors.orange,
            unSelectedColor: RCColors.iconSecondary,
            title: Text("nav_profile".tr),
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
    return Container(
      color: RCColors.background,
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.getEvents();
          await controller.getCurrentUserProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                padding: const EdgeInsets.only(top: 60),
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [RCColors.orange, Color(0xFFF68B28)],
                  ),
                ),
                child: Text(
                  "cal_title".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -60),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: RCColors.card,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(Get.isDarkMode ? 0.3 : 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Calendar(
                          startOnMonday: true,
                          weekDays: [
                            'cal_mon'.tr,
                            'cal_tue'.tr,
                            'cal_wed'.tr,
                            'cal_thu'.tr,
                            'cal_fri'.tr,
                            'cal_sat'.tr,
                            'cal_sun'.tr,
                          ],
                          eventsList: controller.eventList.toList(),
                          isExpandable: true,
                          eventDoneColor: Colors.green,
                          selectedColor: RCColors.orange,
                          selectedTodayColor: RCColors.orange,
                          todayColor: Colors.blueAccent,
                          locale: Get.locale?.languageCode ?? 'es',
                          isExpanded: true,
                          expandableDateFormat: 'EEEE, dd MMMM yyyy',
                          dayOfWeekStyle: TextStyle(
                            color: RCColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                          defaultDayColor: RCColors.textPrimary,
                          displayMonthTextStyle: TextStyle(
                            color: RCColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          todayButtonText: "cal_today".tr,
                          bottomBarColor: RCColors.surface,
                          bottomBarTextStyle: TextStyle(color: RCColors.textPrimary, fontSize: 14),
                          bottomBarArrowColor: RCColors.textPrimary,
                          showEventListViewIcon: false,
                          onDateSelected: (date) => controller.handleDateSelected(date),
                          onMonthChanged: (date) => controller.handleMonthChanged(date),
                          onListViewStateChanged: (state) => controller.toggleAllFutureEvents(),
                          eventListBuilder: (context, events) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Obx(() {
                        final displayEvents = controller.showAllFutureEvents.value
                            ? controller.futureEvents
                            : (controller.isDaySelected.value
                            ? controller.eventsOfDay(controller.selectedDate.value)
                            : controller.eventsOfCurrentMonth);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.listTitle,
                                  style: TextStyle(
                                    color: RCColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.filter_list, color: RCColors.textSecondary),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (displayEvents.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "no_events_scheduled".tr,
                                    style: TextStyle(
                                      color: RCColors.textSecondary.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ...displayEvents.asMap().entries.map((entry) {
                              final index = entry.key;
                              final event = entry.value;
                              return RCEventCard(
                                index: index,
                                title: event.name,
                                location: event.circuitName ?? "no_location".tr,
                                date: event.eventDateIni ?? DateTime.now(),
                                imageUrl: event.imageEvent,
                                categoriesCount: event.categoriesCount,
                                onTap: () => Get.toNamed(Routes.EVENT_DETAIL, arguments: event),
                              );
                            }),
                            const SizedBox(height: 100),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}