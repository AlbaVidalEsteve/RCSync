import 'package:flutter/material.dart';
import 'package:supabase_notes/core/widgets/rc_event_card.dart';
import 'package:supabase_notes/core/widgets/rc_primary_button.dart';

/// The main dashboard screen showing upcoming events.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo_rcsync.png', height: 40),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Próximas Carreras",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          RCEventCard(
            title: "Tamiya Cup - AMSA",
            location: "Barcelona",
            date: DateTime(2025, 3, 2),
            onTap: () {},
          ),
          RCEventCard(
            title: "Tamiya Cup - CALL",
            location: "Cerdanyola",
            date: DateTime(2025, 4, 13),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          RCPrimaryButton(
            label: "Proponer Nuevo Evento",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
