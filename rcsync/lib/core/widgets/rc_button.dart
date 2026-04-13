// lib/views/widgets/rc_button.dart
import 'package:flutter/material.dart';

import '../theme/rc_colors.dart';

class RCButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const RCButton({required this.text, required this.onPressed, this.isSecondary = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? RCColors.darkBlue : RCColors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}