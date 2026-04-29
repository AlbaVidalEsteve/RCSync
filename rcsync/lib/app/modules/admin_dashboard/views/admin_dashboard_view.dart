import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:rcsync/app/modules/admin_dashboard/controllers/admin_dashboard_controller.dart';
import 'package:rcsync/app/modules/admin_dashboard/views/import_results_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('adm_title'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [RCColors.orange, Color(0xFFF68B28)]
                )
            )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => Get.to(() => const ImportResultsView()),
            tooltip: 'import_results'.tr,
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'adm_tab_events'.tr),
            Tab(text: 'adm_tab_champs'.tr),
            Tab(text: 'adm_tab_regs'.tr)
          ],
        ),
      ),
      body: Column(
        children: [
          Container(height: 2, color: RCColors.orange),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [_buildEventosList(controller), _buildCampeonatosList(controller), _buildInscripcionesList(controller)],
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.currentTabIndex.value == 2) return const SizedBox.shrink();
        return Padding(
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
                Get.snackbar('adm_success_title'.tr, 'adm_success_created'.tr, backgroundColor: Colors.green, colorText: Colors.white);
                controller.loadAllData();
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }

  Widget _buildEventosList(AdminDashboardController controller) {
    return Obx(() {
      if (controller.isLoadingEvents.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));
      if (controller.groupedEvents.isEmpty) return Center(child: Text("adm_no_events".tr, style: TextStyle(color: RCColors.textSecondary)));
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
                  child: Text(champName.toUpperCase(), style: TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16))
              ),
              ...events.map((event) {
                final locale = Get.locale?.toLanguageTag() ?? 'es-ES';
                final dateStr = event.eventDateIni != null ? DateFormat.yMMMd(locale).format(event.eventDateIni!) : '---';
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
    });
  }

  Widget _buildCampeonatosList(AdminDashboardController controller) {
    return Obx(() {
      if (controller.isLoadingChamps.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));
      if (controller.activeChampionshipsList.isEmpty) return Center(child: Text("adm_no_champs".tr, style: TextStyle(color: RCColors.textSecondary)));

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
                  title: Text(champ['name'] ?? '---', style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text('${"adm_year".tr}: ${champ['year']}', style: TextStyle(color: RCColors.textSecondary)),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit, color: RCColors.orange),
                      onPressed: () => controller.editChampionship(champ)
                  )
              )
          );
        },
      );
    });
  }

  Widget _buildInscripcionesList(AdminDashboardController controller) {
    return Obx(() {
      if (controller.isLoadingRegs.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));

      // verificar si hay inscripciones
      final hasPending = controller.pendingRegistrationsList.isNotEmpty;
      final hasApproved = controller.approvedRegistrationsList.isNotEmpty;
      final hasDenied = controller.deniedRegistrationsList.isNotEmpty;

      if (!hasPending && !hasApproved && !hasDenied) {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                  const SizedBox(height: 10),
                  Text("adm_no_regs".tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 16))
                ]
            )
        );
      }

      return Column(
        children: [
          // Tabs para filtrar por estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Row(
              children: [
                _buildStatusPill(0, 'Pendientes', Icons.pending_actions, Colors.amber, controller),
                const SizedBox(width: 8),
                _buildStatusPill(1, 'Aprobados', Icons.check_circle, Colors.green, controller),
                const SizedBox(width: 8),
                _buildStatusPill(2, 'Rechazados', Icons.cancel, Colors.red, controller),
              ],
            ),
          ),

          // Lista segun pestaña
          Expanded(
            child: IndexedStack(
              index: controller.regTabIndex.value,
              children: [
                _buildRegList(controller.pendingRegistrationsList, controller, 'pending'),
                _buildRegList(controller.approvedRegistrationsList, controller, 'approved'),
                _buildRegList(controller.deniedRegistrationsList, controller, 'denied'),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatusPill(int index, String label, IconData icon, Color color, AdminDashboardController controller) {
    final isSelected = controller.regTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.regTabIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : RCColors.card,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? color : RCColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : RCColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : RCColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegList(RxList<Map<String, dynamic>> registrations, AdminDashboardController controller, String status) {
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' ? Icons.pending_actions :
              (status == 'approved' ? Icons.check_circle : Icons.cancel),
              size: 50,
              color: status == 'pending' ? Colors.orange :
              (status == 'approved' ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              status == 'pending' ? 'No hay inscripciones pendientes' :
              (status == 'approved' ? 'No hay inscripciones aprobadas' : 'No hay inscripciones rechazadas'),
              style: TextStyle(color: RCColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: registrations.length,
      itemBuilder: (context, index) {
        final reg = registrations[index];
        final pilotName = reg['profiles']?['full_name'] ?? '---';
        final eventName = reg['events']?['name'] ?? '---';
        final categoryName = reg['categories']?['name'] ?? '';
        final pilotImage = reg['profiles']?['image_profile'];

        return Card(
          color: RCColors.card,
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: status == 'pending' ? Colors.amber :
              (status == 'approved' ? Colors.green : Colors.red),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: CircleAvatar(
                backgroundColor: RCColors.background,
                backgroundImage: pilotImage != null ? NetworkImage(pilotImage) : null,
                child: pilotImage == null ? Icon(Icons.person, color: RCColors.iconSecondary) : null,
              ),
              title: Text(pilotName, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(eventName, style: TextStyle(color: RCColors.textSecondary)),
                  Text('${"res_category".tr}: $categoryName', style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (status == 'pending') ...[
                    // Boton aceptar verde
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        final regId = reg['id_registration'];
                        if (regId != null) controller.confirmRegistration(regId);
                      },
                      tooltip: 'Aceptar inscripción',
                    ),
                    // Boton rechazar naranja
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.orange),
                      onPressed: () {
                        final regId = reg['id_registration'];
                        if (regId != null) controller.denyRegistration(regId);
                      },
                      tooltip: 'Rechazar inscripción',
                    ),
                  ],
                  // Boton cancelar/Borrar rojo
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      final regId = reg['id_registration'];
                      if (regId != null) controller.cancelRegistration(regId);
                    },
                    tooltip: 'Cancelar y eliminar inscripción',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}