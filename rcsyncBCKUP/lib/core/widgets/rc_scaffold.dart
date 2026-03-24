// lib/views/widgets/rc_scaffold.dart


import 'package:flutter/material.dart';

import '../theme/rc_colors.dart';

class RCScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const RCScaffold({required this.title, required this.body, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RCColors.background,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: RCColors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
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