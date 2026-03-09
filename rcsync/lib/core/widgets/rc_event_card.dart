import 'package:flutter/material.dart';

/// A card widget to display event information in the RCSync app.
class RCEventCard extends StatelessWidget {
  final String title;
  final String location;
  final DateTime date;
  final VoidCallback onTap;

  const RCEventCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: const BoxDecoration(
            // Sutil detalle: borde izquierdo naranja para destacar
            border: Border(left: BorderSide(color: Color(0xFFF24E02), width: 4)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.speed, color: Color(0xFF13508B), size: 40), // Azul corporativo
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "$location • ${date.day}/${date.month}/${date.year}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Color(0xFFF24E02)),
            ],
          ),
        ),
      ),
    );
  }
}
