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
    // Escuchar el tema para cambios reactivos
    Theme.of(context);
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Panel de Gestión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [RCColors.orange, Color(0xFFF68B28)]))),
        bottom: TabBar(
          controller: controller.tabController, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Eventos'), Tab(text: 'Campeonatos'), Tab(text: 'Inscripciones')],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [_buildEventosList(controller), _buildCampeonatosList(controller), _buildInscripcionesList(controller)],
      ),
      floatingActionButton: Obx(() {
        if (controller.currentTabIndex.value == 2) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 90.0),
          child: FloatingActionButton(
            backgroundColor: RCColors.orange, foregroundColor: Colors.white, elevation: 4,
            onPressed: () async {
              dynamic result;
              if (controller.currentTabIndex.value == 0) {
                result = await Get.toNamed(Routes.CREATE_EVENT);
              } else if (controller.currentTabIndex.value == 1) result = await Get.toNamed(Routes.CREATE_CHAMPIONSHIP);
              if (result == true) {
                Get.snackbar('Éxito', 'Creado correctamente', backgroundColor: Colors.green, colorText: Colors.white);
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
      if (controller.groupedEvents.isEmpty) return Center(child: Text("No hay eventos activos", style: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.5))));
      final groups = controller.groupedEvents.entries.toList();

      return ListView.builder(
        padding: const EdgeInsets.all(15), itemCount: groups.length,
        itemBuilder: (context, index) {
          final champName = groups[index].key;
          final events = groups[index].value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(champName.toUpperCase(), style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16))),
              ...events.map((event) {
                final dateStr = event.eventDateIni != null ? DateFormat('dd MMM yyyy', 'es_ES').format(event.eventDateIni!) : 'Sin fecha';
                return Card(
                  color: RCColors.card, 
                  margin: const EdgeInsets.only(bottom: 10), 
                  child: ListTile(
                    title: Text(event.name, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)), 
                    subtitle: Text(dateStr, style: TextStyle(color: RCColors.textSecondary)), 
                    trailing: IconButton(icon: const Icon(Icons.edit, color: RCColors.orange), onPressed: () => controller.editEvent(event))
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
      if (controller.activeChampionshipsList.isEmpty) return Center(child: Text("No hay campeonatos activos para editar", style: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.5))));

      return ListView.builder(
        padding: const EdgeInsets.all(15), itemCount: controller.activeChampionshipsList.length,
        itemBuilder: (context, index) {
          final champ = controller.activeChampionshipsList[index];
          return Card(
            color: RCColors.card, 
            margin: const EdgeInsets.only(bottom: 10), 
            child: ListTile(
              title: Text(champ['name'] ?? 'Sin nombre', style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)), 
              subtitle: Text('Año: ${champ['year']}', style: TextStyle(color: RCColors.textSecondary)), 
              trailing: IconButton(icon: const Icon(Icons.edit, color: RCColors.orange), onPressed: () => controller.editChampionship(champ))
            )
          );
        },
      );
    });
  }

  Widget _buildInscripcionesList(AdminDashboardController controller) {
    return Obx(() {
      if (controller.isLoadingRegs.value) return const Center(child: CircularProgressIndicator(color: RCColors.orange));
      if (controller.pendingRegistrationsList.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline, color: Colors.green, size: 60), const SizedBox(height: 10), Text("No hay inscripciones pendientes", style: TextStyle(color: RCColors.textSecondary.withValues(alpha: 0.5), fontSize: 16))]));

      return ListView.builder(
        padding: const EdgeInsets.all(15), itemCount: controller.pendingRegistrationsList.length,
        itemBuilder: (context, index) {
          final reg = controller.pendingRegistrationsList[index];
          final pilotName = reg['profiles']?['full_name'] ?? 'Piloto Desconocido';
          final eventName = reg['events']?['name'] ?? 'Evento Desconocido';
          final categoryName = reg['categories']?['name'] ?? '';
          return Card(
            color: RCColors.card, 
            margin: const EdgeInsets.only(bottom: 10), 
            child: ListTile(
              title: Text(pilotName, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)), 
              subtitle: Text('$eventName\nCategoría: $categoryName', style: TextStyle(color: RCColors.textSecondary)), 
              isThreeLine: true, 
              trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () { final regId = reg['id_registration']; if (regId != null) controller.confirmRegistration(regId); }, child: const Text('Confirmar', style: TextStyle(color: Colors.white)))
            )
          );
        },
      );
    });
  }
}
