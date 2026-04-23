import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_primary_button.dart';
import 'package:rcsync/app/modules/map/views/map_view.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';

class EventDetailsView extends GetView<EventDetailsController> {
  const EventDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: RCColors.background,
      body: Obx(() {
        if (controller.isLoading.value && controller.registeredPilots.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: RCColors.orange));
        }

        final RaceEventModel event = controller.event.value;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: RCColors.background,
              leading: _buildBackBtn(),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderBackground(event),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 1. Info Evento
                      _buildEventInfo(event),
                      const SizedBox(height: 20),

                      // 2. Botón de Exportar (solo para admin/organizador)
                      if (controller.isAdminOrOrganizer.value)
                        _buildExportButton(),
                      const SizedBox(height: 20),

                      // 3. Reglamentos colapsable
                      _buildRulebooksSection(),
                      const SizedBox(height: 20),

                      // 4. Descripcion evento colapsable
                      _buildDescriptionSection(event),
                      const SizedBox(height: 20),

                      // 5. Pilotos inscritos y confirmados colapsable
                      _buildPilotList(),
                      const SizedBox(height: 20),

                      // 6. Mapa y ubicacion
                      _buildLocation(event),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        );
      }),
      bottomSheet: _buildBottomAction(),
    );
  }

  // Header
  Widget _buildHeaderBackground(RaceEventModel event) => Stack(
    fit: StackFit.expand,
    children: [
      if (event.imageEvent != null)
        Image.network(event.imageEvent!, fit: BoxFit.cover)
      else
        Container(
            color: RCColors.orange.withValues(alpha: 0.2),
            child: const Icon(Icons.image, size: 100, color: Colors.white24)
        ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, RCColors.background],
          ),
        ),
      ),
    ],
  );

  Widget _buildBackBtn() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: CircleAvatar(
      backgroundColor: Colors.black38,
      child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back()
      ),
    ),
  );

  // Botón de Exportar
  Widget _buildExportButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [RCColors.orange, Color(0xFFF68B28)],
        ),
        boxShadow: [
          BoxShadow(
            color: RCColors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () => controller.exportRegisteredPilots(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'export_pilots'.tr.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info Evento
  Widget _buildEventInfo(RaceEventModel event) => _buildSection(
    title: event.name,
    child: Column(
      children: [
        _buildDetailRow(
            icon: Icons.calendar_today,
            iconColor: RCColors.orange,
            title: 'det_date'.tr,
            subtitle: controller.formattedDate
        ),
        _buildDetailRow(
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber,
            title: 'det_organizer'.tr,
            subtitle: event.organizerName ?? 'Club RC'
        ),
      ],
    ),
  );

  // Reglamentos
  Widget _buildRulebooksSection() {
    return Obx(() {
      if (controller.rulebooks.isEmpty) return const SizedBox.shrink();

      return _buildCollapsibleSection(
        title: 'det_tech_rules'.tr,
        icon: Icons.rule_folder_outlined,
        isExpanded: controller.isRulebooksExpanded.value,
        onToggle: () => controller.isRulebooksExpanded.value = !controller.isRulebooksExpanded.value,
        child: Column(
          children: controller.rulebooks.map((rb) {
            final catName = rb['categories']?['name'] ?? 'evt_none'.tr;
            final url = rb['rulebook_url'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: RCColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                title: Text(
                  '${'det_rulebook'.tr} $catName',
                  style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text('det_open_pdf'.tr, style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios, color: RCColors.iconSecondary, size: 16),
                onTap: () => controller.openRulebook(url),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // Descripcion
  Widget _buildDescriptionSection(RaceEventModel event) {
    final String? description = event.description;
    if (description == null || description.trim().isEmpty) return const SizedBox.shrink();

    return Obx(() => _buildCollapsibleSection(
      title: 'det_description'.tr,
      icon: Icons.info_outline,
      isExpanded: controller.isDescriptionExpanded.value,
      onToggle: () => controller.isDescriptionExpanded.value = !controller.isDescriptionExpanded.value,
      child: Text(
        description,
        style: TextStyle(color: RCColors.textSecondary, fontSize: 14, height: 1.6),
      ),
    ));
  }

  // Pilotos Inscritos
  Widget _buildPilotList() => Obx(() {
    if (controller.registeredPilots.isEmpty) return const SizedBox.shrink();

    return _buildCollapsibleSection(
      title: 'det_pilots'.tr,
      icon: Icons.people_outline,
      isExpanded: controller.isPilotsExpanded.value,
      onToggle: () => controller.isPilotsExpanded.value = !controller.isPilotsExpanded.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.registeredPilots.entries.map(
                (entry) => _buildCategoryGroup(entry.key, entry.value),
          ),
        ],
      ),
    );
  });

  Widget _buildCategoryGroup(String category, List<RegisteredPilot> pilots) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: RCColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${pilots.length} ${'det_pilots_count'.tr}',
                style: const TextStyle(
                  color: RCColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      ...pilots.map((pilot) => Card(
        color: RCColors.card,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: RCColors.background,
            backgroundImage: pilot.imageUrl != null ? NetworkImage(pilot.imageUrl!) : null,
            child: pilot.imageUrl == null ? Icon(Icons.person, color: RCColors.iconSecondary) : null,
          ),
          title: Text(pilot.fullName, style: TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold)),
          subtitle: Text(pilot.subCategory, style: TextStyle(color: RCColors.textSecondary)),
          trailing: Text('${pilot.totalPoints} pts', style: TextStyle(color: RCColors.textSecondary, fontWeight: FontWeight.bold)),
        ),
      )),
    ],
  );

  // Mapa
  Widget _buildLocation(RaceEventModel event) => _buildSection(
    title: 'det_location'.tr,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Solo el mapa, sin texto de población
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: (event.circuitLat != null && event.circuitLng != null)
              ? EventLocationMap(
            lat: event.circuitLat!,
            lng: event.circuitLng!,
            title: event.circuitName ?? "Carrera RC",
          )
              : _buildNoMapPlaceholder(),
        ),
      ],
    ),
  );

  // Accion Boton inferior
  Widget _buildBottomAction() {
    final event = controller.event.value;
    final bool isInscriptionsOpen = event.eventRegFin != null && event.eventRegFin!.isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      color: RCColors.background,
      child: RCPrimaryButton(
        label: isInscriptionsOpen ? 'det_register_now'.tr : 'det_register_closed'.tr,
        onPressed: isInscriptionsOpen ? () => Get.toNamed(Routes.EVENT_REGISTRATION, arguments: event) : null,
      ),
    );
  }

  // Widgets reutilizables
  Widget _buildSection({required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      child
    ]),
  );

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: RCColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyle(
                          color: RCColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: RCColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 20),
              child,
            ],
          ],
        ),
      );

  Widget _buildDetailRow({required IconData icon, required Color iconColor, required String title, required String subtitle}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 24)
      ),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: RCColors.textSecondary, fontSize: 14))
      ]))
    ]),
  );

  Widget _buildNoMapPlaceholder() => Container(
    height: 180,
    decoration: BoxDecoration(
        color: RCColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RCColors.divider)
    ),
    child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: RCColors.iconSecondary, size: 40),
              const SizedBox(height: 10),
              Text('det_no_map'.tr, style: TextStyle(color: RCColors.textSecondary))
            ]
        )
    ),
  );
}