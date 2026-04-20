import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Get.find si ya está inyectado o Get.put si no.
    final controller = Get.isRegistered<AdminDashboardController>() 
        ? Get.find<AdminDashboardController>() 
        : Get.put(AdminDashboardController());

    return Obx(() {
      // Forzamos que el Scaffold reaccione al cambio de idioma
      Theme.of(context);
      final locale = Get.locale; // Escuchamos el locale

      return Scaffold(
        backgroundColor: RCColors.background,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('admin_title'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, 
                end: Alignment.bottomRight, 
                colors: [RCColors.orange, Color(0xFFF68B28)]
              )
            )
          ),
          bottom: TabBar(
            controller: controller.tabController, 
            indicatorColor: Colors.white, 
            indicatorWeight: 3,
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.white70,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'admin_tab_events'.tr), 
              Tab(text: 'admin_tab_champs'.tr), 
              Tab(text: 'admin_tab_regs'.tr)
            ],
          ),
        ),
        body: Column(
          children: [
            Container(height: 2, color: RCColors.orange),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildEventosList(controller), 
                  _buildCampeonatosList(controller), 
                  _buildInscripcionesList(controller)
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: controller.currentTabIndex.value == 2 
            ? const SizedBox.shrink() 
            : Padding(
                padding: const EdgeInsets.only(bottom: 90.0),
                child: FloatingActionButton(
                  backgroundColor: RCColors.orange, 
                  foregroundColor: Colors.white, 
                  elevation: 4,
                  onPressed: () async {
                    dynamic result;
                    if (controller.currentTabIndex.value == 0) {
                      result = await Get.toNamed(Routes.CREATE_EVENT);
                    } else if (controller.currentTabIndex.value == 1) {
                      result = await Get.toNamed(Routes.CREATE_CHAMPIONSHIP);
                    }
                    if (result == true) {
                      Get.snackbar('Éxito', 'success_created'.tr, backgroundColor: Colors.green, colorText: Colors.white);
                      controller.loadAllData();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ),
      );
    });
  }

  Widget _buildEventosList(AdminDashboardController controller) {
    if (controller.isLoadingEvents.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));
    if (controller.groupedEvents.isEmpty) return Center(child: Text("admin_no_active_events".tr, style: TextStyle(color: RCColors.textSecondary)));
    final groups = controller.groupedEvents.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(15), 
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final champName = groups[index].key;
        final events = groups[index].value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10), 
              child: Text(champName.toUpperCase(), style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16))
            ),
            ...events.map((event) {
              final locale = Get.locale?.toString() ?? 'es_ES';
              final dateStr = event.eventDateIni != null ? DateFormat('dd MMM yyyy', locale).format(event.eventDateIni!) : 'Sin fecha';
              return Card(
                color: RCColors.card, 
                margin: const EdgeInsets.only(bottom: 10), 
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(event.name, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)), 
                  subtitle: Text(dateStr, style: TextStyle(color: RCColors.textSecondary)), 
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: RCColors.orange),
                    onPressed: () => controller.editEvent(event)
                  )
                )
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCampeonatosList(AdminDashboardController controller) {
    if (controller.isLoadingChamps.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));
    if (controller.activeChampionshipsList.isEmpty) return Center(child: Text("admin_no_active_champs".tr, style: TextStyle(color: RCColors.textSecondary)));

    return ListView.builder(
      padding: const EdgeInsets.all(15), 
      itemCount: controller.activeChampionshipsList.length,
      itemBuilder: (context, index) {
        final champ = controller.activeChampionshipsList[index];
        return Card(
          color: RCColors.card, 
          margin: const EdgeInsets.only(bottom: 10), 
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(champ['name'] ?? 'Sin nombre', style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)), 
            subtitle: Text('Año: ${champ['year']}', style: TextStyle(color: RCColors.textSecondary)), 
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: RCColors.orange),
              onPressed: () => controller.editChampionship(champ)
            )
          )
        );
      },
    );
  }

  Widget _buildInscripcionesList(AdminDashboardController controller) {
    if (controller.isLoadingRegs.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));
    if (controller.pendingRegistrationsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 60), 
            const SizedBox(height: 10), 
            Text("admin_no_pending_regs".tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 16))
          ]
        )
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15), 
      itemCount: controller.pendingRegistrationsList.length,
      itemBuilder: (context, index) {
        final reg = controller.pendingRegistrationsList[index];
        final pilotName = reg['profiles']?['full_name'] ?? 'Piloto Desconocido';
        final eventName = reg['events']?['name'] ?? 'Evento Desconocido';
        final categoryName = reg['categories']?['name'] ?? '';
        return Card(
          color: RCColors.card, 
          margin: const EdgeInsets.only(bottom: 10), 
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(pilotName, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)), 
            subtitle: Text('$eventName\nCategoría: $categoryName', style: TextStyle(color: RCColors.textSecondary)),
            isThreeLine: true, 
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ), 
              onPressed: () { 
                final regId = reg['id_registration']; 
                if (regId != null) controller.confirmRegistration(regId); 
              }, 
              child: Text('admin_confirm_btn'.tr)
            )
          )
        );
      },
    );
  }
}
