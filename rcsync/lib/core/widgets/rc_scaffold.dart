import 'package:flutter/material.dart';
import '../theme/rc_colors.dart';
import '../theme/rc_spacing.dart'; // Asegúrate de que esta importación esté presente

class RCScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const RCScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual para asegurar reactividad total
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? RCColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // Si el tema no define color, usamos el de fondo por defecto de tu rama
        backgroundColor: theme.appBarTheme.backgroundColor ?? RCColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: theme.appBarTheme.iconTheme ?? const IconThemeData(color: RCColors.orange),
      ),
      body: Padding(
        // Usamos tus constantes de espaciado para mantener la cuadrícula visual
        padding: const EdgeInsets.symmetric(horizontal: RCSpacing.md),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}