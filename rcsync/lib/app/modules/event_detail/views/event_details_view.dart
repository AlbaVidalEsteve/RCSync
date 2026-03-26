import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/widgets/rc_primary_button.dart';
import 'package:rcsync/app/modules/map/views/map_view.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/routes/app_pages.dart';

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

        final event = controller.event.value;
        final bool isInscriptionsOpen = event.eventRegFin != null &&
            event.eventRegFin!.isAfter(DateTime.now());

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: RCColors.background,
              leading: _buildBackBtn(),
              flexibleSpace: FlexibleSpaceBar(background: _buildHeaderBackground(event)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: _buildInscriptionsStatus(isInscriptionsOpen)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RCPrimaryButton(
                        label: "INSCRIBIRSE AHORA",
                        onPressed: isInscriptionsOpen ? () => Get.toNamed(Routes.EVENT_REGISTRATION) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // 1. FECHAS IMPORTANTES
                  _buildSectionCard(
                    title: "Fechas Importantes",
                    child: Column(children: [
                      _buildDetailRow(icon: Icons.calendar_today_outlined, iconColor: Colors.blueAccent, title: "Día de Carrera", subtitle: controller.formattedDate),
                      const Divider(color: Colors.white10),
                      _buildDetailRow(icon: Icons.euro_symbol, iconColor: RCColors.orange, title: "Precio Inscripción", subtitle: "${event.prize ?? 0} € por categoría"),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // 2. DESCRIPCIÓN
                  _buildSectionCard(
                    title: "Descripción",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.circuitAddress != null) ...[
                          Text("Dirección: ${event.circuitAddress}", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                        ],
                        Text(event.description ?? "Sin descripción disponible.", style: TextStyle(color: Colors.white.withAlpha(153), height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. PILOTOS INSCRITOS
                  const Text("Pilotos Inscritos", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("Ordenados por ranking general", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 15),

                  if (controller.registeredPilots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Cargando lista...", style: TextStyle(color: Colors.white38)),
                    )
                  else
                    ...controller.registeredPilots.entries.map((entry) => _buildCategoryTable(entry.key, entry.value)).toList(),

                  const SizedBox(height: 25),

                  // 4. MAPA (AL FINAL)
                  const Text("Ubicación del Circuito", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (event.circuitLat != null && event.circuitLng != null)
                    EventLocationMap(lat: event.circuitLat!, lng: event.circuitLng!, title: event.circuitName ?? "CIRCUITO")
                  else
                    _buildNoMapPlaceholder(),

                  const SizedBox(height: 50),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildBackBtn() => Padding(padding: const EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Colors.black38, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Get.back())));

  Widget _buildHeaderBackground(event) => Stack(fit: StackFit.expand, children: [
    if (event.imageEvent != null && event.imageEvent!.isNotEmpty) Image.network(event.imageEvent!, fit: BoxFit.cover) else Image.asset('assets/images/logo_rcsync.jpeg', fit: BoxFit.cover),
    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))),
    Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text((event.name ?? "S/N").toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Row(children: [const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18), const SizedBox(width: 5), Text(event.circuitName ?? "Circuito por definir", style: const TextStyle(color: Colors.white70, fontSize: 16))]),
    ])),
  ]);

  Widget _buildCategoryTable(String categoryName, List<RegisteredPilot> pilots) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(color: const Color(0xFF1A222D), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.05))),
    child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: const BorderRadius.vertical(top: Radius.circular(15))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(categoryName.toUpperCase(), style: const TextStyle(color: RCColors.orange, fontWeight: FontWeight.bold, fontSize: 14)), Text("${pilots.length} Pilotos", style: const TextStyle(color: Colors.white38, fontSize: 12))])),
      ListView.separated(padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: pilots.length, separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1), itemBuilder: (context, index) {
        final pilot = pilots[index];
        return ListTile(dense: true, leading: CircleAvatar(radius: 14, backgroundColor: RCColors.orange.withOpacity(0.1), child: Text("${index + 1}", style: const TextStyle(color: RCColors.orange, fontSize: 11, fontWeight: FontWeight.bold))), title: Text(pilot.fullName, style: const TextStyle(color: Colors.white, fontSize: 14)), subtitle: Text("${pilot.totalPoints} pts", style: const TextStyle(color: Colors.white24, fontSize: 10)), trailing: _buildSubcatBadge(pilot.subCategory));
      }),
    ]),
  );

  Widget _buildSubcatBadge(String sub) => sub.isEmpty ? const SizedBox() : Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (sub == 'SUPERSTOCK' ? Colors.purple : Colors.blue).withOpacity(0.2), borderRadius: BorderRadius.circular(5)), child: Text(sub, style: TextStyle(color: sub == 'SUPERSTOCK' ? Colors.purpleAccent : Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)));

  Widget _buildInscriptionsStatus(bool isOpen) => Container(height: 55, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: isOpen ? Colors.greenAccent.withAlpha(128) : Colors.redAccent.withAlpha(128)), color: isOpen ? Colors.greenAccent.withAlpha(13) : Colors.redAccent.withAlpha(13)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(isOpen ? Icons.lock_open : Icons.lock, color: isOpen ? Colors.greenAccent : Colors.redAccent, size: 20), const SizedBox(width: 8), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("INSCRIPCIONES", style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)), Text(isOpen ? "ABIERTAS" : "CERRADAS", style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold))])]));

  Widget _buildSectionCard({required String title, required Widget child}) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1A222D), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 20), child]));

  Widget _buildDetailRow({required IconData icon, required Color iconColor, required String title, required String subtitle}) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 24)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14))]))]));

  Widget _buildNoMapPlaceholder() => Container(height: 200, decoration: BoxDecoration(color: const Color(0xFF1A222D), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map_outlined, color: Colors.white24, size: 40), SizedBox(height: 10), Text("Mapa no disponible", style: TextStyle(color: Colors.white24))])));
}