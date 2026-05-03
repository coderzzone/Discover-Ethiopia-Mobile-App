import 'package:flutter/material.dart';

import '../widgets/ui_components.dart';

class TravelToolkitScreen extends StatelessWidget {
  const TravelToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EthioColors.background,
      appBar: AppBar(
        title: const Text('Travel Toolkit'),
        backgroundColor: EthioColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: const [
          _ToolCard(
            icon: Icons.phone_in_talk_rounded,
            title: 'Emergency Contacts',
            lines: ['Police: 991', 'Ambulance: 907', 'Fire: 939'],
            color: EthioColors.error,
          ),
          SizedBox(height: 12),
          _ToolCard(
            icon: Icons.translate_rounded,
            title: 'Useful Phrases',
            lines: ['Hello: Selam', 'Thank you: Ameseginalehu', 'How much?: Sint new?'],
            color: EthioColors.secondary,
          ),
          SizedBox(height: 12),
          _ToolCard(
            icon: Icons.bolt_rounded,
            title: 'Power & Connectivity',
            lines: ['Plug type: C / F', 'Voltage: 220V', 'Download offline map before road trips'],
            color: EthioColors.primary,
          ),
          SizedBox(height: 12),
          _ToolCard(
            icon: Icons.health_and_safety_rounded,
            title: 'Health Tips',
            lines: ['Hydrate frequently at altitude', 'Carry basic meds', 'Use sunscreen for highland sun'],
            color: EthioColors.tertiary,
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.lines,
    required this.color,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(line)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
