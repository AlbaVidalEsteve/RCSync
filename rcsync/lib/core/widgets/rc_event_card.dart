import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/rc_colors.dart';

class RCEventCard extends StatelessWidget {
  final String title;
  final String location;
  final DateTime date;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool isAccepted;

  const RCEventCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.onTap,
    this.isAccepted = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: RCColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: RCColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? Image.network(imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        height: 160,
                        width: double.infinity,
                        color: RCColors.background.withOpacity(0.1),
                        child: Icon(Icons.image, color: RCColors.iconSecondary, size: 50),
                      ),
                ),
                if (isAccepted)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.black),
                    ),
                  ),
              ],
            ),
            
            // Texto inferior
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: RCColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    location,
                    style: TextStyle(color: RCColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM', 'es_ES').format(date),
                            style: TextStyle(color: RCColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                      const Text(
                        "3 categorías",
                        style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
