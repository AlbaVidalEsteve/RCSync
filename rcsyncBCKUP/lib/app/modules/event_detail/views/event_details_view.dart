import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/rc_colors.dart';
import '../../../../core/widgets/rc_primary_button.dart';
import '../../../data/models/race_event_model.dart';
import '../../map/views/map_view.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recuperamos el evento de los argumentos
    final RaceEventModel event = Get.arguments;
    
    // Lógica para saber si las inscripciones están abiertas
    final bool isInscriptionsOpen = event.eventRegFin != null && 
                                   event.eventRegFin!.isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: RCColors.background,
      body: CustomScrollView(
        slivers: [
          // CABECERA CON IMAGEN Y TÍTULO
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: RCColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildBadge(
                  text: "✓ Aceptado", 
                  color: Colors.greenAccent[700]!,
                  textColor: Colors.white,
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo
                  if (event.imageEvent != null)
                    Image.network(event.imageEvent!, fit: BoxFit.cover)
                  else
                    Image.asset('assets/images/logo_rcsync.jpeg', fit: BoxFit.cover),
                  
                  // Gradiente oscuro
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  
                  // Título y Ubicación sobre la imagen
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              event.circuitName ?? "Circuito por definir",
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTONES DE ESTADO E INSCRIPCIÓN
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildInscriptionsStatus(isInscriptionsOpen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: RCPrimaryButton(
                      label: "INSCRIBIRSE AHORA",
                      onPressed: isInscriptionsOpen ? () {} : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CUERPO DE LA PANTALLA
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // SECCIÓN: FECHAS IMPORTANTES
                _buildSectionCard(
                  title: "Fechas Importantes",
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        iconColor: Colors.blueAccent,
                        title: "Inscripciones",
                        subtitle: "${_formatDate(event.eventRegIni)} - ${_formatDate(event.eventRegFin)}",
                      ),
                      const Divider(color: Colors.white10),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        iconColor: Colors.purpleAccent,
                        title: "Evento",
                        subtitle: "${_formatDate(event.eventDateIni)} · 08:00 - 14:00",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // SECCIÓN: ORGANIZADOR
                _buildSectionCard(
                  title: "Organizador",
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.indigoAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.organizerName ?? "Organizador rcsync",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Organizador Verificado",
                            style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // SECCIÓN: DESCRIPCIÓN
                _buildSectionCard(
                  title: "Descripción",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.circuitAddress != null) ...[
                        Text(
                          "Dirección: ${event.circuitAddress}",
                          style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        event.description ?? "No hay descripción disponible para este evento.",
                        style: TextStyle(color: Colors.white.withAlpha(153), height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // SECCIÓN: MAPA
                if (event.circuitLat != null && event.circuitLng != null)
                  EventLocationMap(
                    lat: event.circuitLat!,
                    lng: event.circuitLng!,
                    title: event.circuitName ?? "CIRCUITO",
                  )
                else
                  const _NoMapPlaceholder(),

                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS DE APOYO
  Widget _buildBadge({required String text, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInscriptionsStatus(bool isOpen) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isOpen ? Colors.greenAccent.withAlpha(128) : Colors.redAccent.withAlpha(128)),
        color: isOpen ? Colors.greenAccent.withAlpha(13) : Colors.redAccent.withAlpha(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isOpen ? Icons.lock_open : Icons.lock, color: isOpen ? Colors.greenAccent : Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("INSCRIPCIONES", style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(isOpen ? "ABIERTAS" : "CERRADAS", style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A222D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(128), fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "TBD";
    return DateFormat('dd MMM yyyy', 'es_ES').format(date);
  }
}

class _NoMapPlaceholder extends StatelessWidget {
  const _NoMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: Colors.white24, size: 40),
            SizedBox(height: 10),
            Text("Mapa no disponible", style: TextStyle(color: Colors.white24)),
          ],
        ),
      ),
    );
  }
}
