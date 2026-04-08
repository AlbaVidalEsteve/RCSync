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
                      // 1. Información del Evento (Fechas y Organizador)
                      _buildEventInfo(event),
                      const SizedBox(height: 20),

                      // 2. Reglamentos Técnicos
                      _buildRulebooksSection(),
                      const SizedBox(height: 20),

                      // 3. Pilotos Inscritos
                      _buildPilotList(),
                      const SizedBox(height: 20),

                      // 4. Mapa y Ubicación (Movido al final)
                      _buildLocation(event),

                      const SizedBox(height: 100), // Espacio inferior para que no lo tape el botón
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

  Widget _buildRulebooksSection() {
    return Obx(() {
      if (controller.rulebooks.isEmpty) return const SizedBox.shrink();

      return _buildSection(
        title: 'Reglamentos Técnicos',
        child: Column(
          children: controller.rulebooks.map((rb) {
            final catName = rb['categories']?['name'] ?? 'General';
            final url = rb['rulebook_url'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                title: Text(
                  'Reglamento $catName',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text('Toca para abrir PDF', style: TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                onTap: () => controller.openRulebook(url),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildHeaderBackground(RaceEventModel event) => Stack(
    fit: StackFit.expand,
    children: [
      if (event.imageEvent != null)
        Image.network(event.imageEvent!, fit: BoxFit.cover)
      else
        Container(
            color: RCColors.orange.withOpacity(0.2),
            child: const Icon(Icons.image, size: 100, color: Colors.white24)
        ),
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

  Widget _buildEventInfo(RaceEventModel event) => _buildSection(
    title: event.name,
    child: Column(
      children: [
        _buildDetailRow(
            icon: Icons.calendar_today,
            iconColor: RCColors.orange,
            title: 'Fecha',
            subtitle: controller.formattedDate
        ),
        _buildDetailRow(
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber,
            title: 'Organizador',
            subtitle: event.organizerName ?? 'Club RC'
        ),
      ],
    ),
  );

  Widget _buildLocation(RaceEventModel event) => _buildSection(
    title: 'Ubicación',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.circuitName ?? 'Circuito RC', style: const TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 400,
            child: (event.circuitLat != null && event.circuitLng != null)
                ? EventLocationMap(
              lat: event.circuitLat!,
              lng: event.circuitLng!,
              title: event.circuitName ?? "Carrera rcsync",
            )
                : _buildNoMapPlaceholder(),
          ),
        ),
      ],
    ),
  );

  Widget _buildPilotList() => Obx(() {
    if (controller.registeredPilots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilotos Inscritos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ...controller.registeredPilots.entries.map((entry) => _buildCategoryGroup(entry.key, entry.value)),
      ],
    );
  });

  Widget _buildCategoryGroup(String category, List<RegisteredPilot> pilots) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(category, style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      ...pilots.map((pilot) => Card(
        color: const Color(0xFF1A222D),
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white10,
            backgroundImage: pilot.imageUrl != null ? NetworkImage(pilot.imageUrl!) : null,
            child: pilot.imageUrl == null ? const Icon(Icons.person, color: Colors.white24) : null,
          ),
          title: Text(pilot.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(pilot.subCategory, style: const TextStyle(color: Colors.white54)),
          trailing: Text('${pilot.totalPoints} pts', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        ),
      )),
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

  Widget _buildSection({required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF1A222D), borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      child
    ]),
  );

  Widget _buildDetailRow({required IconData icon, required Color iconColor, required String title, required String subtitle}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 24)
      ),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14))
      ]))
    ]),
  );

  Widget _buildNoMapPlaceholder() => Container(
    height: 180,
    decoration: BoxDecoration(
        color: const Color(0xFF1A222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10)
    ),
    child: const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: Colors.white24, size: 40),
              SizedBox(height: 10),
              Text('Mapa no disponible', style: TextStyle(color: Colors.white24))
            ]
        )
    ),
  );
}