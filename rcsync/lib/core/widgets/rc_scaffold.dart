import 'package:flutter/material.dart';
import 'package:rcsync/core/theme/rc_colors.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: RCSpacing.md),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
