import 'package:flutter/material.dart';
import '../theme/rc_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: RCSpacing.sm),
      padding: const EdgeInsets.all(RCSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category == 'SUPERSTOCK' 
            ? RCColors.orange 
            : (isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildCategoryBadge(category),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String cat) {
    final isSuper = cat.toUpperCase() == 'SUPERSTOCK';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSuper ? RCColors.orange : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        cat,
        style: TextStyle(
          color: isSuper ? Colors.white : Colors.grey,
          fontSize: 10, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
