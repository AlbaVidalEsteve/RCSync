import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_primary_button.dart';
import 'package:rcsync/app/modules/map/views/map_view.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:rcsync/app/data/models/race_event_model.dart';
import 'package:intl/intl.dart';

class EventDetailsView extends GetView<EventDetailsController> {
  const EventDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  
                  // 1. FECHAS Y INFO PRINCIPAL (Tu diseño de Card + Datos Master)
                  _buildSectionCard(
                    title: "Información General",
                    child: Column(children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined, 
                        iconColor: Colors.blueAccent, 
                        title: "Día de Carrera", 
                        subtitle: controller.formattedDate
                      ),
                      Divider(color: RCColors.divider),
                      _buildDetailRow(
                        icon: Icons.emoji_events_outlined, 
                        iconColor: Colors.amber, 
                        title: "Organizador", 
                        subtitle: event.organizerName ?? 'Club RC'
                      ),
                      Divider(color: RCColors.divider),
                      _buildDetailRow(
                        icon: Icons.euro_symbol, 
                        iconColor: RCColors.orange, 
                        title: "Precio Inscripción", 
                        subtitle: "${event.prize ?? 0} € por categoría"
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // 2. REGLAMENTOS (Lógica Master con tu estética)
                  _buildRulebooksSection(),
                  const SizedBox(height: 20),

                  // 3. DESCRIPCIÓN
                  _buildSectionCard(
                    title: "Descripción",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.circuitAddress != null) ...[
                          Text("Dirección: ${event.circuitAddress}", 
                            style: const TextStyle(color: RCColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                        ],
                        Text(event.description ?? "Sin descripción disponible.", 
                          style: const TextStyle(color: RCColors.textSecondary, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 4. PILOTOS INSCRITOS (Tu tabla detallada)
                  Text("Pilotos Inscritos", style: TextStyle(color: RCColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Ordenados por ranking general", style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 15),

                  if (controller.registeredPilots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No hay pilotos inscritos aún", style: TextStyle(color: RCColors.textSecondary)),
                    )
                  else
                    ...controller.registeredPilots.entries.map((entry) => _buildCategoryTable(entry.key, entry.value)).toList(),

                  const SizedBox(height: 25),

                  // 5. UBICACIÓN (Estética Master pero al final como querías tú)
                  Text("Ubicación del Circuito", style: TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      height: 300,
                      child: (event.circuitLat != null && event.circuitLng != null)
                          ? EventLocationMap(
                              lat: event.circuitLat!,
                              lng: event.circuitLng!,
                              title: event.circuitName ?? "CIRCUITO",
                            )
                          : _buildNoMapPlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 100), 
                ]),
              ),
            ),
          ],
        );
      }),
      bottomSheet: _buildBottomAction(), // Acción de Master
    );
  }

  // --- MÉTODOS DE APOYO UNIFICADOS ---

  Widget _buildRulebooksSection() {
    if (controller.rulebooks.isEmpty) return const SizedBox.shrink();
    return _buildSectionCard(
      title: 'Reglamentos Técnicos',
      child: Column(
        children: controller.rulebooks.map((rb) {
          final catName = rb['categories']?['name'] ?? 'General';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
            title: Text('Reglamento $catName', style: const TextStyle(color: RCColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Toca para abrir PDF', style: TextStyle(color: RCColors.textSecondary, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, color: RCColors.iconSecondary, size: 16),
            onTap: () => controller.openRulebook(rb['rulebook_url']),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTable(String categoryName, List<RegisteredPilot> pilots) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: RCColors.divider)),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: const BorderRadius.vertical(top: Radius.circular(15))), 
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(categoryName.toUpperCase(), style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 14)), 
          Text("${pilots.length} Pilotos", style: const TextStyle(color: RCColors.textSecondary, fontSize: 12))
        ])
      ),
      ListView.separated(
        padding: EdgeInsets.zero, 
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(), 
        itemCount: pilots.length, 
        separatorBuilder: (_, __) => Divider(color: RCColors.divider, height: 1), 
        itemBuilder: (context, index) {
          final pilot = pilots[index];
          return ListTile(
            dense: true, 
            leading: CircleAvatar(
              radius: 14, 
              backgroundColor: RCColors.orange.withOpacity(0.1), 
              child: Text("${index + 1}", style: const TextStyle(color: RCColors.orange, fontSize: 11, fontWeight: FontWeight.bold))
            ), 
            title: Text(pilot.fullName, style: const TextStyle(color: RCColors.textPrimary, fontSize: 14)), 
            subtitle: Text("${pilot.totalPoints} pts", style: const TextStyle(color: RCColors.textSecondary, fontSize: 10)), 
            trailing: Text(pilot.subCategory, style: const TextStyle(color: RCColors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          );
        }
      ),
    ]),
  );

  Widget _buildHeaderBackground(RaceEventModel event) => Stack(
    fit: StackFit.expand,
    children: [
      if (event.imageEvent != null)
        Image.network(event.imageEvent!, fit: BoxFit.cover)
      else
        Container(color: RCColors.orange.withOpacity(0.2), child: const Icon(Icons.image, size: 100, color: Colors.white24)),
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, RCColors.background],
          ),
        ),
      ),
    ],
  );

  Widget _buildBottomAction() {
    final event = controller.event.value;
    final bool isInscriptionsOpen = event.eventRegFin != null && event.eventRegFin!.isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      color: RCColors.background,
      child: RCPrimaryButton(
        label: isInscriptionsOpen ? 'Inscribirse ahora' : 'Inscripciones cerradas',
        onPressed: isInscriptionsOpen ? () => Get.toNamed(Routes.EVENT_REGISTRATION, arguments: event) : null,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) => Container(
    padding: const EdgeInsets.all(20), 
    decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(20)), 
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: RCColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)), 
      const SizedBox(height: 20), 
      child
    ])
  );

  Widget _buildDetailRow({required IconData icon, required Color iconColor, required String title, required String subtitle}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10), 
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 24)), 
      const SizedBox(width: 15), 
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: RCColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)), 
        const SizedBox(height: 2), 
        Text(subtitle, style: const TextStyle(color: RCColors.textSecondary, fontSize: 14))
      ]))
    ])
  );

  Widget _buildBackBtn() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: CircleAvatar(
      backgroundColor: Colors.black38,
      child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
    ),
  );

  Widget _buildNoMapPlaceholder() => Container(
    height: 200, 
    decoration: BoxDecoration(color: RCColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: RCColors.divider)), 
    child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.map_outlined, color: RCColors.iconSecondary, size: 40), 
      SizedBox(height: 10), 
      Text("Mapa no disponible", style: TextStyle(color: RCColors.textSecondary))
    ]))
  );
}