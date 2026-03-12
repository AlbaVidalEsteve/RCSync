import 'package:flutter/material.dart';

/// A primary button with a gradient background for the RCSync app.
class RCPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const RCPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isEnabled 
          ? const LinearGradient(
              colors: [
                Color(0xFFF24E02),
                Color(0xFFF68B28),
              ],
            )
          : null,
        color: isEnabled ? null : Colors.grey[800],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isEnabled ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}
