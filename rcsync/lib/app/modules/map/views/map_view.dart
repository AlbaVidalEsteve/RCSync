import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rcsync/core/theme/rc_colors.dart';

class EventLocationMap extends StatelessWidget {
  final double lat;
  final double lng;
  final String title;

  const EventLocationMap({
    super.key,
    required this.lat,
    required this.lng,
    this.title = "Carrera rcsync"
  });

  Future<void> _openGoogleMaps() async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el mapa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: RCColors.cardDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: RCColors.orange.withOpacity(0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Mapa
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.rcsync',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: RCColors.orange,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                ),
              ],
            ),
            // Botón para abrir Google Maps
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                onPressed: _openGoogleMaps,
                backgroundColor: RCColors.orange,
                mini: true,
                child: const Icon(Icons.directions, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}