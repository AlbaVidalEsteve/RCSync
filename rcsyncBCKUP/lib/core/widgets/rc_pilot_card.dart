// lib/views/widgets/rc_pilot_card.dart
import 'package:flutter/material.dart';

import '../theme/rc_colors.dart';

class RCPilotCard extends StatelessWidget {
  final String name;
  final String category; // Stock / Superstock

  const RCPilotCard({required this.name, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: RCSpacing.sm),
      padding: EdgeInsets.all(RCSpacing.md),
      decoration: BoxDecoration(
        color: RCColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category == 'SUPERSTOCK' ? RCColors.orange : Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: RCColors.white, fontSize: 16)),
          _buildCategoryBadge(category),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String cat) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cat == 'SUPERSTOCK' ? RCColors.orange : Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(cat, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}