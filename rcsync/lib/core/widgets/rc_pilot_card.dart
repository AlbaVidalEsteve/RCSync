import 'package:flutter/material.dart';
import 'package:rcsync/core/theme/rc_colors.dart';
import 'package:rcsync/core/theme/rc_spacing.dart';

class RCPilotCard extends StatelessWidget {
  final String name;
  final String category; // STOCK / SUPERSTOCK

  const RCPilotCard({
    super.key,
    required this.name,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos el contexto para detectar el brillo y adaptar los bordes
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: RCSpacing.sm),
      padding: const EdgeInsets.all(RCSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? RCColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Si es SUPERSTOCK resaltamos con naranja (tu identidad de marca)
          color: category.toUpperCase() == 'SUPERSTOCK' 
            ? RCColors.orange 
            : (isDark ? Colors.white10 : Colors.black12),
          width: category.toUpperCase() == 'SUPERSTOCK' ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? RCColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildCategoryBadge(category),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String cat) {
    final isSuper = cat.toUpperCase() == 'SUPERSTOCK';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSuper ? RCColors.orange : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8), // Bordes un poco más suaves
      ),
      child: Text(
        cat.toUpperCase(),
        style: TextStyle(
          color: isSuper ? Colors.white : (isSuper ? Colors.white : Colors.grey),
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}